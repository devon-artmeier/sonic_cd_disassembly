; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"pcm_driver.inc"

	section code

; ------------------------------------------------------------------------------
; Null graphics interrupt
; ------------------------------------------------------------------------------

	xdef NullGraphicsIrq
NullGraphicsIrq:
	rte

; ------------------------------------------------------------------------------
; Run PCM driver (timer interrupt)
; ------------------------------------------------------------------------------

	xdef TimerIrq
TimerIrq:
	bchg	#0,pcm_driver_flags				; Should we run the driver on this interrupt?
	beq.s	.End						; If not, branch

	movem.l	d0-a6,-(sp)					; Run the driver
	jsr	RunPcmDriver
	movem.l	(sp)+,d0-a6

.End:
	rte
	
; ------------------------------------------------------------------------------
; Give Word RAM access to the Main CPU (and finish off command)
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	bset	#MCDR_RET_BIT,MCD_MEM_MODE			; Give Word RAM access to Main CPU
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait

; ------------------------------------------------------------------------------
; Finish off command
; ------------------------------------------------------------------------------

	xdef FinishCommand
FinishCommand:
	move.w	MCD_MAIN_COMM_0,MCD_SUB_COMM_0			; Acknowledge command

.WaitMain:
	move.w	MCD_MAIN_COMM_0,d0				; Is the Main CPU ready?
	bne.s	.WaitMain					; If not, wait
	move.w	MCD_MAIN_COMM_0,d0
	bne.s	.WaitMain					; If not, wait

	move.w	#0,MCD_SUB_COMM_0				; Mark as ready for another command
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
