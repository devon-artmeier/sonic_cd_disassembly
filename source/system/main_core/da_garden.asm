; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; D.A. Garden
; ------------------------------------------------------------------------------

	xdef DaGarden
DaGarden:
	move.w	#SYS_DA_GARDEN,d0				; Run D.A. Garden
	bra.w	RunMmd
	
; ------------------------------------------------------------------------------
