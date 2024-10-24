; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Unknown graphics interrupt handler
; ------------------------------------------------------------------------------

	xdef GraphicsIrq
GraphicsIrq:
	move.b	#0,irq1_flag					; Clear IRQ1 flag
	rte

; ------------------------------------------------------------------------------
; Unknown decompression routine
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to compressed data
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef UnkDecomp
UnkDecomp:
	movem.l	d0-a2,-(sp)					; Save registers

	lea	decomp_window,a2				; Decompression sliding window
	move.w	(a0)+,d7					; Get size of uncompressed data
	subq.w	#1,d7						; Subtract 1 for loop
	move.w	#(-$12)&$FFF,d2					; Set window position
	
	move.b	(a0)+,d1					; Get first description field
	move.w	#$FFF,d6					; Set window position mask
	moveq	#8,d0						; Number of bits in description field

.MainLoop:
	dbf	d0,.NextDescBit					; Loop until all flags have been scanned
	moveq	#8-1,d0						; Prepare next description field
	move.b	(a0)+,d1

.NextDescBit:
	lsr.b	#1,d1						; Get next description field bit
	bcc.s	.CopyFromWindow					; 0 | If we are copying from the window, branch

.CopyNextByte:
	move.b	(a0),(a1)+					; 1 | Copy next byte from archive
	move.b	(a0)+,(a2,d2.w)					; Store in window
	addq.w	#1,d2						; Advance window position
	and.w	d6,d2
	dbf	d7,.MainLoop					; Loop until all of the data is decompressed
	bra.s	.End						; Exit out

.CopyFromWindow:
	moveq	#0,d3
	move.b	(a0)+,d3					; Get low byte of window position
	move.b	(a0)+,d4					; Get high bits of window position and length
	
	move.w	d4,d5						; Combine window position bits
	andi.w	#$F0,d5
	lsl.w	#4,d5
	or.w	d5,d3

	andi.w	#$F,d4						; Isolate length
	addq.w	#3-1,d4						; Copy at least 3 bytes from window

.CopyWindowLoop:
	move.b	(a2,d3.w),d5					; Get byte from window
	move.b	d5,(a1)+					; Store in decompressed data buffer
	subq.w	#1,d7						; Decrement bytes left to decompress
	move.b	d5,(a2,d2.w)					; Store in window
	
	addq.w	#1,d3						; Advance copy position
	and.w	d6,d3
	addq.w	#1,d2						; Advance window position
	and.w	d6,d2

	dbf	d4,.CopyWindowLoop				; Loop until all bytes are copied
	tst.w	d7						; Are there any bytes left to decompress?
	bpl.s	.MainLoop					; If so, branch

.End:
	movem.l	(sp)+,d0-a2					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Mass copy
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Copy128
Copy128:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------
; Wait for the graphics interrupt handler to run
; ------------------------------------------------------------------------------

	xdef WaitGraphicsIrq
WaitGraphicsIrq:
	move.b	#1,irq1_flag					; Set IRQ1 flag
	move	#$2000,sr					; Enable interrupts

.Wait:
	tst.b	irq1_flag					; Has the interrupt handler been run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Sync with Main CPU
; ------------------------------------------------------------------------------

	xdef SyncWithMainCpu
SyncWithMainCpu:
	tst.w	MCD_MAIN_COMM_2					; Are we synced with the Main CPU?
	bne.s	SyncWithMainCpu					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Give Main CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	bset	#MCDR_RET_BIT,MCD_MEM_MODE			; Give Main CPU Word RAM access
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
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
; Load source image map
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
;	d1.w - Width (minus 1)
;	d2.w - Height (minus 1)
; ------------------------------------------------------------------------------

	xdef LoadSourceImageMap
LoadSourceImageMap:
	move.l	#$100,d4					; Stride

.SetupRow:
	movea.l	d0,a2						; Set row pointer
	move.w	d1,d3						; Set row width

.RowLoop:
	move.w	(a1)+,d5					; Get data
	lsl.w	#2,d5
	move.w	d5,(a2)+					; Store it
	dbf	d3,.RowLoop					; Loop until row is written
	add.l	d4,d0						; Next row
	dbf	d2,.SetupRow					; Loop until all data is written
	rts

; ------------------------------------------------------------------------------
; Run Backup RAM command
; ------------------------------------------------------------------------------

	xdef BuramCommand
BuramCommand:
	moveq	#0,d0						; Get command ID
	move.b	buram_command,d0
	beq.s	.End						; If it's zero, branch
	
	subq.w	#1,d0						; Make command ID zero based
	cmpi.w	#(.CommandsEnd-.Commands)/2,d0			; Is it too large?
	bcc.s	.Error						; If so, branch

	add.w	d0,d0						; Run command
	lea	.Commands,a0
	move.w	(a0,d0.w),d0
	moveq	#0,d1
	jsr	(a0,d0.w)
	bcs.s	.Error						; If an error occured, branch

	move.b	#0,buram_status					; Mark as a success
	bra.s	.GetReturnVals

