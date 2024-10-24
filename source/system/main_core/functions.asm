; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; Run MMD file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File load command ID
; ------------------------------------------------------------------------------
	
	xdef RunMmd
RunMmd:
	move.l	a0,-(sp)					; Save registers
	move.w	d0,MCD_MAIN_COMM_0				; Set command ID

	lea	work_ram_file,a1				; Clear work RAM file buffer
	moveq	#0,d0
	move.w	#WORK_RAM_FILE_SIZE/16-1,d7

.ClearFileBuffer:
	rept	16/4
		move.l	d0,(a1)+
	endr
	dbf	d7,.ClearFileBuffer

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	move.l	WORD_RAM_2M+mmd.entry,d0			; Get entry address
	beq.w	.End						; If it's not set, exit
	movea.l	d0,a0

	move.l	WORD_RAM_2M+mmd.origin,d0			; Get origin address
	beq.s	.GetHBlank					; If it's not set, branch
	
	movea.l	d0,a2						; Copy file to origin address
	lea	WORD_RAM_2M+mmd.file,a1
	move.w	WORD_RAM_2M+mmd.size,d7

.CopyFile:
	move.l	(a1)+,(a2)+
	dbf	d7,.CopyFile

.GetHBlank:
	move	sr,-(sp)					; Save status register

	move.l	WORD_RAM_2M+mmd.hblank,d0			; Get H-BLANK interrupt address
	beq.s	.GetVBlank					; If it's not set, branch
	move.l	d0,_LEVEL4+2					; Set H-BLANK interrupt address

.GetVBlank:
	move.l	WORD_RAM_2M+mmd.vblank,d0			; Get V-BLANK interrupt address
	beq.s	.CheckFlags					; If it's not set, branch
	move.l	d0,_LEVEL6+2					; Set V-BLANK interrupt address

.CheckFlags:
	btst	#MMD_SUB_BIT,WORD_RAM_2M+mmd.flags		; Should the Sub CPU have Word RAM access?
	beq.s	.NoSubWordRam					; If not, branch
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

.NoSubWordRam:
	move	(sp)+,sr					; Restore status register

.WaitSubCpu:
	move.w	MCD_SUB_COMM_0,d0				; Has the Sub CPU received the command?
	beq.s	.WaitSubCpu					; If not, wait
	cmp.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpu					; If not, wait

	move.w	#0,MCD_MAIN_COMM_0				; Mark as ready to send commands again

.WaitSubCpuDone:
	move.w	MCD_SUB_COMM_0,d0				; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCpuDone					; If not, wait
	move.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpuDone					; If not, wait

	jsr	(a0)						; Run file
	move.b	d0,mmd_return_code				; Set return code

	bsr.w	StopZ80						; Stop FM sound
	move.b	#FM_CMD_STOP,z_fm_sound_queue_1
	bsr.w	StartZ80

	move.b	#0,ipx_vsync					; Clear VSync flag
	move.l	#HBlankIrq,_LEVEL4+2				; Reset H-BLANK interrupt address
	move.l	#VBlankIrq,_LEVEL6+2				; Reset V-BLANK interrupt address
	move.w	#$8134,ipx_vdp_reg_81				; Reset VDP register 1 cache
	
	bset	#0,screen_disabled				; Set screen disable flag
	bsr.w	VSync						; VSync
	
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

.End:
	movea.l	(sp)+,a0					; Restore a0
	rts

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

screen_disabled:
	dc.b	0						; Screen disable flag
	
	xdef mmd_return_code
mmd_return_code:
	dc.b	0						; MMD return code
	
; ------------------------------------------------------------------------------
; V-BLANK interrupt handler
; ------------------------------------------------------------------------------

	xdef VBlankIrq
VBlankIrq:
	bset	#MCDR_IFL2_BIT,MCD_IRQ2				; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipx_vsync					; Clear VSync flag
	bclr	#0,screen_disabled				; Clear screen disable flag
	beq.s	HBlankIrq					; If it wasn't set branch
	
	move.w	#$8134,VDP_CTRL					; If it was set, disable the screen

	xdef HBlankIrq
HBlankIrq:
	rte
	
; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------

	xdef ReadSaveData
