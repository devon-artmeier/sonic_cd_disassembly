; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"
	
; ------------------------------------------------------------------------------
; Driver entry point
; ------------------------------------------------------------------------------

	section code_rst_00
DriverStart:
	di							; Disable interrupts
	di
	im	1						; Interrupt mode 1
	
	jr	InitDriver					; Initialize driver

; ------------------------------------------------------------------------------
; Get list from driver info table
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Table index
; RETURNS:
;	hl - Pointer to list
; ------------------------------------------------------------------------------

	section code_rst_08
GetList:
	ld	hl,DriverInfo					; Get pointer to entry
	ld	b,0
	add	hl,bc
	ex	af,af'						; Read pointer
	rst	20h
	ex	af,af'
	ret
	
; ------------------------------------------------------------------------------
; Read pointer from table
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Table index
;	hl - Pointer to table
; ------------------------------------------------------------------------------

	section code_rst_18_20
ReadTablePointer:
	ld	c,a						; Get pointer to entry
	ld	b,0
	add	hl,bc
	add	hl,bc
	nop
	nop
	nop

; ------------------------------------------------------------------------------
; Read pointer from HL register
; ------------------------------------------------------------------------------
; PARAMETERS:
;	hl - Pointer to read
; RETURNS:
;	hl - Read pointer
; ------------------------------------------------------------------------------

ReadHlPointer:
	ld	a,(hl)						; Read from HL into HL
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret
	
; ------------------------------------------------------------------------------
; Initialize driver
; ------------------------------------------------------------------------------

	section code
InitDriver:
	ld	sp,stack_base					; Set stack pointer
	
	ld	c,0						; Delay with a 65536 times loop

.Delay:
	ld	b,0
	
.DelayLoop:
	djnz	.DelayLoop
	dec	c
	jr	nz,.Delay
	
	call	StopSound					; Stop all sound

.Loop:
	call	ProcessSoundQueue				; Process sound queue
	
	ld	a,(YM_ADDR_0)					; Has timer B run out?
	bit	1,a
	jr	z,.Loop						; If not, wait
	call	ResetTimerB					; Reset timer B
	
	call	UpdateTracks					; Update tracks
	jr	.Loop						; Loop

; ------------------------------------------------------------------------------
; Reset timer B
; ------------------------------------------------------------------------------

ResetTimerB:
	ld	c,0C8h						; Set timer B frequency
	ld	a,26h
	call	WriteYm1
	
	ld	a,2Fh						; Start timer B up again
	ld	hl,ym_reg_27
	or	(hl)
	ld	c,a
	ld	a,27h
	call	WriteYm1
	ret
	
; ------------------------------------------------------------------------------
; Update tracks
; ------------------------------------------------------------------------------

UpdateTracks:
	call	PlaySoundId					; Check sound ID and play it
	
	ld	ix,fm1_track					; Start on FM1
	ld	b,TRACK_COUNT					; Number of tracks

.Update:
	push	bc						; Save counter
	
	bit	TRACK_PLAY,(ix+track.flags)			; Is this track playing?
	call	nz,UpdateTrack					; If so, update it
	
	ld	de,track.struct_size				; Next track
	add	ix,de
	pop	bc						; Loop until all tracks are updated
	djnz	.Update
	ret

; ------------------------------------------------------------------------------
; Update track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

UpdateTrack:
	call	UpdateDuration					; Update note duration
	jr	nz,.Update					; If it hasn't run out, ranch
	
	call	ParseTrackData					; Parse track data
	bit	TRACK_REST,(ix+track.flags)			; Is this track rested?	
	ret	nz						; If so, exit
	
	call	InitVibrato					; Initialize vibrato
	call	UpdatePortamento				; Update portamento
	call	UpdateVibrato					; Update vibrato
	call	UpdateFrequency					; Update frequency
	jp	SetKeyOn					; Set key on
	
; --------------------------------------------------------------------------------

.Update:
	bit	TRACK_REST,(ix+track.flags)			; Is this track rested?	
	ret	nz						; If so, exit
	
	ld	a,(ix+track.staccato_timer)			; Get staccato counter
	or	a
	jr	z,.NoStaccato					; If it's not active, branch
	dec	(ix+track.staccato_timer)			; Decrement staccato counter
	jp	z,SetKeyOff					; If it has run out, set key off

.NoStaccato:
	call	UpdatePortamento				; Update portamento
	bit	TRACK_VIBRATO_END,(ix+track.flags)		; Has the vibrato envelope ended?
	ret	nz						; If so, branch
	call	UpdateVibrato					; Update vibrato

; ------------------------------------------------------------------------------
; Update frequency
; ------------------------------------------------------------------------------
; PARAMETERS:
;	hl - Frequency value
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

UpdateFrequency:
	bit	TRACK_MUTE,(ix+track.flags)			; Is sound disabled?
	ret	nz						; If so, branch
	bit	TRACK_FM3_DETUNE,(ix+track.flags)		; Is FM3 detune mode on?
	jp	nz,.CheckFm3					; If so, branch

.Normal:
	ld	a,0A4h						; Write frequency
	ld	c,h
	call	WriteYmTrack
	ld	a,0A0h
	ld	c,l
	call	WriteYmTrack
	ret

; --------------------------------------------------------------------------------

.CheckFm3:
	ld	a,(ix+track.channel)				; Is this FM3?
	cp	2
	jr	nz,.Normal					; If not, branch

	ld	de,fm3_detune_op1				; Detune value array
	exx
	ld	hl,SpecialFm3Regs				; Special FM3 frequency registers
	ld	b,4						; Number of operators

