; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Driver info
; ------------------------------------------------------------------------------

	xdef DriverInfo
DriverInfo:
	dc.l	MusicPriorities					; Music priority table
	dc.l	*
	dc.l	MusicIndex					; Music index
	dc.l	SfxIndex					; SFX index
	dc.l	*
	dc.l	*
	dc.l	PCMS_START					; First SFX ID
	dc.l	PcmDriverOrigin					; Origin
	dc.l	SfxPriorities					; SFX priority table
	dc.l	CmdPriorities					; Command priority table

; ------------------------------------------------------------------------------
