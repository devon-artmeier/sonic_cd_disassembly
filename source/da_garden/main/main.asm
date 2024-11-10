; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; -------------------------------------------------------------------------

	mmd 0, work_ram_file, $7800, Start, 0, 0

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

Start:
	move.l	#VBlankIrq,_LEVEL6+2.w				; Set V-BLANK address
	
	moveq	#0,d0						; Clear communication commands
	move.l	d0,MCD_MAIN_COMM_0
	move.l	d0,MCD_MAIN_COMM_4
	move.l	d0,MCD_MAIN_COMM_8
	move.l	d0,MCD_MAIN_COMM_12
	move.b	d0,MCD_MAIN_FLAG
	
	; Go to "InitPlanetRender" for more information on why this is here
	move.w	#$8000,ctrl_data				; Force program to assume start button was being held
	
	bsr.w	InitAnimation					; Initialize animation
	
	bsr.w	WaitSubCpuStart					; Wait for the Sub CPU program to start
	bsr.w	GiveWordRamAccess				; Give Word RAM access
	bsr.w	WaitSubCpuInit					; Wait for the Sub CPU program to finish initializing
	
	lea	VARIABLES,a0					; Clear variables
	moveq	#0,d0
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	d0,(a0)+
	dbf	d7,.ClearVariables
	ifne VARIABLES_SIZE&2
		move.w	d0,(a0)+
	endif
	ifne VARIABLES_SIZE&1
		move.b	d0,(a0)+
	endif
	
	bsr.w	InitMegaDrive					; Initialize the Mega Drive

	bsr.w	DrawPlanetMap					; Draw planet map
	bsr.w	DrawBackground					; Draw background
	
	move.b	#1,disable_palette_cycle			; Disable palette cycling
	bset	#6,ipx_vdp_reg_81+1				; Enable display
	move.w	ipx_vdp_reg_81,VDP_CTRL
	
	bsr.w	InitPlanetRender				; Initialize planet render
	bne.w	Exit						; If we are exiting, branch
	
	lea	DaGardenPalette(pc),a0				; Load palette
	lea	fade_palette,a1
	moveq	#$80/4-1,d7
	
.LoadPalette:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPalette
	
	bsr.w	FadeFromBlack					; Fade from black
	move.b	#0,disable_palette_cycle			; Enable palette cycling

; -------------------------------------------------------------------------

MainLoop:
	move.w	#2-1,planet_render_count			; Render to both buffers
	move.w	#0,vblank_routine				; Reset V-BLANK routine

.Loop:
	tst.w	planet_render_count				; Have both buffers been rendered to?
	blt.s	MainLoop					; If so, branch
	
	bsr.w	UpdateSubCpu					; Update Sub CPU
	jsr	TrackSelection(pc)				; Handle track selection
	jsr	UpdateObjects(pc)				; Update objects
	bsr.w	VSync						; VSync
	
	addq.w	#1,vblank_routine				; Next V-BLANK routine
	jsr	TrackSelection(pc)				; Handle track selection
	jsr	UpdateObjects(pc)				; Update objects
	bsr.w	VSync						; VSync
	
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	move	#$2700,sr					; Disable interrupts
	bsr.w	CheckTrackTitleSpawn				; Check track title object spawn
	bsr.w	GetPlanetImage					; Get planet image
	bsr.w	AnimateVolcano					; Animate volcano
	move	#$2500,sr					; Enable interrupts
	bsr.w	GiveWordRamAccess				; Give back Word RAM access

	btst	#5,MCD_SUB_FLAG					; Is the screen being refreshed?
	beq.s	.CheckExit					; If not, branch
	
	bsr.w	RefreshScreen					; Refresh the screen

.CheckExit:
	btst	#6,MCD_SUB_FLAG					; Are we exiting?
	beq.s	.NoExit						; If not, branch
	
	bsr.w	ExitFadeOut					; Fade out
	bra.s	Exit						; Exit

.NoExit:
	subq.w	#1,planet_render_count				; Decrement buffer render count
	addq.w	#1,vblank_routine				; Next V-BLANK routine
	bra.w	.Loop						; Loop

; -------------------------------------------------------------------------

Exit:
	move.b	#0,MCD_MAIN_FLAG				; Mark as done
	nop
	nop
	nop
	rts

; -------------------------------------------------------------------------
; Refresh the screen
; -------------------------------------------------------------------------

RefreshScreen:
	bsr.w	FadeToWhite					; Fade to white
	bsr.w	InitObjects					; Initialize objects
	bsr.w	ResetDaGarden					; Reset DA Garden
	bclr	#5,MCD_MAIN_FLAG				; Finish communication with Sub CPU