.SetFm3Detune:
	ld	a,(hl)						; Get FM3 operator frequency register
	push	af
	inc	hl
	
	exx							; Get FM3 operator detune value
	ex	de,hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ex	de,hl
	ld	l,(ix+track.frequency)				; Add to base frequency value
	ld	h,(ix+track.frequency+1)
	add	hl,bc
	
	pop	af						; Write frequency
	push	af
	ld	c,h
	call	WriteYm1
	pop	af
	sub	4
	ld	c,l
	call	WriteYm1
	
	exx							; Loop until all operators are set
	djnz	.SetFm3Detune
	exx
	ret

; ------------------------------------------------------------------------------
; Parse track data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

ParseTrackData:
	ld	e,(ix+track.data)				; Get data pointer
	ld	d,(ix+track.data+1)
	res	TRACK_LEGATO,(ix+track.flags)			; Clear legato flag
	res	TRACK_REST,(ix+track.flags)			; Clear rest flag

ParseTrackCommand:
	ld	a,(de)						; Read byte from track data
	inc	de
	cp	0E0h						; Is it a track command?
	jp	nc,TrackCommand					; If so, branch
	
	ex	af,af'						; Set key off
	call	SetKeyOff
	ex	af,af'
	
	bit	TRACK_RAW_FREQ,(ix+track.flags)			; Is raw frequency mode set?
	jp	nz,.RawFreqMode					; If so, branch
	
	or	a						; Is the read byte a duration value?
	jp	p,.CalcDuration					; If so, branch
	sub	81h						; Is it a note value?
	jp	p,.GetNote					; If so, branch
	set	TRACK_REST,(ix+track.flags)			; If it's a rest note, set the rest flag
	jr	.ReadDuration					; Read duration

.GetNote:
	add	a,(ix+track.transpose)				; Add transposition to note value
	
	push	de						; Calculate FM frequency block from note octave
	ld	d,8
	ld	e,0Ch
	ex	af,af'
	xor	a

.GetFreqBlock:
	ex	af,af'
	sub	e
	jr	c,.GotFreqBlock
	ex	af,af'
	add	a,d
	jr	.GetFreqBlock

.GotFreqBlock:
	add	a,e						; Get frequency value
	ld	hl,FrequencyTable
	rst	18h
	ex	af,af'
	or	h
	ld	h,a
	pop	de
	ld	(ix+track.frequency),l
	ld	(ix+track.frequency+1),h

.ReadDuration:
	bit	TRACK_PORTAMENTO,(ix+track.flags)		; Is portamento enabled?
	jr	nz,.SetPortaSpeed				; If so, branch
	
	ld	a,(de)						; Read another byte
	or	a						; Is it a duration?
	jp	p,.GotDuration					; If so, branch
	ld	a,(ix+track.duration)				; If not, use previous duration value
	ld	(ix+track.duration_timer),a
	jr	.Finish						; Finish update

.SetPortaSpeed:
	ld	a,(de)						; Read portamento speed
	inc	de
	ld	(ix+track.porta_speed),a
	jr	.ReadDuration2					; Read duration

; --------------------------------------------------------------------------------

.RawFreqMode:
	ld	h,a						; Get raw frequency value
	ld	a,(de)
	inc	de
	ld	l,a
	or	h
	jr	z,.SetRawFreq					; If it's 0, branch
	
	ld	a,(ix+track.transpose)				; Add transposition value
	ld	b,0
	or	a
	jp	p,.AddRawTranspose
	dec	b

.AddRawTranspose:
	ld	c,a
	add	hl,bc

.SetRawFreq:
	ld	(ix+track.frequency),l				; Set frequency
	ld	(ix+track.frequency+1),h
	
	bit	TRACK_PORTAMENTO,(ix+track.flags)		; Is portamento enabled?
	jr	z,.ReadDuration2				; If not, branch
	ld	a,(de)						; If so, read portamento speed
	inc	de
	ld	(ix+track.porta_speed),a

.ReadDuration2:
	ld	a,(de)						; Read duration value

.GotDuration:
	inc	de

.CalcDuration:
	call	CalcDuration					; Calculate note duration
	ld	(ix+track.duration),a

; --------------------------------------------------------------------------------

.Finish:
	ld	(ix+track.data),e				; Update data pointer
	ld	(ix+track.data+1),d
	
	ld	a,(ix+track.duration)				; Reset note duration
	ld	(ix+track.duration_timer),a

	bit	TRACK_LEGATO,(ix+track.flags)			; Is legato enabled?
	ret	nz						; If so, branch
	
	xor	a						; Clear vibrato speed counter
	ld	(ix+track.vibrato_speed),a
	ld	(ix+track.vibrato_offset),a			; Clear vibrato offset value
	ld	(ix+track.env_counter),a			; Clear enveloper counter
	ld	a,(ix+track.staccato)				; Reset staccato
	ld	(ix+track.staccato_timer),a
	ret
	
; ------------------------------------------------------------------------------
; Calculate note duration
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Input duration value
;	ix - Pointer to track variables
; RETURNS:
;	a  - Multiplied duration value
; ------------------------------------------------------------------------------

CalcDuration:
	ld	b,(ix+track.tick_multiply)			; Get tick multiplier
	dec	b
	ret	z						; If it's 1, exit

	ld	c,a						; Multiply duration with tick multiplier

.Multiply:
	add	a,c
	djnz	.Multiply
	ret

; ------------------------------------------------------------------------------
; Update note duration
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix   - Pointer to track variables
; RETURNS:
;	z/nz - Ran out/Still active
; ------------------------------------------------------------------------------

