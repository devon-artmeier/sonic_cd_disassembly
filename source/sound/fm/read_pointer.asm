; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code_rst_18_20
	
; ------------------------------------------------------------------------------
; Read pointer from table
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Table index
;	hl - Pointer to table
; ------------------------------------------------------------------------------

	xdef ReadTablePointer
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

	xdef ReadHlPointer
ReadHlPointer:
	ld	a,(hl)						; Read from HL into HL
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret
	
; ------------------------------------------------------------------------------
