; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"constants.inc"
	
	section code
	
; ------------------------------------------------------------------------------
; Initialize vibrato
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef InitVibrato
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

	xdef UpdateVibrato
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