UpdateDuration:
	ld	a,(ix+track.duration_timer)				; Decrement note duration
	dec	a
	ld	(ix+track.duration_timer),a
	ret
	
; ------------------------------------------------------------------------------
; Initialize vibrato
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

InitVibrato:
	bit	7,(ix+track.vibrato_mode)			; Is vibrato enabled?
	ret	z						; If so, exit
	bit	TRACK_LEGATO,(ix+track.flags)			; Is legato set?
	ret	nz						; If so, exit
	
	ld	e,(ix+track.vibrato_params)			; Get vibrato parameters
	ld	d,(ix+track.vibrato_params+1)
	
	push	ix						; Copy parameters
	pop	hl
	ld	b,0
	ld	c,track.vibrato_wait
	add	hl,bc
	ex	de,hl
	ldi
	ldi
	ldi
	ld	a,(hl)						; 2 directions per cycle
	srl	a
	ld	(de),a
	
	xor	a						; Clear vibrato frequency value
	ld	(ix+track.vibrato_offset),a
	ld	(ix+track.vibrato_offset+1),a
	ret

; ------------------------------------------------------------------------------
; Update vibrato
; ------------------------------------------------------------------------------
; PARAMETERS:
;	hl - Input frequency value
;	ix - Pointer to track variables
; RETURNS:
;	hl - Modified frequency value
; ------------------------------------------------------------------------------

UpdateVibrato:
	ld	a,(ix+track.vibrato_mode)			; Is vibrato enabled?
	or	a
	ret	z						; If not, exit

	dec	(ix+track.vibrato_wait)				; Decrement delay counter
	ret	nz						; If it hasn't run out, exit
	inc	(ix+track.vibrato_wait)				; Cap it

	push	hl						; Get current vibrato frequency value
	ld	l,(ix+track.vibrato_offset)
	ld	h,(ix+track.vibrato_offset+1)
	
	dec	(ix+track.vibrato_speed)			; Update speed counter
	jr	nz,.UpdateDir
	ld	e,(ix+track.vibrato_params)
	ld	d,(ix+track.vibrato_params+1)
	push	de
	pop	iy
	ld	a,(iy+vibrato.speed)
	ld	(ix+track.vibrato_speed),a
	
	ld	a,(ix+track.vibrato_delta)			; Add delta value to vibrato frequency value
	ld	c,a
	and	80h
	rlca
	neg
	ld	b,a
	add	hl,bc
	ld	(ix+track.vibrato_offset),l
	ld	(ix+track.vibrato_offset+1),h

.UpdateDir:
	pop	bc						; Add input frequency
	add	hl,bc
	
	dec	(ix+track.vibrato_steps)			; Update direction step counter
	ret	nz
	ld	a,(iy+vibrato.steps)
	ld	(ix+track.vibrato_steps),a
	
	ld	a,(ix+track.vibrato_delta)			; Flip direction
	neg
	ld	(ix+track.vibrato_delta),a
	ret

; ------------------------------------------------------------------------------
; Set key on
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SetKeyOn:
	ld	a,(ix+track.frequency)				; Is a frequency set?
	or	(ix+track.frequency+1)
	ret	z						; If not, exit
	
	ld	a,(ix+track.flags)				; Is either legato set or sound disabled?
	and	(1<<TRACK_LEGATO)|(1<<TRACK_MUTE)
	ret	nz						; If so, exit

	ld	a,(ix+track.channel)				; Set key on
	or	0F0h
	ld	c,a
	ld	a,28h
	call	WriteYm1
	ret

; ------------------------------------------------------------------------------
; Set key off
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SetKeyOff:
	ld	a,(ix+track.flags)				; Is either legato set or sound disabled?
	and	(1<<TRACK_LEGATO)|(1<<TRACK_MUTE)
	ret	nz						; If so, exit

ForceKeyOff:
	res	TRACK_VIBRATO_END,(ix+track.flags)		; Clear vibrato envelope end flag
	
	ld	c,(ix+track.channel)				; Set key off
	ld	a,28h
	call	WriteYm1
	ret
	
; ------------------------------------------------------------------------------
; Update portamento
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; RETURNS:
;	hl - Frequency value
; ------------------------------------------------------------------------------

UpdatePortamento:
	ld	b,0						; Get portamento speed, sign extended
	ld	a,(ix+track.porta_speed)
	or	a
	jp	p,.GetNewFrequency
	dec	b

.GetNewFrequency:
	ld	h,(ix+track.frequency+1)			; Get frequency
	ld	l,(ix+track.frequency)
	ld	c,a						; Add portamento speed
	add	hl,bc
	ex	de,hl
	
	ld	a,7						; Get frequency within block
	and	d
	ld	b,a
	ld	c,e
	
	or	a						; Has it gone past the bottom block boundary?
	ld	hl,283h
	sbc	hl,bc
	jr	c,.CheckTopBoundary				; If not, branch
	ld	hl,-57Bh					; If so, shift down a block
	add	hl,de
	jr	.UpdateFrequency

; --------------------------------------------------------------------------------

.CheckTopBoundary:
	or	a						; Has it gone past the top block boundary?
	ld	hl,508h
	sbc	hl,bc
	jr	nc,.NoBoundaryCross				; If not, branch
	ld	hl,57Ch						; If so, shift up a block
	add	hl,de
	ex	de,hl

.NoBoundaryCross:
	ex	de,hl