ReadSaveData:
	bsr.w	GetBuramData					; Get Backup RAM data

	move.w	buram_zone,saved_stage				; Read save data
	move.b	buram_good_futures,good_future_zones
	move.b	buram_title_flags,title_flags
	move.b	buram_attack_unlock,time_attack_unlock
	move.b	buram_unknown,unknown_buram_var
	move.b	buram_special_stage,current_special_stage
	move.b	buram_time_stones,time_stones

	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	rts

; ------------------------------------------------------------------------------
; Get Backup RAM data
; ------------------------------------------------------------------------------

	xdef GetBuramData
GetBuramData:
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	
	move.w	#SYS_TEMP_READ,d0				; Read temporary save data
	btst	#0,save_disabled				; Is saving to Backup RAM disabled?
	bne.s	.Read						; If so, branch
	move.w	#SYS_BURAM_READ,d0				; Read Backup RAM save data
	
.Read:
	bsr.w	SubCpuCommand					; Run command
	bra.w	WaitWordRamAccess				; Wait for Word RAM access

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

	xdef WriteSaveData
WriteSaveData:
	bsr.s	GetBuramData					; Get Backup RAM data

	move.w	saved_stage,buram_zone				; Write save data
	move.b	good_future_zones,buram_good_futures
	move.b	title_flags,buram_title_flags
	move.b	time_attack_unlock,buram_attack_unlock
	move.b	unknown_buram_var,buram_unknown
	move.b	current_special_stage,buram_special_stage
	move.b	time_stones,buram_time_stones

	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM access

	move.w	#SYS_TEMP_WRITE,d0				; Write temporary save data
	btst	#0,save_disabled				; Is saving to Backup RAM disabled?
	bne.s	.Read						; If so, branch
	move.w	#SYS_BURAM_WRITE,d0				; Write Backup RAM save data
	
.Read:
	bsr.w	SubCpuCommand					; Run command
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bra.w	GiveWordRamAccess				; Give Sub CPU Word RAM access
	
; ------------------------------------------------------------------------------
; Send the Sub CPU a command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

	xdef SubCpuCommand
SubCpuCommand:
	move.w	d0,MCD_MAIN_COMM_0				; Set command ID

.WaitSubCpu:
	move.w	MCD_SUB_COMM_0,d0				; Has the Sub CPU received the command?
	beq.s	.WaitSubCpu					; If not, wait
	cmp.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpu					; If not, wait

	move.w	#0,MCD_MAIN_COMM_0				; Mark as ready to send commands again

.WaitSubCpuDone:
	move.w	MCD_SUB_COMM_0,d0				; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCpuDone					; If not, wait
	move.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpuDone					; If not, wait
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
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	bset	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Give Sub CPU Word RAM access
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

	xdef StopZ80
StopZ80:
	move	sr,saved_sr					; Save status register
	move	#$2700,sr					; Disable interrupts
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
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	bset	#0,ipx_vsync					; Set VSync flag
	move	#$2500,sr					; Enable V-BLANK interrupt

.Wait:
	btst	#0,ipx_vsync					; Has the V-BLANK handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Send the Sub CPU a command (copy)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; ------------------------------------------------------------------------------

	xdef SubCpuCommandCopy
SubCpuCommandCopy:
	move.w	d0,MCD_MAIN_COMM_0				; Send the command

.WaitSubCpu:
	move.w	MCD_SUB_COMM_0,d0				; Has the Sub CPU received the command?
	beq.s	.WaitSubCpu					; If not, wait
	cmp.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpu					; If not, wait

	move.w	#0,MCD_MAIN_COMM_0				; Mark as ready to send commands again

.WaitSubCpuDone:
	move.w	MCD_SUB_COMM_0,d0				; Is the Sub CPU done processing the command?
	bne.s	.WaitSubCpuDone					; If not, wait
	move.w	MCD_SUB_COMM_0,d0
	bne.s	.WaitSubCpuDone					; If not, wait
	rts

; ------------------------------------------------------------------------------
; Saved status register
; ------------------------------------------------------------------------------

saved_sr:
	dc.w	0
	
; ------------------------------------------------------------------------------
; Unknown
; ------------------------------------------------------------------------------

	jmp	0
	
; ------------------------------------------------------------------------------
