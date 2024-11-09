; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.l	#GraphicsIrq,_LEVEL1+2				; Set graphics interrupt handler
	move.l	#MegaDriveIrq,_USERCALL2+2			; Set Mega Drive interrupt handler
	move.b	#0,MCD_MEM_MODE					; Set to 2M mode

	moveq	#0,d0						; Clear communication registers
	move.w	d0,MCD_SUB_COMM_0
	move.b	d0,MCD_SUB_COMM_2
	move.l	d0,MCD_SUB_COMM_4
	move.l	d0,MCD_SUB_COMM_8
	move.l	d0,MCD_SUB_COMM_12

	bset	#7,MCD_SUB_FLAG					; Mark as started
	bclr	#1,MCD_IRQ_MASK					; Disable graphics interrupt
	bclr	#3,MCD_IRQ_MASK					; Disable timer interrupt
	move.b	#3,MCD_CDC_DEVICE				; Set CDC device to "Sub CPU"

	lea	VARIABLES,a0					; Clear variables
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables

	bsr.w	InitCloudRender					; Initialize cloud rendering
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	WORD_RAM_2M,a0					; Clear Word RAM
	move.w	#WORD_RAM_2M_SIZE/8-1,d7

.ClearWordRam:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearWordRam

	lea	WORD_RAM_2M+$30000,a0				; Load unknown data
	move.w	#$8000/4-1,d7

.LoadUnkData:
	move.l	#$01080108,(a0)+
	dbf	d7,.LoadUnkData

	bsr.w	LoadCloudData					; Load cloud data
	bsr.w	InitCloudRenderParams				; Initialize cloud rendering parameters

	bset	#1,MCD_IRQ_MASK					; Enable graphics interrupt
	bclr	#7,MCD_SUB_FLAG					; Mark as initialized

; ------------------------------------------------------------------------------

MainLoop:
	btst	#0,MCD_MAIN_FLAG				; Is the Main CPU finished?
	beq.s	.NotDone					; If not, branch
	bset	#0,MCD_SUB_FLAG					; Respond to the Main CPU

.WaitMainCpuDone:
	btst	#0,MCD_MAIN_FLAG				; Has the Main CPU responded?
	bne.s	.WaitMainCpuDone				; If not, wait
	bclr	#0,MCD_SUB_FLAG					; Communication is done

	move.w	#FDRCHG,d0					; Fade CD audio out
	moveq	#$20,d1
	jsr	_CDBIOS

	moveq	#0,d1
	rts

.NotDone:
	move.b	MCD_MAIN_COMM_2,d0				; Should we run a cloud rendering?
	beq.s	MainLoop					; If not, branch
	move.b	MCD_MAIN_COMM_2,MCD_SUB_COMM_2			; Tell Main CPU we received the tip

.WaitMainCpu:
	tst.b	MCD_MAIN_COMM_2					; Has the Main CPU received our tip?
	bne.s	.WaitMainCpu					; If not, wait
	move.b	#0,MCD_SUB_COMM_2				; Communication is done

	bsr.w	GetCloudRenderSines				; Get sines for cloud rendering
	bsr.w	RenderClouds					; Render clouds
	bsr.w	ControlClouds					; Control the clouds
	bsr.w	WaitCloudsRender				; Wait for cloud rendering to be done
	
	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access
	bra.w	MainLoop					; Loop

; ------------------------------------------------------------------------------
