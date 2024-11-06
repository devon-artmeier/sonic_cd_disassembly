; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------

	mmd MMD_SUB, work_ram_file, $8000, Start, 0, 0

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.w	#$8134,ipx_vdp_reg_81				; Disable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	
	move.l	#VBlankIrq,_LEVEL6+2				; Set V-BLANK address
	move.l	#-1,lag_counter					; Disable lag counter

	moveq	#0,d0						; Clear communication registers
	move.l	d0,MCD_MAIN_COMM_0
	move.l	d0,MCD_MAIN_COMM_4
	move.l	d0,MCD_MAIN_COMM_8
	move.l	d0,MCD_MAIN_COMM_12
	move.b	d0,MCD_MAIN_FLAG
	
	move.b	d0,enable_display				; Clear display enable flag
	move.l	d0,sub_wait_time				; Reset Sub CPU wait time
	move.b	d0,sub_fail_count				; Reset Sub CPU fail count
	
	lea	VARIABLES,a0					; Clear variables
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVariables:
	clr.l	(a0)+
	dbf	d7,.ClearVariables
	ifne VARIABLES_SIZE&2
		clr.w	(a0)+
	endif
	ifne VARIABLES_SIZE&1
		clr.b	(a0)+
	endif
	
	bsr.w	WaitSubCpuStart					; Wait for the Sub CPU program to start
	bsr.w	GiveWordRamAccess				; Give Word RAM access
	bsr.w	WaitSubCpuInit					; Wait for the Sub CPU program to finish initializing
	
	bsr.w	InitMegaDrive					; Initialize Mega Drive hardware
	bsr.w	ClearSprites					; Clear sprites
	bsr.w	ClearObjects					; Clear objects
	bsr.w	DrawTilemaps					; Draw tilemaps
	
	vdpCmd move.l,$D800,VRAM,WRITE,VDP_CTRL			; Load press start text art
	lea	PressStartTextArt(pc),a0
	bsr.w	DecompressNemesisVdp
	
	vdpCmd move.l,$DC00,VRAM,WRITE,VDP_CTRL			; Load menu arrow art
	lea	MenuArrowArt(pc),a0
	bsr.w	DecompressNemesisVdp
	
	ifne REGION=USA						; Load copyright/TM art
		vdpCmd move.l,$DE00,VRAM,WRITE,VDP_CTRL
		lea	CopyrightTmArt(pc),a0
		bsr.w	DecompressNemesisVdp
		
		vdpCmd move.l,$DFC0,VRAM,WRITE,VDP_CTRL
		lea	TmArt(pc),a0
		bsr.w	DecompressNemesisVdp
	else
		vdpCmd move.l,$DE00,VRAM,WRITE,VDP_CTRL
		lea	CopyrightArt(pc),a0
		bsr.w	DecompressNemesisVdp
		
		vdpCmd move.l,$DF20,VRAM,WRITE,VDP_CTRL
		lea	TmArt(pc),a0
		bsr.w	DecompressNemesisVdp
	endif
	
	vdpCmd move.l,$F000,VRAM,WRITE,VDP_CTRL			; Load banner art
	lea	BannerArt(pc),a0
	bsr.w	DecompressNemesisVdp
	
	vdpCmd move.l,$6D00,VRAM,WRITE,VDP_CTRL			; Load Sonic art
	lea	SonicArt(pc),a0
	bsr.w	DecompressNemesisVdp

	lea	SonicObject(pc),a2				; Spawn Sonic
	bsr.w	SpawnObject
	
	vdpCmd move.l,$BC20,VRAM,WRITE,VDP_CTRL			; Load solid tiles
	lea	SolidColorArt(pc),a0
	bsr.w	DecompressNemesisVdp
	
	bsr.w	DrawCloudTilemap				; Draw cloud tilemap
	bsr.w	VSync						; VSync

	move.b	#1,enable_display				; Enable display
	move.w	#4,vblank_routine				; VSync
	bsr.w	VSync

	ifne REGION=USA
		move.w	#48-1,d7				; Delay 48 frames

.Delay:
		bsr.w	VSync
		dbf	d7,.Delay
	endif

	move.l	#0,lag_counter					; Enable and reset lag counter
	jsr	RunObjects(pc)					; Run objects
	move.w	#5,vblank_routine				; VSync
	bsr.w	VSync

	lea	TitlePalette+($30*2),a1				; Fade in Sonic palette
	lea	fade_palette+($30*2),a2
	movem.l	(a1)+,d0-d7
	movem.l	d0-d7,(a2)
	move.w	#($30<<9)|($10-1),palette_fade_params
	bsr.w	FadeFromBlack

.WaitSonicTurn:
	move.b	#1,title_mode					; Set to "Sonic turning" mode
	
	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects

	btst	#7,title_mode					; Has Sonic turned around?
	bne.s	.FlashWhite					; If so, branch
	move.w	#5,vblank_routine				; VSync
	bsr.w	VSync
	bra.w	.WaitSonicTurn					; Loop

