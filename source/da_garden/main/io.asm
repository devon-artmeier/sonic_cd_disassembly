; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Initialize the Mega Drive hardware
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
	
	bra.s	.SkipZ80					; Skip the Z80 stuff
	
	resetZ80Off						; Set Z80 reset off
	bsr.w	StopZ80						; Stop the Z80
	
	lea	Z80_RAM,a1					; Load Z80 code
	move.b	#$F3,(a1)+					; DI
	move.b	#$F3,(a1)+					; DI
	move.b	#$C3,(a1)+					; JP $0000
	move.b	#0,(a1)+
	move.b	#0,(a1)+
	
	resetZ80On						; Set Z80 reset on
	resetZ80Off						; Set Z80 reset off

.SkipZ80:
	bsr.w	StopZ80						; Stop the Z80

	vramFill 0,$10000,0					; Clear VRAM

	vdpCmd move.l,$C000,VRAM,WRITE,VDP_CTRL			; Reset plane A
	move.w	#$1000/2-1,d7

.ResetPlaneA:
	move.w	#$E6FF,VDP_DATA
	dbf	d7,.ResetPlaneA

	vdpCmd move.l,$E000,VRAM,WRITE,VDP_CTRL			; Reset plane B
	move.w	#$1000/2-1,d7

.ResetPlaneB:
	move.w	#$6FE,VDP_DATA
	dbf	d7,.ResetPlaneB
	
	vdpCmd move.l,0,CRAM,WRITE,VDP_CTRL			; Clear CRAM
	lea	InitPalette(pc),a0
	moveq	#0,d0
	moveq	#$80/4-1,d7
	
.ClearCram:
	move.l	d0,VDP_DATA
	dbf	d7,.ClearCram

	vdpCmd move.l,0,VSRAM,WRITE,VDP_CTRL			; Reset VSRAM
	move.l	#$FFE0,VDP_DATA

	bsr.w	StartZ80					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
	rts

; ------------------------------------------------------------------------------

InitPalette:
	incbin	"../data/palette.pal"
InitPaletteEnd:
	even

VdpRegisters:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$E000/$2000					; Plane B location
	dc.b	$EC00/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; BG color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-BLANK interrupt counter 0
	dc.b	%00000000					; Scroll by screen
	dc.b	%00000000					; H32
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
	lea	sub_p2_ctrl_data,a0				; Controller data buffer
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
	and.b	d1,d0						; store tapped buttons
	move.b	d0,(a0)+
	rts

; ------------------------------------------------------------------------------