.UpdateFrequency:
	bit	TRACK_PORTAMENTO,(ix+track.flags)		; Is portamento enabled?
	ret	z						; If not, exit
	
	ld	(ix+track.frequency+1),h			; Update frequency
	ld	(ix+track.frequency),l
	ret
	
; ------------------------------------------------------------------------------
; Read envelope data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Envelope data index
;	hl - Pointer to envelope data
; RETURNS:
;	a  - Read data
; ------------------------------------------------------------------------------

ReadEnvelopeData:
	ld	b,0						; Read envelope data
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	a,(bc)
	ret
	
; ------------------------------------------------------------------------------
; Get pointer to instrument data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	b  - Instrument ID
;	ix - Pointer to track variables
; RETURNS:
;	hl - Pointer to instrument data
; ------------------------------------------------------------------------------

GetInstrument:
	ld	l,(ix+track.instruments)			; Get instrument data
	ld	h,(ix+track.instruments+1)
	
	xor	a						; Is the instrument ID 0?
	or	b
	jr	z,.End						; If so, branch

	ld	de,19h						; Jump to correct instrument data

.Iterate:
	add	hl,de
	djnz	.Iterate

.End:
	ret

; ------------------------------------------------------------------------------
; Write YM register data for track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYmTrack:
	bit	2,(ix+track.channel)				; Is this track FM part 2?
	jr	nz,WriteYm2Track

	bit	TRACK_MUTE,(ix+track.flags)			; Is this track muted?
	ret	nz						; If so, exit
	add	a,(ix+track.channel)				; Add channel ID to register ID

; ------------------------------------------------------------------------------
; Write YM register data (part 1)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
; ------------------------------------------------------------------------------

WriteYm1:
	ld	(YM_ADDR_0),a					; Write register data
	nop
	ld	a,c
	ld	(YM_DATA_0),a
	ret
	
; ------------------------------------------------------------------------------
; Write YM register data for track (part 2)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYm2Track:
	bit	TRACK_MUTE,(ix+track.flags)			; Is sound disabled?
	ret	nz						; If so, exit
	add	a,(ix+track.channel)				; Add channel ID to register ID
	sub	4

; ------------------------------------------------------------------------------
; Write YM register data (part 2)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
; ------------------------------------------------------------------------------

WriteYm2:
	ld	(YM_ADDR_1),a					; Write register data
	nop
	ld	a,c
	ld	(YM_DATA_1),a
	ret

; ------------------------------------------------------------------------------
; Update instrument
; ------------------------------------------------------------------------------
; PARAMETERS:
;	hl - Pointer to instrument data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

UpdateInstrument:
	ld	de,InstrumentRegs				; Instrument registers
	
	ld	c,(ix+track.pan_ams_fms)			; Set panning/AMS/FMS
	ld	a,0B4h
	call	WriteYmTrack

	call	WriteInstrumentReg				; Set feedback/algorithm
	ld	(ix+track.algo_feedback),a
	
	ld	b,14h						; Set rest of the registers

.SetRegisters:
	call	WriteInstrumentReg
	djnz	.SetRegisters

	ld	(ix+track.tl_values),l				; Update volume with new TL data
	ld	(ix+track.tl_values+1),h
	jp	UpdateVolume

; ------------------------------------------------------------------------------
; Write instrument register
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to instrument register ID
;	hl - Pointer to instrument register data
; RETURNS:
;	a  - Written register data
; ------------------------------------------------------------------------------

WriteInstrumentReg:
	ld	a,(de)						; Set instrument register data
	inc	de
	ld	c,(hl)
	inc	hl
	call	WriteYmTrack
	ret
	
; ------------------------------------------------------------------------------
; Play a sound from the queue
; ------------------------------------------------------------------------------

PlaySoundId:
	ld	a,(z_sound_play)				; Get sound pulled from the queue
	bit	7,a						; Is it a sound ID?
	jp	z,StopSound					; If not, stop all sound
	
	cp	FM_END+1					; Is it a sound effect?
	jp	c,PlaySfx					; If so, branch
	
	jp	StopSound					; Stop all sound

; --------------------------------------------------------------------------------
; Initial track data
; --------------------------------------------------------------------------------

TrackInitData:
	db	80h, 0						; FM1
	db	80h, 1						; FM2
	db	80h, 2						; FM3
	db	80h, 4						; FM4
	db	80h, 5						; FM5
	db	80h, 6						; FM6

; ------------------------------------------------------------------------------
; Play a sound effect
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a - Sound ID
; ------------------------------------------------------------------------------

PlaySfx:
	sub	FM_START					; Make ID zero based
	ret	m						; If it's not a valid sound effect ID, exit

	ld	c,info.sfx_index				; Get sound effect pointer
	rst	8
	rst	18h

	push	hl						; Get instrument table pointer
	rst	20h
	ld	(instrument_table),hl
	xor	a						; Clear end flag
	ld	(end_flag),a
	pop	hl

	push	hl						; Get tick multiplier
	pop	iy
	ld	a,(iy+2)
	ld	(tick_multiply),a
	ld	de,4						; Skip past header
	add	hl,de
	ld	b,(iy+3)					; Get number of tracks

