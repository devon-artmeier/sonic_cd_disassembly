; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code_rst_00
	
; ------------------------------------------------------------------------------
; Driver entry point
; ------------------------------------------------------------------------------

DriverStart:
	di							; Disable interrupts
	di
	im	1						; Interrupt mode 1
	
	jr	InitDriver					; Initialize driver
	
; ------------------------------------------------------------------------------
