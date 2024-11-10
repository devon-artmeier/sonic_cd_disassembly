; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; -------------------------------------------------------------------------
; Reset DA Garden
; -------------------------------------------------------------------------

	xdef ResetDaGarden
ResetDaGarden:
	bsr.w	InitObjects					; Initialize objects

; -------------------------------------------------------------------------
; Load palette
; -------------------------------------------------------------------------

LoadPalette:
	lea	PaletteCycleIndex(pc),a0			; Get time zone palette cycle metadata
	move.w	track_time_zone,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	(a0,d0.w),a1
	
	movea.l	(a1),a2						; Get planet palette cycle data
	move.w	(a2),d1
	adda.w	d1,a2
	
	lea	4(a0,d0.w),a1					; Get background palette cycle data
	movea.l	(a1),a1
	move.l	(a1),d1						; BUG: Should be "move.w"
	adda.w	d1,a1
	
	lea	fade_palette,a0					; Load background palette
	moveq	#$20/4-1,d7

.InitBgPalette:
	move.l	(a1)+,(a0)+
	dbf	d7,.InitBgPalette
	
	moveq	#$20/4-1,d7					; Load planet palette

.InitPlanetPalette:
	move.l	(a2)+,(a0)+
	dbf	d7,.InitPlanetPalette
	
	lea	SpritePaletteCycle0,a1				; Load sprite palette
	moveq	#$20/4-1,d7

.InitSpritePalette:
	move.l	(a1)+,(a0)+
	dbf	d7,.InitSpritePalette
	
	lea	MenuPalette,a1					; Load selection menu palette
	moveq	#$20/4-1,d7

.InitMenuPalette:
	move.l	(a1)+,(a0)+
	dbf	d7,.InitMenuPalette

; -------------------------------------------------------------------------
; Initialize volcano animation and palette cycle
; -------------------------------------------------------------------------

	xdef InitAnimation
InitAnimation:
	move.w	#0,d0						; Reset palette cycle index
	move.w	d0,palette_cycle_frame
	add.w	d0,d0
	lea	PaletteCycleTimes,a0				; Reset palette cycle timer
	move.w	(a0,d0.w),palette_cycle_delay
	
	move.w	#0,d0						; Reset volcano animation index
	move.w	d0,volcano_anim_frame
	add.w	d0,d0
	lea	VolcanoAnimTimes,a0				; Reset volcano animation timer
	move.w	(a0,d0.w),volcano_anim_delay
	
	lea	VolcanoAnimFrames,a0				; Get initial frame stamps
	adda.w	(a0,d0.w),a0
	
	movea.l	#WORD_RAM_2M+PLANET_STAMP_MAP+(6*2),a1		; Get volcano section
	move.w	#$D8,d1						; Base stamp ID
	moveq	#2-1,d7						; Volcano section height

.SetStamps:
	move.w	(a0)+,d0					; Set row stamp 1
	add.w	d1,d0
	move.w	d0,(a1)+
	
	move.w	(a0)+,d0					; Set row stamp 2
	add.w	d1,d0
	move.w	d0,(a1)
	
	lea	$100-2(a1),a1					; Next row
	dbf	d7,.SetStamps					; Loop until all stamps are set
	
	move.w	#5,sprite_pal_cycle_delay			; Reset sprite palette cycle
	move.w	#0,sprite_pal_cycle_frame
	rts

; -------------------------------------------------------------------------
; Perform exit fade out
; -------------------------------------------------------------------------

	xdef ExitFadeOut
ExitFadeOut:
	move.b	#1,disable_palette_cycle			; Disable palette cycling
	bsr.w	FadeToBlack					; Fade to black
	bsr.w	LoadPalette					; Load palette
	
	bset	#6,MCD_MAIN_FLAG				; Mark as exiting

.WaitSubCpu:
	btst	#6,MCD_SUB_FLAG					; Has the Sub CPU responded?
	bne.s	.WaitSubCpu					; If not, wait
	bclr	#6,MCD_MAIN_FLAG				; Communication is done
	
	clr.b	disable_palette_cycle				; Enable palette cycling
	rts

; -------------------------------------------------------------------------
; Perform exit fade out (wait for Sub CPU)
; -------------------------------------------------------------------------

	xdef WaitSubExit
WaitSubExit:
	move.b	#1,disable_palette_cycle			; Disable palette cycling
	bsr.w	FadeToBlack					; Fade to black
	bsr.w	LoadPalette					; Load palette
	
.WaitSubCpu:
	nop							; Wait a bit
	nop
	nop
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	beq.s	.WaitSubCpu					; If not, wait
	bclr	#6,MCD_MAIN_FLAG				; Communication is done
	
	clr.b	disable_palette_cycle				; Enable palette cycling
	rts

; -------------------------------------------------------------------------
; Get rendered planet image
; -------------------------------------------------------------------------

	xdef GetPlanetImage