.InitTracks:
	push	bc						; Save track counter
	
	push	hl						; Get track variables pointer
	inc	hl
	ld	c,(hl)
	call	GetSfxTrack
	push	ix
	pop	de
	pop	hl

	ldi							; Copy flags
	ld	a,(de)						; Get channel ID
	cp	2						; Is it FM3?
	call	z,DisableSpecialFm3				; If so, disable special FM3 mode
	ldi							; Copy channel ID
	ld	a,(tick_multiply)				; Set tick multiplier
	ld	(de),a
	inc	de
	ldi							; Copy track data pointer
	ldi
	ldi							; Copy transposition value
	ldi							; Copy volume value

	call	FinishTrackInit					; Finish track initialization

	push	hl						; Set instrument table pointer
	ld	hl,(instrument_table)
	ld	(ix+track.instruments),l
	ld	(ix+track.instruments+1),h
	call	SetKeyOff					; Set key off
	call	DisableSsgEg					; Disable SSG-EG
	pop	hl
	
	pop	bc						; Loop until all tracks are initialized
	djnz	.InitTracks

ResetSoundQueue:
	ld	a,80h						; Clear sound play queue
	ld	(z_sound_play),a
	ret

; ------------------------------------------------------------------------------
; Get sound effect track variables pointer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Channel ID
; RETURNS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

GetSfxTrack:
	ld	a,c						; Get channel ID
	bit	2,a						; Is it a YM part 2 channel?
	jr	z,.GetPtr					; If not, branch
	dec	a						; Make ID linear

.GetPtr:
	ld	(channel_id),a					; Get track variables pointer
	push	af
	ld	hl,SfxTracks
	rst	18h
	push	hl
	pop	ix
	pop	af
	ret

; ------------------------------------------------------------------------------
; Finish track initialization
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track variables after volume
; RETURNS:
;	de - Advanced track variables pointer
; ------------------------------------------------------------------------------

FinishTrackInit:
	ex	af,af'
	xor	a						; Reset vibrato mode
	ld	(de),a
	inc	de
	ld	(de),a						; Reset instrument ID
	inc	de
	ex	af,af'

	ex	de,hl						; Set call stack pointer
	ld	(hl),track.call_stack_base
	inc	hl
	ld	(hl),0C0h					; Set panning/AMS/FMS
	inc	hl
	ld	(hl),1						; Set duration counter to 1

	ld	b,TRACK_CLEAR_SIZE				; Clear rest of the track

.ClearTrack:
	inc	hl
	ld	(hl),0
	djnz	.ClearTrack

	inc	hl
	ex	de,hl
	ret

; --------------------------------------------------------------------------------
; Sound effect track variables pointers
; --------------------------------------------------------------------------------

SfxTracks:
	dw	fm1_track					; FM1
	dw	fm2_track					; FM2
	dw	fm3_track					; FM3
	dw	fm4_track					; FM4
	dw	fm5_track					; FM5
	dw	fm6_track					; FM6

; ------------------------------------------------------------------------------
; Stop all sound
; ------------------------------------------------------------------------------

StopSound:
	ld	hl,z_sound_play					; Clear driver variables
	ld	de,z_sound_play+1
	ld	bc,VARIABLES_CLEAR_SIZE-1
	ld	(hl),0
	ldir

	; BUG: SilenceTrack and DisableSsgEg expect ix to be a pointer
	; to a track's variables. TrackInitData also doesn't get properly used.
	; As a result, this function does not work properly.
	ld	ix,TrackInitData				; Initial track data
	ld	b,TRACK_COUNT					; Number of tracks

.StopTracks:
	push	bc						; Save track counter
	call	SilenceTrack					; Silence track
	call	DisableSsgEg					; Disable SSG-EG

	inc	ix						; Next track
	inc	ix
	pop	bc
	djnz	.StopTracks					; Loop until all tracks are stopped
	
	ld	b,7						; Reset fading
	xor	a
	ld	(fade_flag),a

; ------------------------------------------------------------------------------
; Disable special FM3 mode
; ------------------------------------------------------------------------------

DisableSpecialFm3:
	ld	a,0Fh						; Disable special FM3 mode
	ld	(ym_reg_27),a
	ld	c,a
	ld	a,27h
	call	WriteYm1
	
	jp	ResetSoundQueue					; Reset sound queue

; ------------------------------------------------------------------------------
; Disable SSG-EG
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

DisableSsgEg:
	ld	a,90h						; Disable SSG-EG
	ld	c,0
	jp	WriteYm4Op

; ------------------------------------------------------------------------------
; Process sound queue
; ------------------------------------------------------------------------------

ProcessSoundQueue:
	ld	a,r						; Store value of the R register
	ld	(r_value),a

	ld	de,z_sound_queue				; Process sound queue 1
	call	.ProcessSlot
	call	.ProcessSlot					; Process sound queue 2
	; Fall through to process sound queue 3

; ------------------------------------------------------------------------------

.ProcessSlot:
	ld	a,(de)						; Read from queue
	bit	7,a						; Is a sound ID written in it?
	ret	z						; If not, exit
	sub	FM_START					; Is it a valid sound effect ID?
	ret	c						; If not, exit
	
	ld	c,info.sfx_priorities				; Get sound priority
	rst	8
	ld	c,a
	ld	b,0
	add	hl,bc

	ld	a,(cur_priority)				; Get current sound priority
	cp	(hl)						; Is this sound's priority greater?
	jr	z,.SetSound					; If so, branch
	jr	nc,.ClearSlot					; If not, branch

.SetSound:
	ld	a,(de)						; Override sound play queue
	ld	(z_sound_play),a
	ld	a,(hl)						; Set new priority
	and	7Fh
	ld	(cur_priority),a

.ClearSlot:
	xor	a						; Clear queue slot
	ld	(de),a
	inc	de						; Next queue slot
	ret

; ------------------------------------------------------------------------------
; Silence track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SilenceTrack:
	call	SetMaxReleaseRate				; Maximize release rate
	ld	a,40h						; Silence channel
	ld	c,7Fh
	call	WriteYm4Op

	ld	c,(ix+track.channel)				; Set key off
	jp	ForceKeyOff

