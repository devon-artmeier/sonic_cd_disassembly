; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"constants.inc"

	section code
	
; ------------------------------------------------------------------------------
; Read envelope data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Envelope data index
;	hl - Pointer to envelope data
; RETURNS:
;	a  - Read data
; ------------------------------------------------------------------------------

	xdef ReadEnvelopeData
ReadEnvelopeData:
	ld	b,0						; Read envelope data
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	a,(bc)
	ret
	
; ------------------------------------------------------------------------------
