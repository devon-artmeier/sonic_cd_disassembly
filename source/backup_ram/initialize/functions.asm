; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Unused function to send a Backup RAM command to the Sub CPU
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

	xdef SubBuramCommand
SubBuramCommand:
	move.w	#1,MCD_MAIN_COMM_2				; Send command

.WaitSubCpu:
	tst.w	MCD_SUB_COMM_2					; Has the Sub CPU acknowledged it?
	beq.s	.WaitSubCpu
	
	move.w	#0,MCD_MAIN_COMM_2				; Tell Sub CPU we are ready to send more commands

.WaitSubCpu2:
	tst.w	MCD_SUB_COMM_2					; Is the Sub CPU ready for more commands?
	bne.s	.WaitSubCpu2					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	bset	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Give Sub CPU Word RAM access
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
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
; Initialize Mega Drive hardware
; ------------------------------------------------------------------------------

	xdef InitMegaDrive
InitMegaDrive:
	lea	VdpRegisters(pc),a0				; Set up VDP registers
	move.w	#$8000,d0
	moveq	#$13-1,d7

.SetVdpRegisters:
	move.b	(a0)+,d0
	move.w	d0,VDP_CTRL
	addi.w	#$100,d0
	dbf	d7,.SetVdpRegisters

	moveq	#$40,d0						; Set up controller ports
	move.b	d0,IO_CTRL_1
	move.b	d0,IO_CTRL_2
	move.b	d0,IO_CTRL_3
	move.b	#$C0,IO_DATA_1

	bsr.w	StopZ80						; Stop the Z80
	vramFill 0,$10000,0					; Clear VRAM

	vdpCmd move.l,$C000,VRAM,WRITE,VDP_CTRL			; Clear Plane A
	move.w	#$1000/2-1,d7

.ClearPlaneA:
	move.w	#0,VDP_DATA
	dbf	d7,.ClearPlaneA

	vdpCmd move.l,$E000,VRAM,WRITE,VDP_CTRL			; Clear Plane B
	move.w	#$1000/2-1,d7

.ClearPlaneB:
	move.w	#0,VDP_DATA
	dbf	d7,.ClearPlaneB

	vdpCmd move.l,0,CRAM,WRITE,VDP_CTRL			; Load palette
	lea	Palette(pc),a0
	moveq	#(PaletteEnd-Palette)/4-1,d7

.LoadPalette:
	move.l	(a0)+,VDP_DATA
	dbf	d7,.LoadPalette

	vdpCmd move.l,0,VSRAM,WRITE,VDP_CTRL			; Clear VSRAM
	moveq	#$50/4-1,d0

.ClearVsram:
	move.w	#0,VDP_DATA
	move.w	#0,VDP_DATA
	dbf	d0,.ClearVsram

	bsr.w	StartZ80					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
	rts

; ------------------------------------------------------------------------------

Palette:
	incbin	"source/backup_ram/initialize/data/palette.pal"
PaletteEnd:
	even

VdpRegisters:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$E000/$2000					; Plane B location
	dc.b	$BC00/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; Background color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-BLANK interrupt counter 0
	dc.b	%00000110					; Scroll by tile
	dc.b	%10000001					; H40
	dc.b	$D000/$400					; Horizontal scroll table lcation
	dc.b	0						; Reserved
	dc.b	2						; Auto increment by 2
	dc.b	%00000001					; 64x32 tile plane size
	dc.b	0						; Window horizontal position 0
	dc.b	0						; Window vertical position 0
	even

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

	xdef StopZ80
StopZ80:
	move	sr,saved_sr					; Save status register
	getZ80Bus						; Get Z80 bus access
	rts

; ------------------------------------------------------------------------------
; Start the Z80
; ------------------------------------------------------------------------------

	xdef StartZ80
StartZ80:
	releaseZ80Bus						; Release Z80 bus
	move	saved_sr,sr					; Restore status register
	rts

; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

	xdef ReadController
ReadController:
	lea	ctrl_data,a0					; Controller data buffer
	lea	IO_DATA_1,a1					; Controller port 1
	
	move.b	#0,(a1)						; TH = 0
	tst.w	(a0)						; Delay
	move.b	(a1),d0						; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)					; TH = 1
	tst.w	(a0)						; Delay
	move.b	(a1),d1						; Read B, C, and D-pad buttons
	andi.b	#$3F,d1

	or.b	d1,d0						; Combine button data
	not.b	d0						; Flip bits
	move.b	d0,d1						; Make copy

	move.b	(a0),d2						; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a0)+					; Store pressed buttons
	and.b	d1,d0						; Store tapped buttons
	move.b	d0,(a0)+
	rts

; ------------------------------------------------------------------------------
; Initialize the Z80
; ------------------------------------------------------------------------------

	xdef InitZ80
