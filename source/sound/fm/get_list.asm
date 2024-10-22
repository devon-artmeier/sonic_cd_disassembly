; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code_rst_08

; ------------------------------------------------------------------------------
; Get list from driver info table
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Table index
; RETURNS:
;	hl - Pointer to list
; ------------------------------------------------------------------------------

	xdef GetList
GetList:
	ld	hl,DriverInfo					; Get pointer to entry
	ld	b,0
	add	hl,bc
	ex	af,af'						; Read pointer
	rst	20h
	ex	af,af'
	ret
	
; ------------------------------------------------------------------------------