; ------------------------------------------------------------------------------
; Maximize release rate
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SetMaxReleaseRate:
	ld	a,80h						; Set max release rate
	ld	c,0FFh

; ------------------------------------------------------------------------------
; Write a value to all 4 operators for a register
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Base register ID
;	c  - Register data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYm4Op:
	ld	b,4						; Number of operators

.Write:
	push	af						; Write operator register data
	call	WriteYmTrack
	pop	af
	add	a,4						; Next operator
	djnz	.Write						; Loop until operator registers are set
	ret
	
; --------------------------------------------------------------------------------
; Instrument registers
; --------------------------------------------------------------------------------

InstrumentRegs:
	db	0B0h						; Feedback/Algorithm
	db	30h, 38h, 34h, 3Ch				; Detune/Multiply
	db	50h, 58h, 54h, 5Ch				; Rate scale/Attack rate
	db	60h, 68h, 64h, 6Ch				; AMS enable/Decay rate
	db	70h, 78h, 74h, 7Ch				; Sustain rate
	db	80h, 88h, 84h, 8Ch				; Sustain level/Release rate
InstrumentRegsTl:
	db	40h, 48h, 44h, 4Ch				; Total level
InstrumentRegsSsgEg:
	db	90h, 98h, 94h, 9Ch				; SSG-EG

; --------------------------------------------------------------------------------
; Special FM3 frequency registers
; --------------------------------------------------------------------------------

SpecialFm3Regs:
	db	0ADh, 0AEh, 0ACh, 0A6h				; FM3 frequency
	
; --------------------------------------------------------------------------------
; Frequency table
; --------------------------------------------------------------------------------
	
FrequencyTable:
	;	C     C#/Db D     D#/Eb E     F     F#/Gb G     G#/Ab A     A#/Bb B
	dw	284h, 2ABh, 2D3h, 2FEh, 32Dh, 35Ch, 38Fh, 3C5h, 3FFh, 43Ch, 47Ch, 4C0h
	
; ------------------------------------------------------------------------------
; Process track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Track command ID
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

TrackCommand:
	ld	hl,.Done					; Set return address
	push	hl

	sub	0E0h						; Process track command
	ld	hl,.Commands
	rst	18h
	ld	a,(de)
	jp	(hl)

.Done:
	inc	de						; Parse next track command
	jp	ParseTrackCommand

; --------------------------------------------------------------------------------

.Commands:
	dw	PanCommand					; Set panning
	dw	PortaSpeedCommand				; Set detune
	dw	CommunicationCommand				; Set communication flag
	dw	SilenceCommand					; Silence track
	dw	StopCommand					; Stop
	dw	LoopEndCommand					; End loop
	dw	VolumeCommand					; Add volume
	dw	LegatoCommand					; Set legato
	dw	StaccatoCommand					; Set staccato
	dw	LfoCommand					; Set LFO
	dw	StopCommand					; Stop
	dw	ConditionalJumpCommand				; Conditional jump
	dw	ResetRingCommand				; Reset ring channel
	dw	WriteYmCommand					; Write YM register data for track
	dw	WriteYm1Command					; Write YM register data (part 1)
	dw	InstrumentCommand				; Set instrument
	dw	VibratoCommand					; Set vibrato
	dw	DisableVibratoCommand				; Disable vibrato
	dw	StopCommand					; Stop
	dw	SwapRingCommand					; Swap ring channel
	dw	StopCommand					; Stop
	dw	StopCommand					; Stop
	dw	JumpCommand					; Jump
	dw	LoopCommand					; Loop
	dw	CallCommand					; Call
	dw	ReturnCommand					; Return
	dw	TickMultiplyCommand				; Set track tick multiplier
	dw	TransposeCommand				; Transpose
	dw	PortamentoCommand				; Set portamento
	dw	RawFrequencyCommand				; Set raw frequency mode
	dw	Fm3DetuneCommand				; Set FM3 detune mode
	dw	.FFxx						; FFxx
	
.CommandsFFxx:
	dw	StopCommand					; Stop
	dw	TempoCommand					; Set tempo
	dw	PlaySoundCommand				; Play sound
	dw	StopCommand					; Stop
	dw	CopyDataCommand					; Copy data
	dw	StopCommand					; Stop
	dw	SsgEgCommand					; Set SSG-EG

; ------------------------------------------------------------------------------
; Process FFxx track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

.FFxx:
	ld	hl,.CommandsFFxx				; Process track command
	rst	18h
	inc	de
	ld	a,(de)
	jp	(hl)

; ------------------------------------------------------------------------------
; Tempo track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Tempo value
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

TempoCommand:
	ld	hl,tempo					; Set tempo
	ld	(hl),a
	dec	hl
	ld	(hl),a
	ret

; ------------------------------------------------------------------------------
; Sound play track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Sound ID
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

PlaySoundCommand:
	ld	hl,z_sound_play					; Play sound
	ld	(hl),a
	ret

; ------------------------------------------------------------------------------
; Data copy track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

CopyDataCommand:
	ex	de,hl						; Get destination address
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl

	ld	c,(hl)						; Get count
	ld	b,0
	inc	hl
	ex	de,hl

	ldir							; Copy data
	dec	de
	ret

; ------------------------------------------------------------------------------
; Conditional jump track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

ConditionalJumpCommand:
	ld	a,(jump_condition)				; Get jump condition
	or	a						; Should we jump?
	jp	z,JumpCommand					; If so, branch
	inc	de						; If not, skip
	ret