.Error:
	move.b	#-1,buram_status				; Mark as a failure

.GetReturnVals:
	move.w	d0,buram_d0					; Store return values
	move.w	d1,buram_d1
	
	clr.b	buram_command					; Mark command as completed

.End:
	rts

; ------------------------------------------------------------------------------

.Commands:
	dc.w	InitBuram-.Commands
	dc.w	GetBuramStatus-.Commands
	dc.w	CartBuram-.Commands
	dc.w	ReadBuram-.Commands	
	dc.w	WriteBuram-.Commands
	dc.w	DeleteBuram-.Commands
	dc.w	FormatBuram-.Commands
	dc.w	GetBuramDirectory-.Commands
	dc.w	VerifyBuram-.Commands
	dc.w	ReadSaveData-.Commands
	dc.w	WriteSaveData-.Commands
.CommandsEnd:

; ------------------------------------------------------------------------------
; Initialize Backup RAM interaction
; ------------------------------------------------------------------------------

InitBuram:
	lea	BuramScratch,a0					; Initialize Backup RAM
	lea	BuramStrings,a1
	moveq	#BRMINIT,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get Backup RAM status	
; ------------------------------------------------------------------------------

GetBuramStatus:
	moveq	#BRMSTAT,d0					; Get Backup RAM status
	movea.l	#BuramStrings,a1
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Search Backup RAM
; ------------------------------------------------------------------------------

CartBuram:
	movea.l	#buram_params,a0				; Search Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMSERCH,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Read from Backup RAM
; ------------------------------------------------------------------------------

ReadBuram:
	movea.l	#buram_params,a0				; Read Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data,a1
	moveq	#BRMREAD,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

ReadSaveData:
	tst.b	buram_disabled					; Is Backup RAM disabled?
	bne.s	.BuramDisabled					; If so, branch

	bsr.s	ReadBuram					; Read from Backup RAM
	bsr.w	WriteTempSaveData				; Write read data to temporary save data buffer
	
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

.BuramDisabled:
	bsr.w	ReadTempSaveData				; Read from temporary save data buffer
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

; ------------------------------------------------------------------------------
; Write to Backup RAM
; ------------------------------------------------------------------------------

WriteBuram:
	movea.l	#buram_params,a0				; Write Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMWRITE,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

WriteSaveData:
	tst.b	buram_disabled					; Is Backup RAM disabled?
	bne.s	.BuramDisabled					; If so, branch

	bsr.s	WriteBuram					; Write to Backup RAM
	bsr.w	WriteTempSaveData				; Write to temporary save data buffer
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

.BuramDisabled:
	bsr.w	WriteTempSaveData				; Write to temporary save data buffer
	move.w	#0,buram_d0
	move.w	#0,buram_d1
	rts

; ------------------------------------------------------------------------------
; Delete Backup RAM
; ------------------------------------------------------------------------------

DeleteBuram:
	movea.l	#buram_params,a0				; Delete Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMDEL,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Format Backup RAM
; ------------------------------------------------------------------------------

FormatBuram:
	moveq	#BRMFORMAT,d0					; Format Backup RAM
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get Backup RAM directory
; ------------------------------------------------------------------------------

GetBuramDirectory:
	movea.l	#buram_params,a0				; Get Backup RAM directory
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data+4,a1
	move.l	buram_data,d1
	moveq	#BRMDIR,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Verify Backup RAM
; ------------------------------------------------------------------------------

VerifyBuram:
	movea.l	#buram_params,a0				; Verify Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMVERIFY,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Write to temporary save data buffer
; ------------------------------------------------------------------------------

WriteTempSaveData:
	movem.l	d0/a0-a1,-(sp)					; Save registers

	movea.l	#buram_data,a0					; Write to temporary save data buffer
	movea.l	#TempSaveData,a1
	move.w	#save.struct_size/4-1,d0

.Write:
	move.l	(a0)+,(a1)+
	dbf	d0,.Write

	movem.l	(sp)+,d0/a0-a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Read from temporary save data buffer
; ------------------------------------------------------------------------------

ReadTempSaveData:
	movem.l	d0/a0-a1,-(sp)					; Save registers

	movea.l	#TempSaveData,a0				; Read from temporary save data buffer
	movea.l	#buram_data,a1
	move.w	#save.struct_size/4-1,d0

.read:
	move.l	(a0)+,(a1)+
	dbf	d0,.read

	movem.l	(sp)+,d0/a0-a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Backup RAM data
; ------------------------------------------------------------------------------

BuramScratch:
	dcb.b	$640, 0						; Scratch RAM

BuramStrings:	
	dcb.b	$C, 0						; Display strings

; ------------------------------------------------------------------------------
