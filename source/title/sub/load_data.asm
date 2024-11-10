; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Load clouds data
; ------------------------------------------------------------------------------

	xdef LoadCloudData
LoadCloudData:
	lea	CloudStamps(pc),a0				; Load stamp art
	lea	WORD_RAM_2M+$200,a1
	bsr.w	DecompressKosinski
	
	lea	CloudStampMap(pc),a0				; Load stamp map
	lea	WORD_RAM_2M+CLOUD_STAMP_MAP,a1
	bsr.w	DecompressKosinski
	rts

; ------------------------------------------------------------------------------
