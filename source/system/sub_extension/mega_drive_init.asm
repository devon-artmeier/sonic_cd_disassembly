; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"regions.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code

; ------------------------------------------------------------------------------
; Load Mega Drive initialization
; ------------------------------------------------------------------------------

	xdef LoadMegaDriveInit
LoadMegaDriveInit:
	lea	MdInitFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