.WaitSubCpu:
	bsr.w	UpdateSubCpu					; Update Sub CPU
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetPlanetImage					; Get planet image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access
	
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.w	.End						; If so, branch
	btst	#4,MCD_SUB_FLAG					; Is the Sub CPU still switching music tracks?
	bne.s	.WaitSubCpu					; If so, wait
	
	; Show planet buffer 2, render to buffer 1
	move.w	#0,vblank_routine				; Set V-BLANK routine (copy 1st half of last rendered planet art to buffer 1)
	bsr.w	UpdateSubCpu					; Update Sub CPU
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetPlanetImage					; Get planet image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access
	bsr.w	VSync						; VSync
	
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.s	.End						; If so, branch
	
	move.w	#1,vblank_routine				; Set V-BLANK routine (copy 2nd half of last rendered planet art to buffer 1)
	bsr.w	VSync						; VSync
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.s	.End						; If so, branch
	
	; Show planet buffer 1, render to buffer 2
	move.w	#2,vblank_routine				; Set V-BLANK routine (copy 1st half of last rendered planet art to buffer 2)
	bsr.w	UpdateSubCpu					; Update Sub CPU
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetPlanetImage					; Get planet image
	bsr.w	GiveWordRamAccess				; Give back Word RAM access
	bsr.w	VSync						; VSync
	
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.s	.End						; If so, branch
	
	move.w	#3,vblank_routine				; Set V-BLANK routine (copy 2nd half of last rendered planet art to buffer 2)
	bsr.w	VSync						; VSync
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.s	.End						; If so, branch
	
	bclr	#0,track_selection_flags			; Music switch is done
	move.b	#0,object_spawn_flags				; Mark objects as despawned
	
	bsr.w	FadeFromWhite					; Fade from white
	move.w	#0,planet_render_count				; Clear buffer render count
	move.w	#-1,vblank_routine				; Make V-BLANK routine increment to 0

.End:
	rts

; -------------------------------------------------------------------------
; Initialize planet render
; -------------------------------------------------------------------------

InitPlanetRender:
	; Show planet buffer 2, render to buffer 1
	bsr.w	UpdateSubCpu					; Update Sub CPU
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetPlanetImage					; Get planet image
	bsr.w	AnimateVolcano					; Animate volcano
	bsr.w	GiveWordRamAccess				; Give back Word RAM access
	bsr.w	VSync						; VSync
	
	addq.w	#1,vblank_routine				; Set V-BLANK routine (copy 2nd half of last rendered planet art to buffer 1)
	bsr.w	VSync						; VSync
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.s	.Exit						; If so, branch
	
	; Show planet buffer 1, render to buffer 2
	bsr.w	UpdateSubCpu					; Update Sub CPU
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access
	bsr.w	GetPlanetImage					; Get planet image
	bsr.w	AnimateVolcano					; Animate volcano
	bsr.w	GiveWordRamAccess				; Give back Word RAM access
	addq.w	#1,vblank_routine				; Set V-BLANK routine (copy 1st half of last rendered planet art to buffer 2)
	bsr.w	VSync						; VSync
	
	addq.w	#1,vblank_routine				; Set V-BLANK routine (copy 2nd half of last rendered planet art to buffer 2)
	bsr.w	VSync						; VSync
	btst	#6,MCD_SUB_FLAG					; Is the Sub CPU exiting?
	bne.s	.Exit						; If so, branch
	
	moveq	#0,d0						; Not exiting
	rts

; -------------------------------------------------------------------------

.Exit:
	move.b	#1,disable_palette_cycle			; Disable palette cycling
	bsr.w	FadeToBlack					; Fade to black
	
	; BUG: That "beq.s" should be a "bne.s".
	; If it were to ever branch here, this could cause a crash, as the Sub CPU
	; will pretty much immediately clear bit 6 in MCD_SUB_FLAG, and cause
	; the loop to loop forever. However, because of a line that forces
	; the game to think that start was being held when the program started,
	; it prevents the Sub CPU from ever seeing the start button tapped bit
	; being set during this routine, thus preventing this code from
	; being executed.
	bset	#6,MCD_MAIN_FLAG				; Mark as exiting

.WaitSubCpu:
	btst	#6,MCD_SUB_FLAG					; Has the Sub CPU responded?
	beq.s	.WaitSubCpu					; If not, wait
	bclr	#6,MCD_MAIN_FLAG				; Communication is done
	
	clr.b	disable_palette_cycle				; Enable palette cycling
	moveq	#1,d0						; Exiting
	rts

; ------------------------------------------------------------------------------
