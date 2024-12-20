; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

SpecialStageData	equ $18000				; Special stage data offset
SpecialStageDataCopy	equ $6D00				; Special stage data copy offset

special_stage_id_cmd	equ MCD_MAIN_COMM_3			; Stage ID (for Sub CPU command)
time_stones_cmd		equ MCD_MAIN_COMM_10			; Time stones retrieved (for Sub CPU command)
special_stage_flags	equ MCD_MAIN_COMM_11			; Flags (for Sub CPU command)
special_stage_id	equ MCD_SUB_COMM_3			; Stage ID
special_stage_rings	equ MCD_SUB_COMM_4			; Ring count
special_stage_timer	equ MCD_SUB_COMM_6			; Timer
time_stones_sub		equ MCD_SUB_COMM_10			; Time stones retrieved

; ------------------------------------------------------------------------------
