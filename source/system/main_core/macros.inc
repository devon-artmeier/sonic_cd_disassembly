; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Stage selection entry
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command ID
;	\3 - Stage ID
;	\4 - Time zone
;	\5 - Good Future flag
; ------------------------------------------------------------------------------

__stage_select_id set 0
selectEntry macro
	xdef \1
	dc.w	\2, \3
	dc.b	\4, \5
	\1:			equ __stage_select_id
	__stage_select_id:	set __stage_select_id+1
	endm

; ------------------------------------------------------------------------------
