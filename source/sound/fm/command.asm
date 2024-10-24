; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Process track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Track command ID
;	de - Pointer to track data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef TrackCommand
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

	xdef UpdateVolume
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
