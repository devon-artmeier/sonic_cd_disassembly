; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	bset	#0,ipx_vsync					; Set VSync flag
	move	#$2500,sr					; Enable interrupts

.Wait:
	btst	#0,ipx_vsync					; Has the V-BLANK interrupt handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; V-BLANK interrupt
; ------------------------------------------------------------------------------

	xdef VBlankIrq
VBlankIrq:
	movem.l	d0-a6,-(sp)					; Save registers

	move.b	#1,MCD_IRQ2					; Trigger IRQ2 on Sub CPU
	
	bclr	#0,ipx_vsync					; Clear VSync flag
	beq.w	VBlankLag					; If it wasn't set, branch
	
	tst.b	enable_display					; Should we enable the display?
	beq.s	.Update						; If not, branch
	
	bset	#6,ipx_vdp_reg_81+1				; Enable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	clr.b	enable_display					; Clear enable display flag

.Update:
	lea	VDP_CTRL,a1					; VDP control port
	lea	VDP_DATA,a2					; VDP data port
	move.w	(a1),d0						; Reset V-BLANK flag

	jsr	StopZ80(pc)					; Stop the Z80
	dma68k palette,$0000,$80,CRAM				; Copy palette data
	dma68k hscroll,$D000,$380,VRAM				; Copy horizontal scroll data

	move.w	vblank_routine,d0				; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; ------------------------------------------------------------------------------

.Routines:
	dc.w	VBlankCopyClouds11-.Routines
	dc.w	VBlankCopyClouds12-.Routines
	dc.w	VBlankCopyClouds21-.Routines
	dc.w	VBlankCopyClouds22-.Routines
	dc.w	VBlankNothing-.Routines
	dc.w	VBlankNoClouds-.Routines

; ------------------------------------------------------------------------------

VBlankCopyClouds11:
	dma68k sprites,$D400,$280,VRAM				; Copy sprite data
	copyClouds 0,0						; Copy cloud image

	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VBlankFinish					; Finish

; ------------------------------------------------------------------------------

VBlankCopyClouds12:
	dma68k sprites,$D400,$280,VRAM				; Copy sprite data
	copyClouds 0,1						; Copy cloud image

	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VBlankFinish					; Finish

; ------------------------------------------------------------------------------

VBlankCopyClouds21:
	dma68k sprites,$D400,$280,VRAM				; Copy sprite data
	copyClouds 1,0						; Copy cloud image

	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VBlankFinish					; Finish

; ------------------------------------------------------------------------------

VBlankCopyClouds22:
	dma68k sprites,$D400,$280,VRAM				; Copy sprite data
	copyClouds 1,1						; Copy cloud image
	
	jsr	ReadControllers(pc)				; Read controllers
	bra.w	VBlankFinish					; Finish

; ------------------------------------------------------------------------------

VBlankNothing:
	bra.w	VBlankFinish					; Finish

; ------------------------------------------------------------------------------

VBlankNoClouds:
	dma68k sprites,$D400,$280,VRAM				; Copy sprite data
	jsr	ReadControllers(pc)				; Read controllers

; ------------------------------------------------------------------------------

VBlankFinish:
	tst.b	fm_sound_queue					; Is there a sound queued?
	beq.s	.NoSound					; If not, branch
	move.b	fm_sound_queue,Z80_RAM+z_sound_queue		; Queue sound in driver
	clr.b	fm_sound_queue					; Clear sound queue

.NoSound:
	bsr.w	StartZ80					; Start the Z80
	
	tst.w	timer						; Is the timer running?
	beq.s	.NoTimer					; If not, branch
	subq.w	#1,timer					; Decrement timer

.NoTimer:
	addq.w	#1,frame_count					; Increment frame count
	
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------

VBlankLag:
	cmpi.l	#-1,lag_count					; Is the lag counter disabled?
	beq.s	.NoLagCounter					; If so, branch
	addq.l	#1,lag_count					; Increment lag count
	move.b	vblank_routine+1,lag_count			; Save routine ID

.NoLagCounter:
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------
