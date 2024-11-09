; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"regions.inc"
	include	"system.inc"
	include	"backup_ram.inc"

	section data_temp_save

; ------------------------------------------------------------------------------
; Temporary save data area
; ------------------------------------------------------------------------------

	xdef TempSaveData
TempSaveData:
	include	"../../backup_ram/data/initial_data.inc"

; ------------------------------------------------------------------------------