GetPlanetImage:
	lea	WORD_RAM_2M+PLANET_IMAGE_BUFFER,a1		; Rendered image in Word RAM
	lea	planet_image,a2					; Destination buffer
	move.w	#(PLANET_IMAGE_SIZE/$800)-1,d7			; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80					; Copy $800 bytes
		bsr.s	.Copy128
	endr
	dbf	d7,.CopyChunks
	rts

; -------------------------------------------------------------------------

.Copy128:
	rept	128/4
		move.l	(a1)+,(a2)+
	endr
	rts

; -------------------------------------------------------------------------
; Draw planet tilemap
; -------------------------------------------------------------------------

	xdef DrawPlanetMap
DrawPlanetMap:
	move.w	#$2000,d6					; Buffer 1 base tile ID
	lea	VDP_CTRL,a2					; VDP control port
	lea	VDP_DATA,a3					; VDP data port
	
	vdpCmd move.l,$C180,VRAM,WRITE,d0			; Draw buffer 1 tilemap
	moveq	#PLANET_TILE_W-1,d1
	moveq	#PLANET_TILE_H-1,d2
	bsr.s	.DrawMap
	
	move.w	#$22C0,d6					; Draw buffer 2 tilemap
	vdpCmd move.l,$C1C0,VRAM,WRITE,d0
	moveq	#PLANET_TILE_W-1,d1
	moveq	#PLANET_TILE_H-1,d2

; -------------------------------------------------------------------------

.DrawMap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width
	move.w	d6,d5						; Get first column tile

.DrawTile:
	move.w	d5,(a3)						; Write tile ID
	addi.w	#PLANET_TILE_H,d5				; Next column tile
	dbf	d3,.DrawTile					; Loop until row is written
	
	add.l	d4,d0						; Next row
	addq.w	#1,d6						; Next column tile
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts
	
; -------------------------------------------------------------------------
; Draw background
; -------------------------------------------------------------------------

	xdef DrawBackground
DrawBackground:
	lea	BackgroundTilemap,a0				; Decompress mappings
	lea	kos_buffer,a1
	bsr.w	DecompressKosinski
	
	lea	kos_buffer,a1					; Decompressed mappings
	lea	VDP_CTRL,a2					; VDP control port
	
	move.w	#$580,d6					; Base tile ID
	vdpCmd move.l,$E000,VRAM,WRITE,d0			; VDP write command
	
	move.w	#$16-1,d1					; Get height

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	#$20-1,d2					; Get width

.DrawTile:
	move.w	(a1)+,d3					; Draw tile
	add.w	d6,d3
	move.w	d3,VDP_DATA
	dbf	d2,.DrawTile					; Loop until row is written
	
	addi.l	#$800000,d0					; Next row
	dbf	d1,.DrawRow					; Loop until map is drawn
	
	vdpCmd move.l,$B000,VRAM,WRITE,VDP_CTRL			; Load background art
	lea	BackgroundArt,a0
	bsr.w	DecompressNemesisVdp
	
	vdpCmd move.l,$DFC0,VRAM,WRITE,VDP_CTRL			; Load unknown tiles
	rept	8
		move.l	#$DDDDDDDD,VDP_DATA
	endr
	rept	8
		move.l	#$FFFFFFFF,VDP_DATA
	endr
	rts

; -------------------------------------------------------------------------
; Animate volcano
; -------------------------------------------------------------------------

	xdef AnimateVolcano
AnimateVolcano:
	nop
	tst.w	volcano_anim_delay				; Has the timer ran out?
	bne.s	.End						; If not, exit
	
	cmpi.w	#$C,volcano_anim_frame				; Is the animation restarting?
	blt.s	.GetStamps					; If not, branch
	move.w	#0,volcano_anim_frame				; If so, reset the index

.GetStamps:
	lea	VolcanoAnimTimes,a0				; Set new timer
	move.w	volcano_anim_frame,d0
	add.w	d0,d0
	move.w	(a0,d0.w),volcano_anim_delay
	
	addq.w	#1,volcano_anim_frame				; Increment index
	
	lea	VolcanoAnimFrames,a0				; Get frame stamps
	adda.w	(a0,d0.w),a0
	
	movea.l	#WORD_RAM_2M+PLANET_STAMP_MAP+(6*2),a1		; Get volcano section
	move.w	#$D8,d1						; Base stamp ID
	moveq	#2-1,d6						; Volcano section height

.Row:
	moveq	#2-1,d5						; Volcano section width

.Stamp:
	move.w	(a0)+,d0					; Get stamp ID
	beq.s	.DrawStamp					; If it's blank, branch
	add.w	d1,d0						; If not, add base stamp ID

.DrawStamp:
	move.w	d0,(a1)+					; Store stamp ID
	dbf	d5,.Stamp					; Loop until row is set
	lea	$100-4(a1),a1					; Next row
	dbf	d6,.Row						; Loop until all stamps are set

.End:
	rts

; ------------------------------------------------------------------------------
