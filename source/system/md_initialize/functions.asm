; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code
	
; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

	xdef ReadController
ReadController:
	lea	ctrl_data,a0					; Controller data buffer
	lea	IO_DATA_2,a1					; Controller port 2
	
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

	xdef ctrl_data, ctrl_press, ctrl_tap
ctrl_data:							; Controller data
ctrl_press:
	dc.b	0						; Controller pressed buttons data
ctrl_tap:
	dc.b	0						; Controller tapped buttons data

; ------------------------------------------------------------------------------
; VDP register data
; ------------------------------------------------------------------------------

	xdef VdpRegisters
VdpRegisters:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$C000/$2000					; Plane B location
	dc.b	$E000/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; Background color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-BLANK interrupt counter 0
	dc.b	%00000000					; Scroll by screen
	dc.b	%10000001					; H40
	dc.b	$E400/$400					; Horizontal scroll table lcation
	dc.b	0						; Reserved
	dc.b	2						; Auto increment by 2
	dc.b	%00000001					; 64x32 tile plane size
	dc.b	0						; Window horizontal position 0
	dc.b	0						; Window vertical position 0
	even

; ------------------------------------------------------------------------------
; FM SFX Sound driver
; ------------------------------------------------------------------------------

	xdef FmDriver
FmDriver:
	incbin	"../../../build/z80.bin"
FmDriverEnd:
	even

	xdef FM_DRIVER_SIZE
FM_DRIVER_SIZE		equ FmDriverEnd-FmDriver

; ------------------------------------------------------------------------------
; Saved status register
; ------------------------------------------------------------------------------

	xdef saved_sr
saved_sr:
	dc.w	0

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
