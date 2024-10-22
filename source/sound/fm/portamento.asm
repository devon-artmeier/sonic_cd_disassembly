; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Update portamento
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; RETURNS:
;	hl - Frequency value
; ------------------------------------------------------------------------------

	xdef UpdatePortamento
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