; ------------------------------------------------------------------------------
; Ring channel reset track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

ResetRingCommand:
	ld	a,80h						; Reset ring channel
	ld	(ring_channel),a
	ret

; ------------------------------------------------------------------------------
; SSG-EG track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SsgEgCommand:
	ld	(ix+track.ssg_eg_mode),80h			; Enable SSG-EG
	ld	(ix+track.ssg_eg_params),e			; Set parameters pointer
	ld	(ix+track.ssg_eg_params+1),d

	ld	hl,InstrumentRegsSsgEg				; Set SSG-EG register data
	ld	b,4

.SetRegs:
	ld	a,(de)
	inc	de
	ld	c,a
	ld	a,(hl)
	inc	hl
	call	WriteYmTrack
	djnz	.SetRegs
	dec	de
	ret

; ------------------------------------------------------------------------------
; Portamento speed track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Portamento speed
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

PortaSpeedCommand:
	ld	(ix+track.porta_speed),a			; Set portamento speed
	ret

; ------------------------------------------------------------------------------
; Communication flag track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Communication flag
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

CommunicationCommand:
	ld	(communication_flag),a				; Set communication flag
	ret

; ------------------------------------------------------------------------------
; Silence track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SilenceCommand:
	call	SilenceTrack					; Silence track
	jp	StopCommand					; Stop track

; ------------------------------------------------------------------------------
; Staccato track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Staccato duration
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

StaccatoCommand:
	call	CalcDuration					; Set staccato time
	ld	(ix+track.staccato_timer),a
	ld	(ix+track.staccato),a
	ret

; ------------------------------------------------------------------------------
; Track YM register data write track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYmCommand:
	call	GetYmWriteData					; Get register data
	call	WriteYmTrack					; Write it
	ret

; ------------------------------------------------------------------------------
; YM register data write (part 1) track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYm1Command:
	call	GetYmWriteData					; Get register data
	call	WriteYm1					; Write it
	ret

; ------------------------------------------------------------------------------
; Get YM register data to write
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
; RETURNS:
;	a  - Register ID
;	c  - Register data
;	de - Advanced track data pointer
; ------------------------------------------------------------------------------

GetYmWriteData:
	ex	de,hl						; Get write data
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	ex	de,hl
	ret

; ------------------------------------------------------------------------------
; Vibrato track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

VibratoCommand:
	ld	(ix+track.vibrato_params),e			; Set parameters pointer
	ld	(ix+track.vibrato_params+1),d
	ld	(ix+track.vibrato_mode),80h			; Enable vibrato
	inc	de
	inc	de
	inc	de
	ret

; ------------------------------------------------------------------------------
; Vibrato disable track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

DisableVibratoCommand:
	res	7,(ix+track.vibrato_mode)			; Disable vibrato
	dec	de
	ret

; ------------------------------------------------------------------------------
; Legato track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

LegatoCommand:
	set	TRACK_LEGATO,(ix+track.flags)			; Set legato
	dec	de
	ret

; ------------------------------------------------------------------------------
; FM3 detune mode track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

Fm3DetuneCommand:
	ld	a,(ix+track.channel)				; Is this FM3?
	cp	2
	jr	nz,.NotFM3					; If not, branch

	set	TRACK_FM3_DETUNE,(ix+track.flags)		; Set FM3 detune mode

	exx							; Set operator detune values
	ld	de,fm3_detune_op1
	ld	b,4

.SetDetune:
	push	bc
	exx
	ld	a,(de)
	inc	de
	exx
	ld	hl,.DetuneVals
	add	a,a
	ld	c,a
	ld	b,0
	add	hl,bc
	ldi
	ldi
	pop	bc
	djnz	.SetDetune
	exx

	dec	de						; Enable FM3 special mode
	ld	a,4Fh
	ld	(ym_reg_27),a
	ld	c,a
	ld	a,27h
	call	WriteYm1
	ret

.NotFM3:
	inc	de						; If this is not FM3, skip this command
	inc	de
	inc	de
	ret

; --------------------------------------------------------------------------------

.DetuneVals:
	dw	0
	dw	132h
	dw	18Eh
	dw	1E4h
	dw	234h
	dw	27Eh
	dw	2C2h
	dw	2F0h

; ------------------------------------------------------------------------------
; Instrument track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

InstrumentCommand:
	call	SetMaxReleaseRate				; Maximize release rate

	ld	a,(de)						; Set new instrument
	ld	(ix+track.instrument),a
	push	de
	ld	b,a
	call	GetInstrument
	call	UpdateInstrument
	pop	de
	ret

; ------------------------------------------------------------------------------
; Panning track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

PanCommand:
	ld	c,3Fh						; Set panning

; ------------------------------------------------------------------------------
; Update panning/AMS/FMS
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Bits to mask out from old register data
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

UpdatePanAmsFms:
	ld	a,(ix+track.pan_ams_fms)			; Mask out bits
	and	c
	ex	de,hl
	or	(hl)						; Combine new bits from track data

	ld	(ix+track.pan_ams_fms),a			; Write new register data
	ld	c,a
	ld	a,0B4h
	call	WriteYmTrack
	ex	de,hl
	ret

; ------------------------------------------------------------------------------
; LFO track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - LFO value
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

LfoCommand:
	ld	c,a						; Set new LFO value
	ld	a,22h
	call	WriteYm1

	inc	de						; Set new AMS/FMS
	ld	c,0C0h
	jr	UpdatePanAmsFms

; ------------------------------------------------------------------------------
; Volume track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Volume add value
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

