; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Render clouds
; ------------------------------------------------------------------------------

	xdef RenderClouds
RenderClouds:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	move.b	#1,MCD_MAIN_COMM_2				; Tell Sub CPU to render clouds

.WaitSubCpu:
	cmpi.b	#1,MCD_SUB_COMM_2				; Has the Sub CPU responded?
	beq.s	.CommDone					; If so, branch
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.WaitSubCpu					; If we should wait some more, loop

.CommDone:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	move.b	#0,MCD_MAIN_COMM_2				; Respond to the Sub CPU

.WaitSubCpu2:
	tst.b	MCD_SUB_COMM_2					; Has the Sub CPU responded?
	beq.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.WaitSubCpu2					; If we should wait some more, loop

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts
	
; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; ------------------------------------------------------------------------------

	xdef WaitSubCpuStart
WaitSubCpuStart:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program started?
	bne.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitSubCpuStart					; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; ------------------------------------------------------------------------------

	xdef WaitSubCpuInit
WaitSubCpuInit:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program initialized?
	beq.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitSubCpuInit					; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.Done						; If so, branch
	
	btst	#1,MCD_MEM_MODE					; Does the Sub CPU already have Word RAM Access?
	bne.s	.End						; If so, branch
	bset	#1,MCD_MEM_MODE					; Give Sub CPU Word RAM access

.Wait:
	btst	#1,MCD_MEM_MODE					; Has it been given?
	bne.s	.Done						; If so, branch
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.Wait						; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.Done:
	clr.l	sub_wait_time					; Reset Sub CPU wait time

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch

	btst	#0,MCD_MEM_MODE					; Do we have Word RAM access?
	bne.s	.End						; If so, branch

	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitWordRamAccess				; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
