; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Driver info
; ------------------------------------------------------------------------------

	xdef DriverInfo
DriverInfo:
	dc.l	SongPriorities					; Song priority table
	dc.l	*
	dc.l	SongIndex					; Song index
	dc.l	SfxIndex					; SFX index
	dc.l	*
	dc.l	*
	dc.l	PCM_SFX_START					; First SFX ID
	dc.l	PcmDriverOrigin					; Origin
	dc.l	SfxPriorities					; SFX priority table
	dc.l	CmdPriorities					; Command priority table

; ------------------------------------------------------------------------------