VolumeCommand:
	add	a,(ix+track.volume)				; Add volume
	ld	(ix+track.volume),a

; ------------------------------------------------------------------------------
; Update volume
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

UpdateVolume:
	exx							; Get TL register data
	ld	de,InstrumentRegsTl
	ld	l,(ix+track.tl_values)
	ld	h,(ix+track.tl_values+1)
	ld	b,4

.SetRegs:
	ld	a,(hl)						; Get register
	or	a						; Is this a slot operator?
	jp	p,.SetTL					; If not, branch
	add	a,(ix+track.volume)				; If so, add volume to it

.SetTL:
	and	7Fh						; Write new TL data
	ld	c,a
	ld	a,(de)
	call	WriteYmTrack
	
	inc	de						; Next operator
	inc	hl
	djnz	.SetRegs					; Loop until all registers are set
	exx
	ret

; ------------------------------------------------------------------------------
; Transpose track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Transposition
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

TransposeCommand:
	add	a,(ix+track.transpose)				; Transpose
	ld	(ix+track.transpose),a
	ret

; ------------------------------------------------------------------------------
; Track tick multiplier track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Tick multiplier
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

TickMultiplyCommand:
	ld	(ix+track.tick_multiply),a			; Set new tick multiplier
	ret

; ------------------------------------------------------------------------------
; Jump track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

JumpCommand:
	ex	de,hl						; Jump to new data address
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	de
	ret

; ------------------------------------------------------------------------------
; Portamento track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Enable flag
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

PortamentoCommand:
	cp	1						; Is portamento being enabled?
	jr	nz,.Disable					; If not, branch
	set	TRACK_PORTAMENTO,(ix+track.flags)		; Enable portamento
	ret

.Disable:
	res	TRACK_LEGATO,(ix+track.flags)			; Clear legato flag
	res	TRACK_PORTAMENTO,(ix+track.flags)		; Disable portamento
	xor	a						; Clear portamento speed
	ld	(ix+track.porta_speed),a
	ret

; ------------------------------------------------------------------------------
; Raw frequency mode command
; ------------------------------------------------------------------------------

RawFrequencyCommand:
	cp	1						; Is raw frequency mode being enabled?
	jr	nz,.Disable					; If not, branch
	set	TRACK_RAW_FREQ,(ix+track.flags)			; Enable raw frequency mode
	ret

.Disable:
	res	TRACK_RAW_FREQ,(ix+track.flags)			; Disable raw frequency mode
	ret

; ------------------------------------------------------------------------------
; Stop track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

StopCommand:
	res	TRACK_PLAY,(ix+track.flags)			; Stop playing track
	ld	a,1Fh						; Set end flag
	ld	(end_flag),a
	
	ld	c,(ix+track.channel)				; Set key off
	call	ForceKeyOff
	
	xor	a						; Clear sound priority
	ld	(cur_priority),a

	pop	hl						; Skip immediately to next track
	pop	hl
	ret

; ------------------------------------------------------------------------------
; Ring channel swap track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

SwapRingCommand:
	ld	a,(ring_channel)				; Get current ring channel
	or	a						; Is it left?
	jr	z,.SetRight					; If so, branch

.SetLeft:
	xor	a						; Switch to left channel
	ld	(ring_channel),a
	ld	a,FM_RING_LEFT					; Play left channel ring SFX
	ld	(z_sound_queue),a
	dec	de
	ret

.SetRight:
	ld	a,80h						; Switch to right channel
	ld	(ring_channel),a
	dec	de
	ret

; ------------------------------------------------------------------------------
; Call track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Low byte of call address
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

CallCommand:
	ld	c,a						; Get call address
	inc	de
	ld	a,(de)
	ld	b,a

	push	bc						; Push return address to call stack
	push	ix
	pop	hl
	dec	(ix+track.call_stack_addr)
	ld	c,(ix+track.call_stack_addr)
	dec	(ix+track.call_stack_addr)
	ld	b,0
	add	hl,bc
	ld	(hl),d
	dec	hl
	ld	(hl),e

	pop	de						; Jump to call address
	dec	de
	ret

; ------------------------------------------------------------------------------
; Return track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

ReturnCommand:
	push	ix						; Pop return address from call stack
	pop	hl
	ld	c,(ix+track.call_stack_addr)
	ld	b,0
	add	hl,bc
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	(ix+track.call_stack_addr)
	inc	(ix+track.call_stack_addr)
	ret

; ------------------------------------------------------------------------------
; Loop track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

LoopCommand:
	inc	de						; Get loop index
	add	a,track.loop_counters
	ld	c,a
	ld	b,0
	push	ix
	pop	hl
	add	hl,bc

	ld	a,(hl)						; Is the loop count already set?
	or	a
	jr	nz,.CheckLoop					; If so, branch
	ld	a,(de)						; Set loop count
	ld	(hl),a

.CheckLoop:
	inc	de						; Decrement loop count
	dec	(hl)
	jp	nz,JumpCommand					; If it hasn't run out, branch
	inc	de						; If it has, skip past loop address
	ret

; ------------------------------------------------------------------------------
; Loop end track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

LoopEndCommand:
	inc	de						; Get loop index
	add	a,track.loop_counters
	ld	c,a
	ld	b,0
	push	ix
	pop	hl
	add	hl,bc

	ld	a,(hl)						; Decrement loop count
	dec	a
	jp	z,.Jump						; If it's running out, branch
	inc	de						; If not, just continue as normal
	ret

.Jump:
	xor	a						; Clear loop count
	ld	(hl),a
	jp	JumpCommand					; Jump
	
; ------------------------------------------------------------------------------
