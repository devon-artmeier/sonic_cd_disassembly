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
	move.l	#-1,lag_count					; Disable lag counter

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

	move.l	#0,lag_count					; Enable and reset lag counter
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