InitZ80:
	resetZ80Off						; Set Z80 reset off
	jsr	StopZ80(pc)					; Stop the Z80

	lea	Z80_RAM,a1					; Load dummy Z80 code
	move.b	#$F3,(a1)+					; DI
	move.b	#$F3,(a1)+					; DI
	move.b	#$C3,(a1)+					; JP $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+

	resetZ80On						; Set Z80 reset on
	resetZ80Off						; Set Z80 reset off
	jmp	StartZ80(pc)					; Start the Z80
	rts

; ------------------------------------------------------------------------------
; Play an FM sound in queue 2
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; ------------------------------------------------------------------------------

	xdef PlaySound
PlaySound:
	move.b	d0,fm_queue_1					; Play sound
	rts

; ------------------------------------------------------------------------------
; Play an FM sound in queue 3
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - FM sound ID
; ------------------------------------------------------------------------------

	xdef PlaySound2
PlaySound2:
	move.b	d0,fm_queue_2					; Play sound
	rts

; ------------------------------------------------------------------------------
; Flush the sound queue
; ------------------------------------------------------------------------------

	xdef FlushSoundQueue
FlushSoundQueue:
	jsr	StopZ80						; Stop the Z80

.CheckQueue2:
	tst.b	fm_queue_1					; Is the 1st sound queue set?
	beq.s	.CheckQueue3					; If not, branch
	
	move.b	fm_queue_1,z_fm_sound_play			; Queue sound in driver
	move.b	#0,fm_queue_1					; Clear 1st sound queue
	bra.s	.End						; Exit

.CheckQueue3:
	tst.b	fm_queue_2					; Is the 2nd sound queue set?
	beq.s	.End						; If not, branch
	
	move.b	fm_queue_2,z_fm_sound_play			; Queue sound in driver
	move.b	#0,fm_queue_2					; Clear 2nd sound queue

.End:
	jmp	StartZ80					; Start the Z80

; ------------------------------------------------------------------------------
; Mass fill
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Fill128
Fill128:
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	rts

