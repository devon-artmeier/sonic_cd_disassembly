; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to VDP register data table
; ------------------------------------------------------------------------------

	xdef InitMegaDrive
InitMegaDrive:
	move.w	#$8000,d0					; Set up VDP registers
	moveq	#$13-1,d7

.SetupVdpRegs:
	move.b	(a0)+,d0
	move.w	d0,VDP_CTRL
	addi.w	#$100,d0
	dbf	d7,.SetupVdpRegs

	moveq	#$40,d0						; Set up controller ports
	move.b	d0,IO_CTRL_1
	move.b	d0,IO_CTRL_2
	move.b	d0,IO_CTRL_3
	move.b	#$C0,IO_DATA_1

	bsr.w	StopZ80						; Stop the Z80

	vdpCmd move.l,0,VRAM,WRITE,VDP_CTRL			; Clear VRAM
	lea	VDP_DATA,a0
	moveq	#0,d0
	move.w	#$10000/16-1,d7

.ClearVram:
	rept	16/4
		move.l	d0,(a0)
	endr
	dbf	d7,.ClearVram

	vdpCmd move.l,0,VSRAM,WRITE,VDP_CTRL			; Reset vertical scroll data
	move.l	#0,VDP_DATA

	bsr.w	StartZ80					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
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
