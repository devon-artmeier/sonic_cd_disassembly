; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"regions.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Update tracks
; ------------------------------------------------------------------------------

	xdef UpdateTracks
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

	xdef ParseTrackData, ParseTrackCommand
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
	jp	nz,.RawFrequencyMode				; If so, branch
	
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

.GetFrequencyBlock:
	ex	af,af'
	sub	e
	jr	c,.GotFrequencyBlock
	ex	af,af'
	add	a,d
	jr	.GetFrequencyBlock

.GotFrequencyBlock:
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

.RawFrequencyMode:
	ld	h,a						; Get raw frequency value
	ld	a,(de)
	inc	de
	ld	l,a
	or	h
	jr	z,.SetRawFrequency				; If it's 0, branch
	
	ld	a,(ix+track.transpose)				; Add transposition value
	ld	b,0
	or	a
	jp	p,.AddRawTranspose
	dec	b

.AddRawTranspose:
	ld	c,a
	add	hl,bc

.SetRawFrequency:
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

	xdef CalcDuration
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
	jr	nz,.UpdateDirection
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

.UpdateDirection:
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

	xdef SetKeyOn
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

	xdef SetKeyOff, ForceKeyOff
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