.FlashWhite:
	bclr	#7,title_mode					; Clear Sonic turned flag

	vdpCmd move.l,$6D80,VRAM,WRITE,VDP_CTRL			; Load emblem art
	lea	EmblemArt(pc),a0
	bsr.w	DecompressNemesisVdp

	lea	TitlePalette,a1					; Flash white and fade in title screen paltte
	lea	fade_palette,a2
	bsr.w	Copy128
	move.w	#(0<<9)|($30-1),palette_fade_params
	bsr.w	FadeFromWhite2

	lea	PlanetObject(pc),a2				; Spawn background planet
	bsr.w	SpawnObject
	
	lea	MenuObject,a2					; Spawn menu
	bsr.w	SpawnObject
	
	lea	CopyrightObject(pc),a2				; Spawn copyright
	bsr.w	SpawnObject
	
	ifne REGION<>JAPAN
		lea	TmObject(pc),a2				; Spawn TM symbol
		bsr.w	SpawnObject
	endif

; ------------------------------------------------------------------------------

MainLoop:
	move.b	#2,title_mode					; Set to "menu" mode
	
	; Show buffer 2, render to buffer 1
	bsr.w	RenderClouds					; Start rendering clouds
	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	bsr.w	PaletteCycle					; Run palette cycle
	bsr.w	ScrollBackground2				; Scroll background (show buffer 2)
	move.w	#0,vblank_routine				; VSync (copy 1st half of last cloud image to buffer 1)
	bsr.w	VSync

	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	move.w	#1,vblank_routine				; VSync (copy 2nd half of last cloud image to buffer 1)
	bsr.w	VSync

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetCloudImage					; Get cloud image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access

	tst.b	exit_flag					; Are we exiting the title screen?
	bne.s	.Exit						; If so, branch
	
	; Show buffer 1, render to buffer 2
	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	bsr.w	PaletteCycle					; Run palette cycle
	bsr.w	RenderClouds					; Start rendering clouds
	bsr.w	ScrollBackground1				; Scroll background (show buffer 1)
	move.w	#2,vblank_routine				; VSync (copy 1st half of last cloud image to buffer 2)
	bsr.w	VSync

	jsr	ClearSprites(pc)				; Clear sprites
	jsr	RunObjects(pc)					; Run objects
	move.w	#3,vblank_routine				; VSync (copy 2nd half of last cloud image to buffer 2)
	bsr.w	VSync

	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetCloudImage					; Get cloud image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access

	tst.b	exit_flag					; Are we exiting the title screen?
	bne.s	.Exit						; If so, branch
	bra.w	MainLoop					; Loop

.Exit:
	ifne REGION=USA
		cmpi.b	#4,sub_fail_count			; Is the Sub CPU deemed unreliable?
		bcc.s	.FadeOut				; If so, branch
	endif
	bset	#0,MCD_MAIN_FLAG				; Tell Sub CPU we are finished

.WaitSubCpu:
	btst	#0,MCD_SUB_FLAG					; Has the Sub CPU received our tip?
	beq.s	.WaitSubCpu					; If not, branch
	bclr	#0,MCD_MAIN_FLAG				; Respond to the Sub CPU

.FadeOut:
	move.w	#5,vblank_routine				; Fade to black
	bsr.w	FadeToBlack

	moveq	#0,d1						; Set exit code
	move.b	exit_flag,d1
	bmi.s	.NegativeFlag					; If it was negative, branch
	rts

.NegativeFlag:
	moveq	#0,d1						; Override with 0
	rts

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
	move.b	fm_sound_queue,z_fm_sound_queue_1		; Queue sound in driver
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
	cmpi.l	#-1,lag_counter					; Is the lag counter disabled?
	beq.s	.NoLagCounter					; If so, branch
	addq.l	#1,lag_counter					; Increment lag counter
	move.b	vblank_routine+1,lag_counter			; Save routine ID

.NoLagCounter:
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

; ------------------------------------------------------------------------------
; Unused functions to show a buffer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - VDP control port
;	a2.l - VDP data port
; ------------------------------------------------------------------------------

	xdef ShowClouds1
ShowClouds1:
	move.w	#$8F20,(a1)					; Set for every 8 scanlines
	vdpCmd move.l,$D002,VRAM,WRITE,VDP_CTRL			; Write background scroll data
	moveq	#0,d0						; Show buffer 1
	bra.s	ShowClouds

; ------------------------------------------------------------------------------

	xdef ShowClouds2
ShowClouds2:
	move.w	#$8F20,(a1)					; Set for every 8 scanlines
	vdpCmd move.l,$D002,VRAM,WRITE,VDP_CTRL			; Write background scroll data
	move.w	#$100,d0					; Show buffer 2

; ------------------------------------------------------------------------------

	xdef ShowClouds
ShowClouds:
	rept	(CLOUD_HEIGHT-8)/8				; Set scroll offset for clouds
		move.w	d0,(a2)
	endr
	move.w	#$8F02,(a1)					; Restore autoincrement
	rts

