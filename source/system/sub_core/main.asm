; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"backup_ram.inc"

	section code

; ------------------------------------------------------------------------------
; Header
; ------------------------------------------------------------------------------

Header:
	dc.b	'MAIN       ', 0
	dc.w	0, 0
	dc.l	0
	dc.l	End-Header
	dc.l	.Offsets-Header
	dc.l	0

; ------------------------------------------------------------------------------

.Offsets:
	dc.w	Initialize-.Offsets
	dc.w	Main-.Offsets
	dc.w	MegaDriveIrq-.Offsets
	dc.w	UserCall-.Offsets
	dc.w	0

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

	xdef Initialize
Initialize:
	lea	MCD_SUB_COMMS,a0				; Clear communication registers
	moveq	#0,d0
	move.b	d0,MCD_SUB_FLAG-MCD_SUB_COMMS(a0)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	lea	DriveInitParams(pc),a0				; Initialzie drive
	move.w	#DRVINIT,d0
	jsr	_CDBIOS

.WaitReady:
	move.w	#CDBSTAT,d0					; Is the BIOS ready?
	jsr	_CDBIOS
	andi.b	#BIOS_BUSY_MASK,_CDSTAT
	bne.s	.WaitReady					; If not, wait

	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	
	move.w	#FILE_INIT,d0					; Initialize file engine
	jsr	FileFunction

	xdef UserCall
UserCall:
	rts

; ------------------------------------------------------------------------------

DriveInitParams:
	dc.b	1, $FF

SpxFile:
	dc.b	"SPX___.BIN;1", 0
	even

; ------------------------------------------------------------------------------
; Main
; ------------------------------------------------------------------------------

Main:
	move.w	#FILE_GET_FILES,d0				; Get files
	jsr	FileFunction

.Wait:
	jsr	_WAITVSYNC					; VSync

	move.w	#FILE_STATUS,d0					; Is the operation finished?
	jsr	FileFunction
	bcs.s	.Wait						; If not, wait

	cmpi.w	#FILE_STATUS_OK,d0				; Was the operation a success?
	bne.w	.Error						; If not, branch

	lea	SpxFile(pc),a0					; Load SPX file
	lea	Spx,a1
	jsr	LoadFile.w

	lea	PRG_RAM+$10000,sp				; Set stack pointer
	jmp	SpxStart					; Go to SPX

.Error:
	nop							; Loop here forever
	nop
	bra.s	.Error

; ------------------------------------------------------------------------------
; Temporary save data area
; ------------------------------------------------------------------------------

	section data_temp_save
	xdef TempSaveData
TempSaveData:
	include	"../../backup_ram/initial_data.asm"

; ------------------------------------------------------------------------------
; Load file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
;	a1.l - File read destination buffer
; ------------------------------------------------------------------------------

	section code_md_irq
	xdef MegaDriveIrq
MegaDriveIrq:
	movem.l	d0-a6,-(sp)					; Save registers
	move.w	#FILE_OPERATION,d0				; Perform file engine operation
	jsr	FileFunction
	movem.l	(sp)+,d0-a6					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Load file
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
;	a1.l - File read destination buffer
; ------------------------------------------------------------------------------

	section code_load_file
	xdef LoadFile
LoadFile:
	move.w	#FILE_LOAD_FILE,d0				; Start file loading
	jsr	FileFunction

.WaitFileLoad:
	jsr	_WAITVSYNC					; VSync
	
	move.w	#FILE_STATUS,d0					; Is the operation finished?
	jsr	FileFunction
	bcs.s	.WaitFileLoad					; If not, wait

	cmpi.w	#FILE_STATUS_OK,d0				; Was the operation a success?
	bne.w	LoadFile					; If not, try again
	rts

; ------------------------------------------------------------------------------
; Get file name
; ------------------------------------------------------------------------------
; NOTE: This function is not reliable, because there are some file names
; whose size is shorter or longer than "FILE_NAME_SIZE" characters. This is only
; used by the FMVs for getting name of their associated data file, whose
; file names are stored in the "safe" part of the file name table.
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - File ID
; RETURNS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

	section code_get_file_name
	xdef GetFileName
GetFileName:
	mulu.w	#FILE_NAME_SIZE+1,d0				; Get file name pointer
	lea	SpxFileNameTable,a0
	adda.w	d0,a0
	rts

; ------------------------------------------------------------------------------
; End of program
; ------------------------------------------------------------------------------

	section code_end
End:

; ------------------------------------------------------------------------------
