; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

	xdef VBlankIrq
VBlankIrq:
	movem.l	d0-a6,-(sp)					; Save registers

	move.b	#1,MCD_IRQ2					; Trigger IRQ2 on Sub CPU
	
	tst.b	vsync_flag					; Is the VSync flag set?
	beq.w	VBlankLag					; If not, branch
	move.b	#0,vsync_flag					; Clear VSync flag
	
	lea	VDP_CTRL,a1					; VDP control port
	lea	VDP_DATA,a2					; VDP data port
	move.w	(a1),d0						; Reset V-BLANK flag

	jsr	StopZ80(pc)					; Stop the Z80
	
	move.w	vblank_routine,d0				; Run routine
	add.w	d0,d0
	move.w	.Routines(pc,d0.w),d0
	jmp	.Routines(pc,d0.w)

; -------------------------------------------------------------------------

.Routines:
	dc.w	VBlankCopyPlanet11-.Routines
	dc.w	VBlankCopyPlanet12-.Routines
	dc.w	VBlankCopyPlanet21-.Routines
	dc.w	VBlankCopyPlanet22-.Routines

; -------------------------------------------------------------------------

VBlankCopyPlanet11:
	vdpCmd move.l,$D000,VRAM,WRITE,VDP_CTRL			; Show planet buffer 1
	move.w	#$100,(a2)
	copyPlanet 0,0						; Copy rendered planet image
	
	jsr	ReadController(pc)				; Read controllers
	bra.w	VBlankFinish

; -------------------------------------------------------------------------

VBlankCopyPlanet12:
	copyPlanet 0,1						; Copy rendered planet image
	bra.w	VBlankFinish

; -------------------------------------------------------------------------

VBlankCopyPlanet21:
	vdpCmd move.l,$D000,VRAM,WRITE,VDP_CTRL			; Show planet buffer 2
	move.w	#0,(a2)
	copyPlanet 1,0						; Copy rendered planet image
	
	jsr	ReadController(pc)				; Read controllers
	bra.w	VBlankFinish

; -------------------------------------------------------------------------

VBlankCopyPlanet22:
	copyPlanet 1,1						; Copy rendered planet image

; -------------------------------------------------------------------------

VBlankFinish:
	dma68k sprites,$EC00,$280,VRAM				; Copy sprite data
	
	tst.b	disable_palette_cycle				; Is palette cycling disabled?
	bne.w	.NoPaletteCycle					; If so, branch
	
	subq.w	#1,palette_cycle_delay
	bhi.s	.SpritePalCycle
	
	cmpi.w	#$1F,palette_cycle_frame
	blt.s	.CyclePalette
	move.w	#0,palette_cycle_frame

.CyclePalette:
	lea	PaletteCycleTimes,a0				; Reset palette cycle delay timer
	move.w	palette_cycle_frame,d0
	add.w	d0,d0
	move.w	(a0,d0.w),palette_cycle_delay
	
	addq.w	#1,palette_cycle_frame				; Increment palette cycle index
	
	lea	PaletteCycleIndex(pc),a0			; Get time zone palette cycle
	move.w	track_time_zone,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a0,d1.w),a1
	
	movea.l	(a1),a2						; Get planet palette cycle data
	adda.w	(a2,d0.w),a2
	
	lea	4(a0,d1.w),a1					; Get background palette cycle data
	movea.l	(a1),a1
	adda.w	(a1,d0.w),a1
	
	lea	palette,a0					; Load background palette
	moveq	#$20/4-1,d7

.LoadBgPalette:
	move.l	(a1)+,(a0)+
	dbf	d7,.LoadBgPalette
	
	moveq	#$20/4-1,d7					; Load planet palette

.LoadPlanetPalette:
	move.l	(a2)+,(a0)+
	dbf	d7,.LoadPlanetPalette

.SpritePalCycle:
	subq.w	#1,sprite_pal_cycle_delay			; Decrement sprite palette cycle timer
	bgt.s	.CheckVolcanoAnim				; If it hasn't run out, branch
	
	move.w	sprite_pal_cycle_frame,d0			; Get sprite palette cycle data
	lea	SpritePaletteCycleIndex,a1
	adda.w	(a1,d0.w),a1
	
	lea	palette+($20*2),a0				; Load sprite palette
	moveq	#$20/4-1,d7

.LoadSpritePalette:
	move.l	(a1)+,(a0)+
	dbf	d7,.LoadSpritePalette
	
	tst.w	d0						; Are we on the last sprite palette cycle index?
	bne.s	.ResetSprPalCycle				; If so, branch
	
	move.w	#2,sprite_pal_cycle_frame			; Increment sprite palette cycle index
	bra.s	.ResetSprPalCycleDelay

.ResetSprPalCycle:
	move.w	#0,sprite_pal_cycle_frame			; Reset sprite palette cycle index

.ResetSprPalCycleDelay:
	move.w	#5,sprite_pal_cycle_delay			; Reset sprite palette cycle timer

.NoPaletteCycle:
	dma68k palette,$0000,$80,CRAM				; Copy palette data

.CheckVolcanoAnim:
	tst.w	volcano_anim_delay				; Has the volcano timer run out?
	ble.s	.CheckTimer					; If so, branch
	subq.w	#1,volcano_anim_delay				; Decrement volcano timer

.CheckTimer:
	bsr.w	StartZ80					; Start the Z80
	
	tst.w	timer						; Is the timer running?
	beq.s	.NoTimer					; If not, branch
	subq.w	#1,timer					; Decrement timer

.NoTimer:
	addq.w	#1,frame_count					; Increment frame count
	
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; -------------------------------------------------------------------------

VBlankLag:
	addq.l	#1,lag_count					; Increment lag count
	move.b	vblank_routine+1,lag_count			; Save routine ID
	
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------
