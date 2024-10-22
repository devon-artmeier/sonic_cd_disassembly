; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code
	
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

	xdef UpdateDuration
UpdateDuration:
	ld	a,(ix+track.duration_timer)				; Decrement note duration
	dec	a
	ld	(ix+track.duration_timer),a
	ret
	
; ------------------------------------------------------------------------------