; ------------------------------------------------------------------------------
; Mass fill (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; ------------------------------------------------------------------------------

	xdef Fill128Vdp
Fill128Vdp:
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
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
; Mass copy (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; ------------------------------------------------------------------------------

	xdef Copy128Vdp
Copy128Vdp:
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	rts

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	move.b	#1,vsync_flag					; Set VSync flag
	move	#$2500,sr					; Enable interrupts

.Wait:
	tst.b	vsync_flag					; Has the V-BLANK handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Set all buttons
; ------------------------------------------------------------------------------

	xdef SetAllButtons
SetAllButtons:
	move.w	#$FF00,ctrl_data				; Press down all buttons
	rts

; ------------------------------------------------------------------------------
; Random number generator
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; ------------------------------------------------------------------------------

	xdef Random
Random:
	move.l	d1,-(sp)					; Save registers
	move.l	rng_seed,d1					; Get RNG seed
	bne.s	.GetRandom					; If it's set, branch
	move.l	#$2A6D365A,d1					; If not, initialize it

.GetRandom:
	move.l	d1,d0						; Perform various operations
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1

	move.l	d1,rng_seed					; Update RNG seed
	move.l	(sp)+,d1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Run Backup Backup RAM cartridge command
; ------------------------------------------------------------------------------

	xdef CartBuramCommand
CartBuramCommand:
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
	dc.w	InitCartBuram-.Commands	
	dc.w	GetCartBuramStatus-.Commands
	dc.w	SearchCartBuram-.Commands
	dc.w	ReadCartBuram-.Commands	
	dc.w	WriteCartBuram-.Commands
	dc.w	DeleteCartBuram-.Commands
	dc.w	FormatCartBuram-.Commands
	dc.w	GetCartBuramDirectory-.Commands
	dc.w	VerifyCartBuram-.Commands
	; Missing save data read command
	; Missing save data write command
.CommandsEnd:

; ------------------------------------------------------------------------------
; Initialize cartridge Backup RAM interaction
; ------------------------------------------------------------------------------

InitCartBuram:
	lea	CartBuramScratch,a0				; Initialize Backup RAM
	lea	CartBuramStrings,a1
	moveq	#BRMINIT,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get cartridge Backup RAM status	
; ------------------------------------------------------------------------------

GetCartBuramStatus:
	moveq	#BRMSTAT,d0					; Get Backup RAM status
	movea.l	#CartBuramStrings,a1
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Search cartridge Backup RAM
; ------------------------------------------------------------------------------

SearchCartBuram:
	movea.l	#buram_params,a0				; Search Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMSERCH,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Read from cartridge Backup RAM
; ------------------------------------------------------------------------------

ReadCartBuram:
	movea.l	#buram_params,a0				; Read Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data,a1
	moveq	#BRMREAD,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Write to cartridge Backup RAM
; ------------------------------------------------------------------------------

WriteCartBuram:
	movea.l	#buram_params,a0				; Write Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMWRITE,d0
	jsr	_BURAM
	rts

; ------------------------------------------------------------------------------
; Delete cartridge Backup RAM
; ------------------------------------------------------------------------------

DeleteCartBuram:
	movea.l	#buram_params,a0				; Delete Backup RAM
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	moveq	#BRMDEL,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Format cartridge Backup RAM
; ------------------------------------------------------------------------------

FormatCartBuram:
	moveq	#BRMFORMAT,d0					; Format Backup RAM
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Get cartridge Backup RAM directory
; ------------------------------------------------------------------------------

GetCartBuramDirectory:
	movea.l	#buram_params,a0				; Get Backup RAM directory
	move.b	#0,buram_param.misc(a0)
	move.l	#0,buram_param.misc+1(a0)
	movea.l	#buram_data+4,a1
	move.l	buram_data,d1
	moveq	#BRMDIR,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Verify cartridge Backup RAM
; ------------------------------------------------------------------------------

VerifyCartBuram:
	movea.l	#buram_params,a0				; Verify Backup RAM
	move.b	buram_write_flag,buram_param.flag(a0)
	move.w	buram_block_size,buram_param.block_size(a0)
	movea.l	#buram_data,a1
	moveq	#BRMVERIFY,d0
	jmp	_BURAM

; ------------------------------------------------------------------------------
; Backup RAM data
; ------------------------------------------------------------------------------

CartBuramScratch:
	dcb.b	$640*2, 0					; Cartridge scratch RAM

CartBuramStrings:	
	dcb.b	$C, 0						; Cartridge display strings

	include	"../initial_data.asm"				; Initial data

; ------------------------------------------------------------------------------
; Get type of Backup RAM to use
; ------------------------------------------------------------------------------

	xdef GetBuramType
GetBuramType:
	bsr.w	CheckBuramCartridge				; Check if a Backup RAM cartridge was found
	bne.s	.SetType					; If so, branch
	clr.b	d0						; Use internal Backup RAM

.SetType:
	move.b	d0,buram_type					; Set type
	rts

; ------------------------------------------------------------------------------
; Check which kind of Backup RAM is being used
; ------------------------------------------------------------------------------

	xdef CheckBuramType
CheckBuramType:
	tst.b	buram_type					; Check Backup RAM type
	rts

; ------------------------------------------------------------------------------
; Check if a Backup RAM cartridge was found
; ------------------------------------------------------------------------------

	xdef CheckBuramCartridge
CheckBuramCartridge:
	tst.b	buram_cart_found				; Check if RAM cartride was found
	rts

; ------------------------------------------------------------------------------
; Initialize and read save data
; ------------------------------------------------------------------------------

	xdef InitReadSaveData
InitReadSaveData:
	bsr.w	InitBuram					; Initialize Backup RAM interaction
	bsr.w	InitBuramParams					; Set up parameters
	bsr.w	CallReadSaveData				; Read save data
	rts

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

	xdef CallWriteSaveData
CallWriteSaveData:
	bra.w	WriteSaveData					; Write save data

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

	xdef CallReadSaveData
CallReadSaveData:
	bra.w	ReadSaveData					; Read save data

; ------------------------------------------------------------------------------
; Initialize save data
; ------------------------------------------------------------------------------

	xdef InitSaveData
InitSaveData:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	
	lea	SaveDataTimeAttack,a0				; Setup time attack save data
	lea	buram_data,a1
	move.w	#save.attack_struct_size/4-1,d0

.SetupTimeAttackData:
	move.l	(a0)+,(a1)+
	dbf	d0,.SetupTimeAttackData

	lea	SaveDataMain,a0					; Setup main save data
	lea	buram_data+save.attack_struct_size,a1
	move.w	#save.main_struct_size/4-1,d0

.SetupMainData:
	move.l	(a0)+,(a1)+
	dbf	d0,.SetupMainData

	move.b	#0,buram_write_flag				; Set Backup RAM write flag
	move.w	#$B,buram_block_size				; Set Backup RAM block size
	rts

; ------------------------------------------------------------------------------
; Initialize Backup RAM parameters
; ------------------------------------------------------------------------------

	xdef InitBuramParams
InitBuramParams:
	move.b	#0,buram_write_flag				; Set Backup RAM write flag
	move.w	#$B,buram_block_size				; Set Backup RAM block size
	
	lea	.FileName,a0					; Set file name
	bra.s	SetBuramFileName

.FileName:
	dc.b	"SONICCD____"
	even

; ------------------------------------------------------------------------------
; Set Backup RAM file name
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

	xdef SetBuramFileName
SetBuramFileName:
	movem.l	a0-a1,-(sp)					; Save registers
	movea.l	#buram_params,a1				; Copy file name
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	movem.l	(sp)+,a0-a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Run Backup RAM command
; ------------------------------------------------------------------------------

	xdef RunBuramCommand
RunBuramCommand:
	bsr.w	CheckBuramType					; Check which type of Backup RAM we are using
	bne.s	.BuramCart					; If we are using a Backup RAM cartridge, branch
	
	move.b	save_disabled,buram_disabled			; Copy save disabled flag
	jsr	GiveWordRamAccess				; Run the command
	jsr	WaitWordRamAccess				; Wait for the command to finish
	bra.s	.CheckStatus

.BuramCart:
	bsr.w	CartBuramCommand				; Run Backup RAM cartridge command

.CheckStatus:
	tst.b	buram_status					; Check status
	rts

; ------------------------------------------------------------------------------
; Initialize Backup RAM interaction
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.w - Status
;	        0 = Using Backup RAM cartridge
;	        1 = Using internal Backup RAM
;	       -1 = Internal Backup RAM unformatted
;	       -2 = Backup RAM cartridge unformatted
; ------------------------------------------------------------------------------

	xdef InitBuram
InitBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	
	bsr.w	DetectBuramCartridge				; Detect Backup RAM cartridge
	bne.w	.NoBuramCart					; If there is no Backup RAM cartridge, branch
	
	move.b	#BURAM_TYPE_CART,buram_type			; Set Backup RAM type to Backup RAM cartridge
	move.b	#BURAM_CMD_INIT,buram_command			; Initialize Backup RAM interaction
	bsr.s	RunBuramCommand
	
	tst.b	buram_status					; Was it a success?
	beq.s	.FoundBuramCart					; If so, branch
	tst.w	buram_d1					; Is the Backup RAM cartridge unformatted?
	bne.s	.CartUnformatted				; If so, branch

.NoBuramCart:
	move.b	#0,buram_cart_found				; Backup RAM cartridge not found
	bra.s	.InitInternal					; Initialize internal Backup RAM interaction

.FoundBuramCart:
	bsr.w	GetBuramStatus					; Get Backup RAM status
	move.b	#1,buram_cart_found				; Backup RAM cartridge found

.InitInternal:
	move.b	#BURAM_TYPE_INTERNAL,buram_type			; Set Backup RAM type to internal
	move.b	#BURAM_CMD_INIT,buram_command			; Initialize Backup RAM interaction
	bsr.w	RunBuramCommand
	
	tst.b	buram_status					; Was it a success?
	bne.s	.Unformatted					; If not, branch
	bsr.w	GetBuramStatus					; Get Backup RAM status
	
	tst.b	buram_cart_found				; Was a Backup RAM cartridge found?
	beq.s	.NoBuramCart2					; If not, branch
	move.w	#0,d0						; Using Backup RAM cartridge
	rts

.NoBuramCart2:
	move.w	#1,d0						; Using internal Backup RAM
	move.w	#0,d1
	rts

.Unformatted:
	move.w	#-1,d0						; Internal Backup RAM unformatted
	rts

.CartUnformatted:
	move.w	#-2,d0						; Backup RAM cartridge unformatted
	rts

; ------------------------------------------------------------------------------
; Detect Backup RAM cartridge
; ------------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Found/Not found
;	d0.l  - Status
;	         0 = Found
;	        -1 = Not found
; ------------------------------------------------------------------------------

	xdef DetectBuramCartridge
DetectBuramCartridge:
	btst	#7,RAM_CART_ID					; Is there a special Backup RAM cartridge?
	beq.s	.NormalBuramCart				; If not, branch

	lea	SPECIAL_CART_ID,a0				; Check special cartridge
	lea	.RamSignature,a1
	moveq	#12/4-1,d0

.CheckSpecialCart:
	cmpm.l	(a0)+,(a1)+					; Is the signature present?
	bne.s	.NormalBuramCart				; If not, branch
	dbf	d0,.CheckSpecialCart				; Loop until finished

	movea.l	#_BURAM,a0					; Run special cart entry code
	jsr	SPECIAL_CART_START
	bra.w	.Found						; Mark as found

.NormalBuramCart:
	btst	#7,RAM_CART_ID					; Were we just checking for special Backup RAM cartridge data?
	bne.w	.NotFound					; If so, branch

	move.b	RAM_CART_ID,d0					; Get size of cartridge data
	andi.l	#7,d0
	move.l	#$2000,d1
	lsl.l	d0,d1
	lsl.l	#1,d1						; Data is stored every other byte

	lea	RAM_CART_DATA-($40*2)-1,a2			; Go to end of cartridge data
	adda.l	d1,a2
	
	movea.l	a2,a0						; Check normal Backup RAM cartridge
	adda.w	#$30*2,a0
	lea	.RamSignature,a1

	movep.l	1(a0),d1					; Is the signature present?
	cmp.l	(a1),d1
	bne.w	.NoSignature					; If not, branch
	
	movep.l	1+(4*2)(a0),d1					; Is the signature present?
	cmp.l	4(a1),d1
	bne.w	.NoSignature					; If not, branch
	
	movep.l	1+(8*2)(a0),d1					; Is the signature present?
	cmp.l	8(a1),d1
	bne.w	.NoSignature					; If not, branch

	movea.l	a2,a0						; Check format signature
	adda.w	#$20*2,a0
	lea	.FormatSig,a1

	movep.l	1(a0),d1					; Is the signature present?
	cmp.l	(a1),d1
	bne.w	.NoSignature					; If it's not present, branch

	movep.l	1+(4*2)(a0),d1					; Is the signature present?
	cmp.l	4(a1),d1
	bne.w	.NoSignature					; If it's not present, branch

	movep.l	1+(8*2)(a0),d1					; Is the signature present?
	cmp.l	8(a1),d1
	bne.w	.NoSignature					; If it's not present, branch
	
	bra.w	.Found						; Mark as found

.NoSignature:
	bset	#0,RAM_CART_PROTECT				; Enable writing
	lea	RAM_CART_DATA,a0				; Backup RAM cartridge data
	move.b	(a0),d0						; Save first byte
	
	move.b	#$5A,(a0)					; Write random value
	cmpi.b	#$5A,(a0)					; Was it written?
	bne.s	.WriteFailed					; If not, branch
	
	move.b	#$A5,(a0)					; Write another random value
	cmpi.b	#$A5,(a0)					; Was it written?
	bne.s	.WriteFailed					; If not, branch

	move.b	d0,(a0)						; Restore first byte
	bclr	#0,RAM_CART_PROTECT				; Disable writing
	bra.s	.Found2						; Mark as found

.WriteFailed:
	bclr	#0,RAM_CART_PROTECT				; Disable writing
	bra.s	.NotFound					; Mark as not found

.Found:
	moveq	#0,d0						; Mark as found
	rts

.Found2:
	moveq	#0,d0						; Mark as found
	rts

.NotFound:
	moveq	#-1,d0						; Mark as not found
	rts

; ------------------------------------------------------------------------------

.RamSignature:
	dc.b	"RAM_CARTRIDG"
	even

.FormatSig:
	dc.b	"SEGA_CD_ROM"
	even

; ------------------------------------------------------------------------------
; Get Backup RAM directory
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - H: Number of files to skip when all files can't be read
;	          read in one try
;	       L: Size of directory buffer
; ------------------------------------------------------------------------------

	xdef GetBuramDirectory
GetBuramDirectory:
	move.l	d0,-(sp)					; Wait for Word RAM access
	jsr	WaitWordRamAccess
	move.l	(sp)+,d0

	move.l	d0,buram_data					; Set parameters
	lea	.Template,a0					; Set template file name
	bsr.w	SetBuramFileName

	move.b	#BURAM_CMD_DIRECTORY,buram_command		; Get directory
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------

.Template:
	dc.b	"***********"
	even

; ------------------------------------------------------------------------------
; Get Backup RAM status
; ------------------------------------------------------------------------------

	xdef GetBuramStatus
GetBuramStatus:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_STATUS,buram_command			; Get Backup RAM status
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Search Backup RAM
; ------------------------------------------------------------------------------

	xdef SearchBuram
SearchBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_SEARCH,buram_command			; Get Backup RAM status
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Read Backup RAM
; ------------------------------------------------------------------------------

	xdef ReadBuram
ReadBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_READ,buram_command			; Read Backup RAM data
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

	xdef ReadSaveData
ReadSaveData:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_READ_SAVE,buram_command		; Read save data
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Write Backup RAM
; ------------------------------------------------------------------------------

	xdef WriteBuram
WriteBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_WRITE,buram_command			; Write Backup RAM data
	bsr.w	RunBuramCommand
	bne.s	.End						; If it failed, branch
	bsr.w	VerifyBuram					; Verify Backup RAM

.End:
	rts

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

	xdef WriteSaveData
WriteSaveData:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_WRITE_SAVE,buram_command		; Write save data
	bsr.w	RunBuramCommand
	rts

; ------------------------------------------------------------------------------
; Delete Backup RAM
; ------------------------------------------------------------------------------

	xdef DeleteBuram
DeleteBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_DELETE,buram_command			; Delete Backup RAM
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Format Backup RAM
; ------------------------------------------------------------------------------

	xdef FormatBuram
FormatBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_FORMAT,buram_command			; Format Backup RAM
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Verify Backup RAM
; ------------------------------------------------------------------------------

	xdef VerifyBuram
VerifyBuram:
	jsr	WaitWordRamAccess				; Wait for Word RAM access
	move.b	#BURAM_CMD_VERIFY,buram_command			; Verify Backup RAM
	bra.w	RunBuramCommand

; ------------------------------------------------------------------------------
; Load message art
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Message art ID queue
; ------------------------------------------------------------------------------

	xdef LoadMessageArt
LoadMessageArt:
	lea	VDP_CTRL,a5					; VDP control port
	moveq	#4-1,d2						; Number of IDs to check

.QueueLoop:
	moveq	#0,d1						; Get ID from queue
	move.b	d0,d1
	beq.s	.Next						; If it's blank, branch

	lsl.w	#3,d1						; Get art metadata
	lea	.MessageArt(pc),a0

	move.l	-8(a0,d1.w),(a5)				; VDP command
	movea.l	-4(a0,d1.w),a0					; Art data
	jsr	DecompressNemesisVdp(pc)			; Decompress and load art

.Next:
	ror.l	#8,d0						; Shift queue
	dbf	d2,.QueueLoop					; Loop until queue is scanned
	rts

; ------------------------------------------------------------------------------

.MessageArt:
	vdpCmd dc.l,$20,VRAM,WRITE				; Eggman art
	dc.l	EggmanArt
	vdpCmd dc.l,$340,VRAM,WRITE				; Message art
	dc.l	MessageArt
	;if REGION=USA
		vdpCmd dc.l,$1C40,VRAM,WRITE			; Message art (extension)
		dc.l	MessageUsaArt
	;endif

; ------------------------------------------------------------------------------
; Advance data bitstream
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Branch to take if no new byte is needed (optional)
; ------------------------------------------------------------------------------

advanceBitstream macro
	cmpi.w	#9,d6						; Does a new byte need to be read?
	ifgt \#							; If not, branch
		bcc.s	\1
	else
		bcc.s	.NoNewByte\@
	endif
	
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte\@:
	endm

; ------------------------------------------------------------------------------
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; ------------------------------------------------------------------------------

	xdef DecompressNemesisVdp
DecompressNemesisVdp:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRowVdp,a3				; Write all data to the same location
	lea	VDP_DATA,a4					; VDP data port
	bra.s	DecompressNemesisMain

; ------------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; ------------------------------------------------------------------------------

	xdef DecompressNemesis
DecompressNemesis:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRow,a3				; Advance to the next location after each write

; ------------------------------------------------------------------------------

DecompressNemesisMain:
	lea	nem_code_table,a1				; Prepare decompression buffer
	
	move.w	(a0)+,d2					; Get number of tiles
	lsl.w	#1,d2						; Should we use XOR mode?
	bcc.s	.GetRows					; If not, branch
	adda.w	#WriteNemesisRowVdpXor-WriteNemesisRowVdp,a3	; Use XOR mode

.GetRows:
	lsl.w	#2,d2						; Get number of rows
	movea.w	d2,a5
	moveq	#8,d3						; 8 pixels per row
	moveq	#0,d2						; XOR row buffer
	moveq	#0,d4						; Row buffer
	
	jsr	BuildNemesisCodeTable(pc)			; Build code table
	
	move.b	(a0)+,d5					; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6						; Set bitstream read data position
	
	bsr.s	GetNemesisCode					; Decompress data
	
	nop
	nop
	nop
	nop
	
	movem.l	(sp)+,d0-a1/a3-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

GetNemesisCode:
	move.w	d6,d7						; Peek 8 bits from bitstream
	subq.w	#8,d7
	move.w	d5,d1
	lsr.w	d7,d1
	cmpi.b	#%11111100,d1					; Should we read inline data?
	bcc.s	ReadInlineNemesisData				; If so, branch
	
	andi.w	#$FF,d1						; Get code length
	add.w	d1,d1
	move.b	(a1,d1.w),d0
	ext.w	d0
	
	sub.w	d0,d6						; Advance bitstream read data position
	advanceBitstream

	move.b	1(a1,d1.w),d1					; Get palette index
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$F0,d0						; Get repeat count

GetNemesisCodeLength:
	lsr.w	#4,d0						; Isolate repeat count

WriteNemesisPixel:
	lsl.l	#4,d4						; Shift up by a nibble
	or.b	d1,d4						; Write pixel
	subq.w	#1,d3						; Has an entire 8-pixel row been written?
	bne.s	NextNemesisPixel				; If not, loop
	jmp	(a3)						; Otherwise, write the row to its destination

; ------------------------------------------------------------------------------

ResetNemesisRow:
	moveq	#0,d4						; Reset row
	moveq	#8,d3						; Reset nibble counter

NextNemesisPixel:
	dbf	d0,WriteNemesisPixel				; Loop until finished
	bra.s	GetNemesisCode					; Read next code

; ------------------------------------------------------------------------------

ReadInlineNemesisData:
	subq.w	#6,d6						; Advance bitstream read data position
	advanceBitstream

	subq.w	#7,d6						; Read inline data
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1						; Get palette index
	andi.w	#$70,d0						; Get repeat count
	
	advanceBitstream GetNemesisCodeLength			; Advance bitstream read data position
	bra.s	GetNemesisCodeLength

; ------------------------------------------------------------------------------

WriteNemesisRowVdp:
	move.l	d4,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowVdpXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRow:
	move.l	d4,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

BuildNemesisCodeTable:
	move.b	(a0)+,d0					; Read first byte

.CheckEnd:
	cmpi.b	#$FF,d0						; Has the end of the code table been reached?
	bne.s	.NewPaletteIndex				; If not, branch
	rts

.NewPaletteIndex:
	move.w	d0,d7						; Set palette index

.Loop:
	move.b	(a0)+,d0					; Read next byte
	cmpi.b	#$80,d0						; Should we set a new palette index?
	bcc.s	.CheckEnd					; If so, branch

	move.b	d0,d1						; Copy repeat count
	andi.w	#$F,d7						; Get palette index
	andi.w	#$70,d1						; Get repeat count
	or.w	d1,d7						; Combine them
	
	andi.w	#$F,d0						; Get code length
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7						; Combine with palette index and repeat count
	
	moveq	#8,d1						; Is the code length 8 bits in size?
	sub.w	d0,d1
	bne.s	.ShortCode					; If not, branch
	
	move.b	(a0)+,d0					; Store code entry
	add.w	d0,d0
	move.w	d7,(a1,d0.w)
	bra.s	.Loop

.ShortCode:
	move.b	(a0)+,d0					; Get index
	lsl.w	d1,d0
	add.w	d0,d0
	
	moveq	#1,d5						; Get number of entries
	lsl.w	d1,d5
	subq.w	#1,d5

.ShortCode_Loop:
	move.w	d7,(a1,d0.w)					; Store code entry
	addq.w	#2,d0						; Increment index
	dbf	d5,.ShortCode_Loop				; Loop until finished
	bra.s	.Loop

; ------------------------------------------------------------------------------
; Draw message tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Tilemap ID
; ------------------------------------------------------------------------------

	xdef DrawMessageTilemap
DrawMessageTilemap:
	andi.l	#$FFFF,d0					; Get mappings metadata
	mulu.w	#14,d0
	lea	.Tilemaps,a1
	adda.w	d0,a1

	movea.l	(a1)+,a0					; Mappings data
	move.w	(a1)+,d0					; Base tile attributes

	move.l	a1,-(sp)					; Decompress mappings
	lea	decomp_buffer,a1
	bsr.w	DecompressEnigma
	movea.l	(sp)+,a1

	move.w	(a1)+,d3					; Width
	move.w	(a1)+,d2					; Height
	move.l	(a1),d0						; VDP command
	
	lea	decomp_buffer,a0				; Load mappings into VRAM
	movea.l	#VDP_DATA,a1					; VDP data port

.Row:
	move.l	d0,VDP_CTRL					; Set VDP command
	move.w	d3,d1						; Get width

.Tile:
	move.w	(a0)+,(a1)					; Copy tile
	dbf	d1,.Tile					; Loop until row is copied
	addi.l	#$800000,d0					; Next row
	dbf	d2,.Row						; Loop until map is copied
	rts

; ------------------------------------------------------------------------------

.Tilemaps:
	; Backup RAM data corrupted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	dc.l	DataCorruptTilemap
	dc.w	$201A
	;if REGION=JAPAN
	;	dc.w	$24-1, 6-1
	;	vdpCmd dc.l,$E584,VRAM,WRITE
	;else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	;endif
	
	; Internal Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	;if REGION=JAPAN
	;	dc.l	UnformattedTilemap
	;	dc.w	$201A
	;	dc.w	$24-1, 6-1
	;	vdpCmd dc.l,$E584,VRAM,WRITE
	;elseif REGION=USA
		dc.l	UnformattedUsaTilemap
		dc.w	$20E2
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	;else
	;	dc.l	UnformattedTilemap
	;	dc.w	$201A
	;	dc.w	$1D-1, 6-1
	;	vdpCmd dc.l,$E58A,VRAM,WRITE
	;endif
	
	; Cartridge Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	;if REGION=JAPAN
	;	vdpCmd dc.l,$C21E,VRAM,WRITE
	;else
		vdpCmd dc.l,$C29E,VRAM,WRITE
	;endif

	dc.l	CartUnformattedTilemap
	dc.w	$201A
	;if REGION=JAPAN
	;	dc.w	$24-1, $A-1
	;	vdpCmd dc.l,$E484,VRAM,WRITE
	;else
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E50A,VRAM,WRITE
	;endif
	
	; Backup RAM full
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	;if REGION=JAPAN
	;	vdpCmd dc.l,$C29E,VRAM,WRITE
	;else
		vdpCmd dc.l,$C31E,VRAM,WRITE
	;endif

	dc.l	BuramFullTilemap
	dc.w	$201A
	;if REGION=JAPAN
	;	dc.w	$24-1, 8-1
	;	vdpCmd dc.l,$E504,VRAM,WRITE
	;else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	;endif

; ------------------------------------------------------------------------------
; Decompress Enigma tilemap data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Enigma data
;	a1.l - Pointer to destination buffer
;	d0.w - Base tile attributes
; ------------------------------------------------------------------------------

	xdef DecompressEnigma
DecompressEnigma:
	movem.l	d0-d7/a1-a5,-(sp)				; Save registers
	
	movea.w	d0,a3						; Get base tile
	
	move.b	(a0)+,d0					; Get size of inline copy value
	ext.w	d0
	movea.w	d0,a5

	move.b	(a0)+,d4					; Get tile flags
	lsl.b	#3,d4

	movea.w	(a0)+,a2					; Get incremental copy word
	adda.w	a3,a2
	
	movea.w	(a0)+,a4					; Get static copy word
	adda.w	a3,a4

	move.b	(a0)+,d5					; Get read first word
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#16,d6						; Initial shift value

GetEnigmaCode:
	moveq	#7,d0						; Assume a code entry is 7 bits
	move.w	d6,d7
	sub.w	d0,d7
	
	move.w	d5,d1						; Get code entry
	lsr.w	d7,d1
	andi.w	#$7F,d1
	move.w	d1,d2

	cmpi.w	#$40,d1						; Is this code entry actually 6 bits long?
	bcc.s	.GotCode					; If not, branch
	
	moveq	#6,d0						; Code entry is actually 6 bits
	lsr.w	#1,d2

.GotCode:
	bsr.w	AdvanceEnigmaBitstream				; Advance bitstream
	
	andi.w	#$F,d2						; Handle code
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	HandleEnigmaCode(pc,d1.w)

; ------------------------------------------------------------------------------

EnigmaCopyInc:
	move.w	a2,(a1)+					; Copy incremental copy word
	addq.w	#1,a2						; Increment it
	dbf	d2,EnigmaCopyInc				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyStatic:
	move.w	a4,(a1)+					; Copy static copy word
	dbf	d2,EnigmaCopyStatic				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInline:
	bsr.w	ReadInlineEnigmaData				; Read inline data	

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineInc:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	addq.w	#1,d1						; Increment it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineDec:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	subq.w	#1,d1						; Decrement it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineMult:
	cmpi.w	#$F,d2						; Are we done?
	beq.s	EnigmaDone					; If so, branch

.Loop4:
	bsr.w	ReadInlineEnigmaData				; Read inline data
	move.w	d1,(a1)+					; Copy it
	dbf	d2,.Loop4					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

HandleEnigmaCode:
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyInline
	bra.s	EnigmaCopyInlineInc
	bra.s	EnigmaCopyInlineDec
	bra.s	EnigmaCopyInlineMult

; ------------------------------------------------------------------------------

EnigmaDone:
	subq.w	#1,a0						; Go back by one byte
	cmpi.w	#16,d6						; Were we going to start a completely new byte?
	bne.s	.NotNewByte					; If not, branch
	subq.w	#1,a0						; Go back another

.NotNewByte:
	move.w	a0,d0						; Are we on an odd byte?
	lsr.w	#1,d0
	bcc.s	.Even						; If not, branch
	addq.w	#1,a0						; Ensure we're on an even byte

.Even:
	movem.l	(sp)+,d0-d7/a1-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

ReadInlineEnigmaData:
	move.w	a3,d3						; Copy base tile
	move.b	d4,d1						; Copy tile flags
	
	add.b	d1,d1						; Is the priority bit set?
	bcc.s	.NoPriority					; If not, branch
	
	subq.w	#1,d6						; Is the priority bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPriority					; If not, branch
	
	ori.w	#$8000,d3					; Set priority bit in the base tile

.NoPriority:
	add.b	d1,d1						; Is the high palette line bit set?
	bcc.s	.NoPal1						; If not, branch
	
	subq.w	#1,d6						; Is the high palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal1						; If not, branch
	
	addi.w	#$4000,d3					; Set high palette bit

.NoPal1:
	add.b	d1,d1						; Is the low palette line bit set?
	bcc.s	.NoPal0						; If not, branch
	
	subq.w	#1,d6						; Is the low palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal0						; If not, branch
	
	addi.w	#$2000,d3					; Set low palette bit

.NoPal0:
	add.b	d1,d1						; Is the Y flip bit set?
	bcc.s	.NoYFlip					; If not, branch
	
	subq.w	#1,d6						; Is the Y flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoYFlip					; If not, branch
	
	ori.w	#$1000,d3					; Set Y flip bit

.NoYFlip:
	add.b	d1,d1						; Is the X flip bit set?
	bcc.s	.NoXFlip					; If not, branch
	
	subq.w	#1,d6						; Is the X flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoXFlip					; If not, branch
	
	ori.w	#$800,d3					; Set X flip bit

.NoXFlip:
	move.w	d5,d1						; Prepare to advance bitstream to tile ID
	move.w	d6,d7
	sub.w	a5,d7
	bcc.s	.GotEnoughBits					; If we don't need a new word, branch
	
	move.w	d7,d6						; Make space for the rest of the tile ID
	addi.w	#16,d6
	neg.w	d7
	lsl.w	d7,d1
	
	move.b	(a0),d5						; Add in the rest of the tile ID
	rol.b	d7,d5
	add.w	d7,d7
	and.w	EnigmaInlineMasks-2(pc,d7.w),d5
	add.w	d5,d1

.CombineBits:
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1

	add.w	d3,d1						; Add base tile
	
	move.b	(a0)+,d5					; Read another word from the bitstream
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts

.GotEnoughBits:
	beq.s	.JustEnough					; If the word has been exactly exhausted, branch
	
	lsr.w	d7,d1						; Shift tile data down
	
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1	
	
	add.w	d3,d1						; Add base tile

	move.w	a5,d0						; Advance bitstream
	bra.s	AdvanceEnigmaBitstream

.JustEnough:
	moveq	#16,d6						; Reset shift value
	bra.s	.CombineBits

; ------------------------------------------------------------------------------

EnigmaInlineMasks:
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w	%0011111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

; ------------------------------------------------------------------------------

AdvanceEnigmaBitstream:
	sub.w	d0,d6						; Advance bitstream
	advanceBitstream
	rts

; ------------------------------------------------------------------------------
