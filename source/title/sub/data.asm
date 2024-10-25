; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"../common.inc"
	include	"variables.inc"

	section data

; ------------------------------------------------------------------------------
; Clouds data
; ------------------------------------------------------------------------------

	xdef CloudStamps
CloudStamps:
	incbin	"../data/cloud_stamps.kos"
	even

	xdef CloudStampMap
CloudStampMap:
	incbin	"../data/cloud_stamp_map.kos"
	even

; ------------------------------------------------------------------------------
