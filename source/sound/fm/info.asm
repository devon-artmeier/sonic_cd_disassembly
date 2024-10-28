; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"regions.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Driver info
; ------------------------------------------------------------------------------

	xdef DriverInfo
DriverInfo:
	dw	SfxPriorities					; Sound effect priority table
	dw	0
	dw	SongIndex					; Song index
	dw	SfxIndex					; SFX index
	dw	0
	dw	0
	dw	FM_START					; First SFX ID
	dw	0
	dw	variables					; Variables
	dw	0
	
; ------------------------------------------------------------------------------