; ------------------------------------------------------------------------------
; Scroll background (show buffer 1)
; ------------------------------------------------------------------------------

	xdef ScrollBackground1
ScrollBackground1:
	lea	hscroll,a1					; Show buffer 1
	moveq	#(CLOUD_HEIGHT-8)-1,d1

.ShowClouds:
	clr.l	(a1)+
	dbf	d1,.ShowClouds

	lea	water_scroll,a2					; Water scroll buffer
	moveq	#64-1,d2					; 64 scanlines
	move.l	#$1000,d1					; Speed accumulator
	move.l	#$4000,d0					; Initial speed

.MoveWaterSections:
	add.l	d0,(a2)+					; Move water line
	add.l	d1,d0						; Increase speed
	dbf	d2,.MoveWaterSections				; Loop until all lines are moved

	lea	water_scroll,a2					; Set water scroll positions
	lea	hscroll+(160*4),a1
	moveq	#64-1,d2					; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0						; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2					; Next line
	dbf	d2,.SetWaterScroll				; Loop until all scanlines are set
	rts

; ------------------------------------------------------------------------------
; Scroll background (show buffer 2)
; ------------------------------------------------------------------------------

	xdef ScrollBackground2
ScrollBackground2:
	lea	hscroll,a1					; Show buffer 2
	moveq	#(CLOUD_HEIGHT-8)-1,d1

.ShowClouds:
	move.l	#$100,(a1)+
	dbf	d1,.ShowClouds

	lea	water_scroll,a2					; Water scroll buffer
	moveq	#64-1,d2					; 64 scanlines
	move.l	#$1000,d1					; Speed accumulator
	move.l	#$4000,d0					; Initial speed

.MoveWaterSections:
	add.l	d0,(a2)+					; Move water line
	add.l	d1,d0						; Increase speed
	dbf	d2,.MoveWaterSections				; Loop until all lines are moved

	lea	water_scroll,a2					; Set water scroll positions
	lea	hscroll+(160*4),a1
	moveq	#64-1,d2					; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0						; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2					; Next line
	dbf	d2,.SetWaterScroll				; Loop until all scanlines are set
	rts

; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

	xdef ReadControllers
ReadControllers:
	lea	p1_ctrl_data,a0					; Player 1 controller data buffer
	lea	IO_DATA_1,a1					; Controller port 1
	bsr.s	ReadController					; Read controller data
	
	lea	p2_ctrl_data,a0					; Player 2 controller data buffer
	lea	IO_DATA_2,a1					; Controller port 2

	tst.b	control_clouds					; Are the clouds controllable?
	beq.s	ReadController					; If not, branch
	
	move.w	p2_ctrl_data,sub_p2_ctrl_data			; Send controller data to Sub CPU for controlling the clouds

; ------------------------------------------------------------------------------

	xdef ReadController
ReadController:
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
; Run palette cycle
; ------------------------------------------------------------------------------

	xdef PaletteCycle
PaletteCycle:
	addi.b	#$40,palette_cycle_delay			; Run delay timer
	bcs.s	.Update						; If it's time to update, branch
	rts

.Update:
	moveq	#0,d0						; Get frame
	move.b	palette_cycle_frame,d0
	addq.b	#1,d0						; Increment frame
	cmpi.b	#3,d0						; Is it time to wrap?
	bcs.s	.NoWrap						; If not, branch
	clr.b	d0						; Wrap back to start

.NoWrap:
	move.b	d0,palette_cycle_frame				; Update frame ID

	lea	.WaterPaletteCycle(pc),a1			; Set palette cycle colors
	lea	palette+(5*2),a2
	add.b	d0,d0
	add.b	d0,d0
	add.b	d0,d0
	lea	(a1,d0.w),a1
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------

.WaterPaletteCycle:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

; ------------------------------------------------------------------------------
; Draw cloud tilemap
; ------------------------------------------------------------------------------

	xdef DrawCloudTilemap
DrawCloudTilemap:
	lea	VDP_CTRL,a2					; VDP control port
	lea	VDP_DATA,a3					; VDP data port

	move.w	#$8001,d6					; Draw buffer 1 tilemap
	vdpCmd move.l,$E000,VRAM,WRITE,d0
	moveq	#CLOUD_TILE_W-1,d1
	moveq	#CLOUD_TILE_H-1,d2
	bsr.s	.DrawMap

	move.w	#$8181,d6					; Draw buffer 2 tilemap
	vdpCmd move.l,$E040,VRAM,WRITE,d0
	moveq	#CLOUD_TILE_W-1,d1
	moveq	#CLOUD_TILE_H-1,d2

; ------------------------------------------------------------------------------

.DrawMap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width
	move.w	d6,d5						; Get first column tile

.DrawTile:
	move.w	d5,(a3)						; Write tile ID
	addi.w	#CLOUD_TILE_H,d5				; Next column tile
	dbf	d3,.DrawTile					; Loop until row is written
	
	add.l	d4,d0						; Next row
	addq.w	#1,d6						; Next column tile
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
