; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Update Sub CPU
; ------------------------------------------------------------------------------

	xdef UpdateSubCpu
UpdateSubCpu:
	move.w	#1,MCD_MAIN_COMM_2				; Tell Sub CPU program to update
	
.WaitSubCpu:
	tst.w	MCD_SUB_COMM_2					; Has the Sub CPU responded?
	beq.s	.WaitSubCpu					; If not, wait
	
	nop
	nop
	nop
	
	move.w	#0,MCD_MAIN_COMM_2				; Respond to the Sub CPU

.WaitSubCpu2:
	tst.w	MCD_SUB_COMM_2					; Has the Sub CPU responded?
	bne.s	.WaitSubCpu2					; If not, wait
	rts
	

; ------------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	btst	#1,MCD_MEM_MODE					; Does the Sub CPU already have Word RAM Access?
	bne.s	.End						; If so, branch
	
.Wait:
	bset	#1,MCD_MEM_MODE					; Give Sub CPU Word RAM access
	btst	#1,MCD_MEM_MODE					; Has it been given?
	beq.s	.Wait						; If not, wait

.End:
	rts
	

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	btst	#0,MCD_MEM_MODE					; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; ------------------------------------------------------------------------------

	xdef WaitSubCpuStart
WaitSubCpuStart:
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program started?
	beq.s	WaitSubCpuStart					; If not, wait
	rts 

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; ------------------------------------------------------------------------------

	xdef WaitSubCpuInit
WaitSubCpuInit:
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program initialized?
	bne.s	WaitSubCpuInit					; If not, wait
	rts

; ------------------------------------------------------------------------------
