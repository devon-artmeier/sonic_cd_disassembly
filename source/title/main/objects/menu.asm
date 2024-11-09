; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
	
	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"
	include	"menu.inc"

	section code

; ------------------------------------------------------------------------------
; Menu object
; ------------------------------------------------------------------------------

	xdef MenuObject
MenuObject:
	move.l	#MenuSprites,obj.sprites(a0)			; Set sprites
	move.w	#$A000|($D800/$20),obj.sprite_tile(a0)		; Set sprite tile ID
	move.b	#%1,obj.flags(a0)				; Set flags
	move.w	#83,obj.x(a0)					; Set X position
	move.w	#180,obj.y(a0)					; Set Y position
	ifne REGION=USA						; Activate timer
		move.w	#$3FC,timer
	else
		move.w	#$1E0,timer
	endif

; ------------------------------------------------------------------------------
; Check start button
; ------------------------------------------------------------------------------

PressStart:
	addi.b	#$10,menu.delay(a0)				; Increment delay counter
	bcc.s	.NoFlash					; If it hasn't overflowed, branch
	eori.b	#1,obj.sprite_frame(a0)				; Flash text

.NoFlash:
	btst	#7,p1_ctrl_tap					; Has the start button been pressed?
	bne.s	.PrepareMenu					; If so, branch

	bsr.w	CheckCloudCheat					; Check clouds cheat
	bsr.w	CheckCloudControl				; Check cloud control

	bsr.w	CheckSoundTestCheat				; Check sound test cheat
	tst.b	d0						; Was it activated?
	bne.w	CheatActivated					; If so, branch

	bsr.w	CheckStageSelectCheat				; Check stage select cheat
	tst.b	d0						; Was it activated?
	bne.w	CheatActivated					; If so, branch
	
	bsr.w	CheckBestTimesCheat				; Check best times cheat
	tst.b	d0						; Was it activated?
	bne.w	CheatActivated					; If so, branch

	tst.w	timer						; Has the timer run out?
	beq.w	TimeOut						; If so, branch

	bsr.w	BookmarkObject					; Set bookmark
	bra.s	PressStart					; Update

; ------------------------------------------------------------------------------

.PrepareMenu:
	clr.w	p1_ctrl_data					; Clear controller data
	move.b	#1,obj.sprite_frame(a0)				; Make invisible
	move.w	#$1E0,timer					; Reset timer

	lea	menu_options,a2					; Options buffer
	move.b	title_flags,d1					; Title screen flags

	move.w	#$FF02,(a2)+					; Add stop flag and new game option
	moveq	#1,d0						; Highlight new game option
	btst	#6,d1						; Is there a save file?
	beq.s	.SetSelection					; If not, branch
	moveq	#2,d0						; Highlight continue option
	move.b	#3,(a2)+					; Add continue option

.SetSelection:
	move.b	d0,menu_selection				; Set menu selection

	btst	#5,d1						; Is time attack enabled?
	beq.s	.NoTimeAttack					; If not, branch
	move.b	#4,(a2)+					; Add time attack option

.NoTimeAttack:
	btst	#4,d1						; Is save management enabled?
	beq.s	.NoRamData					; If not, branch
	move.b	#5,(a2)+					; Add save management option

.NoRamData:
	btst	#3,d1						; Is DA Garden enabled?
	beq.s	.NoDAGarden					; If not, branch
	move.b	#6,(a2)+					; Add DA Garden option

.NoDAGarden:
	btst	#2,d1						; Is Visual Mode enabled?
	beq.s	.NoVisualMode					; If not, branch
	move.b	#7,(a2)+					; Add Visual Mode option

.NoVisualMode:
	move.b	#$FF,(a2)					; Add stop flag

	lea	MenuArrowObject(pc),a2				; Spawn left menu arrow
	bsr.w	SpawnObject
	move.w	a0,arrow.parent(a1)
	
	lea	MenuArrowObject(pc),a2				; Spawn right menu arrow
	bsr.w	SpawnObject
	move.w	a0,arrow.parent(a1)
	move.b	#1,arrow.id(a1)

; ------------------------------------------------------------------------------
; Move right after initialization or selection
; ------------------------------------------------------------------------------

MoveRight:
	move.w	#$C000|($D800/$20),obj.sprite_tile(a0)		; Unhighlight text
	clr.b	menu.allow_selection(a0)			; Disable selection
	
	bsr.w	BookmarkObject					; Set bookmark
	
	addi.b	#$80,menu.delay(a0)				; Incremenet delay counter
	bcc.s	MoveRight					; If it hasn't overflowed, branch

.MoveOut:
	move.w	obj.x(a0),d0					; Move in
	addi.w	#$20,d0
	move.w	d0,obj.x(a0)
	
	bsr.w	BookmarkObject					; Set bookmark
	
	cmpi.w	#$100,obj.x(a0)					; Is the text fully off screen?
	bcs.s	.MoveOut					; If not, branch
	
	bsr.w	BookmarkObject					; Set bookmark
	
	lea	menu_options,a2					; Set option ID
	moveq	#0,d0
	move.b	menu_selection,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	move.b	d0,menu.option(a0)
	bsr.w	SetOption

	move.w	#-$2D,obj.x(a0)					; Move to left side of screen
	
	bsr.w	BookmarkObject					; Set bookmark

.MoveIn:
	move.w	obj.x(a0),d0					; Move in
	addi.w	#$10,d0
	move.w	d0,obj.x(a0)
	
	bsr.w	BookmarkObject					; Set bookmark
	
	tst.w	obj.x(a0)					; Is the text still off screen?
	bmi.s	.MoveIn						; If so, branch
	cmpi.w	#$53,obj.x(a0)					; Is the text fully on screen?
	bcs.s	.MoveIn						; If not, branch
	
	move.w	#$53,obj.x(a0)					; Stop moving
	move.w	#$A000|($D800/$20),obj.sprite_tile(a0)		; Highlight text
	
	bra.w	WaitSelection					; Wait for selection

; ------------------------------------------------------------------------------
; Move left after selection
; ------------------------------------------------------------------------------

MoveLeft:
	move.w	#$C000|($D800/$20),obj.sprite_tile(a0)		; Unhighlight text
	clr.b	menu.allow_selection(a0)			; Disable selection
	
	bsr.w	BookmarkObject					; Set bookmark
	
	addi.b	#$80,menu.delay(a0)				; Incremenet delay counter
	bcc.s	MoveLeft					; If it hasn't overflowed, branch

.MoveOut:
	move.w	obj.x(a0),d0					; Move in
	subi.w	#$20,d0
	move.w	d0,obj.x(a0)
	
	bsr.w	BookmarkObject					; Set bookmark
	
	tst.w	obj.x(a0)					; Is the text still on screen?
	bpl.s	.MoveOut					; If so, branch
	cmpi.w	#-$35,obj.x(a0)					; Is the text fully off screen?
	bcc.s	.MoveOut					; If not, branch
	
	bsr.w	BookmarkObject					; Set bookmark
	
	lea	menu_options,a2					; Set option ID
	moveq	#0,d0
	move.b	menu_selection,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	move.b	d0,menu.option(a0)
	bsr.w	SetOption

	move.w	#$D3,obj.x(a0)					; Move to right side of screen
	
.MoveIn:
	bsr.w	BookmarkObject					; Set bookmark
	
	move.w	obj.x(a0),d0					; Move in
	subi.w	#$10,d0
	move.w	d0,obj.x(a0)
	
	cmpi.w	#$53,obj.x(a0)					; Is the text fully on screen?
	bcc.s	.MoveIn						; If not, branch
	
	move.w	#$53,obj.x(a0)					; Stop moving
	move.w	#$A000|($D800/$20),obj.sprite_tile(a0)		; Highlight text
	
	bra.w	WaitSelection					; Wait for selection

; ------------------------------------------------------------------------------
; Wait selection
; ------------------------------------------------------------------------------

WaitSelection:
	move.b	#3,menu.allow_selection(a0)			; Allow selection
	bsr.w	BookmarkObject					; Set bookmark

.CheckButtons:
	lea	menu_options,a2					; Options buffer
	btst	#2,p1_ctrl_hold					; Has left been pressed?
	bne.s	SelectLeft					; If so, branch
	btst	#3,p1_ctrl_hold					; Has right been pressed?
	bne.w	SelectRight					; If so, branch

	move.b	p1_ctrl_tap,d0					; Has any of the face buttons been pressed?
	andi.b	#%11110000,d0
	bne.w	SelectOption				; If so, branch

	tst.w	timer						; Has the timer run out?
	beq.w	TimeOut						; If so, branch

	bsr.w	BookmarkObject					; Set bookmark
	bra.s	.CheckButtons					; Check buttons


; ------------------------------------------------------------------------------
; Select left
; ------------------------------------------------------------------------------

SelectLeft:
	move.w	#$1E0,timer					; Reset timer
	
	moveq	#0,d0						; Move selection left
	move.b	menu_selection,d0
	subq.b	#1,d0
	move.b	(a2,d0.w),d1
	cmpi.b	#$FF,d1						; Should we stop?
	beq.s	.End						; If so, branch
	
	move.b	d0,menu_selection				; Set selection
	bra.w	MoveRight					; Move text right

.End:
	rts

; ------------------------------------------------------------------------------
; Select right
; ------------------------------------------------------------------------------

SelectRight:
	move.w	#$1E0,timer					; Reset timer
	
	moveq	#0,d0						; Move selection right
	move.b	menu_selection,d0
	addq.b	#1,d0
	move.b	(a2,d0.w),d1
	cmpi.b	#$FF,d1						; Should we stop?
	beq.s	.End						; If so, branch
	
	move.b	d0,menu_selection				; Set selection
	bra.w	MoveLeft					; Move text left

.End:
	rts

; ------------------------------------------------------------------------------
; Select option
; ------------------------------------------------------------------------------

SelectOption:
	lea	menu_options,a2					; Get option ID
	moveq	#0,d0
	move.b	menu_selection,d0
	lea	(a2,d0.w),a2
	move.b	(a2),d0
	
	subq.b	#1,d0						; Make it zero based
	bcc.s	.SetExitFlag					; If it hasn't underflowed, branch
	move.b	#1,d0						; If it has, use new game option

.SetExitFlag:
	move.b	d0,exit_flag					; Set exit flag

.Done:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	.Done						; Remain static

; ------------------------------------------------------------------------------
; Time out
; ------------------------------------------------------------------------------

TimeOut:
	move.b	#-1,exit_flag					; Go to attract mode

.Done:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	.Done						; Remain static

; ------------------------------------------------------------------------------
; Cheat activated
; ------------------------------------------------------------------------------

CheatActivated:
	move.b	d0,exit_flag					; Set exit flag

.Done:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	.Done						; Remain static

; ------------------------------------------------------------------------------
; Check cloud control cheat
; ------------------------------------------------------------------------------

CheckCloudCheat:
	moveq	#0,d0						; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	menu.cloud_cheat(a0),d0
	lea	(a2,d0.w),a2

	btst	#6,p1_ctrl_hold					; Is A being held?
	beq.s	.Failed						; If not, branch

	move.b	p1_ctrl_tap,d0					; Get current buttons being tapped
	move.b	(a2),d1						; Get current cheat button
	cmp.b	d1,d0						; Do they match?
	bne.s	.Failed						; If not, branch

	addq.b	#1,menu.cloud_cheat(a0)				; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,menu.cloud_cheat(a0)
	beq.s	.Activate					; If the cheat is now done, branch
	bra.s	.NotActivated					; Not done yet

.Failed:
	tst.b	d0						; Were any buttons tapped at all?
	beq.s	.NotActivated					; If not, branch
	clr.b	menu.cloud_cheat(a0)				; Reset cheat

.NotActivated:
	moveq	#0,d0						; Not activated
	rts

.Activate:
	bsr.w	PlayRingSound					; Play ring sound
	moveq	#-1,d0						; Activated
	move.b	d0,control_clouds				; Enable cloud control
	rts

; ------------------------------------------------------------------------------

.Cheat:
	dc.b	1, 2, 2, 2, 2, 1
.CheatEnd:
	dc.b	$FF
	even

; ------------------------------------------------------------------------------
; Check cloud control
; ------------------------------------------------------------------------------

CheckCloudControl:
	tst.b	control_clouds					; Is cloud control enabled?
	beq.s	.End						; If not, branch
	move.b	p2_ctrl_hold,d0					; Get player 2 buttons
	beq.s	.End						; If nothing is being pressed, branch
	move.w	#$1E0,timer					; Reset timer

.End:
	rts

; ------------------------------------------------------------------------------
; Check sound test cheat
; ------------------------------------------------------------------------------

CheckSoundTestCheat:
	moveq	#0,d0						; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	menu.sound_test_cheat(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1_ctrl_tap,d0					; Get current buttons being tapped
	move.b	(a2),d1						; Get current cheat button
	cmp.b	d1,d0						; Do they match?
	bne.s	.Failed						; If not, branch

	addq.b	#1,menu.sound_test_cheat(a0)			; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,menu.sound_test_cheat(a0)
	beq.s	.Activate					; If the cheat is now done, branch
	bra.s	.NotActivated					; Not done yet

.Failed:
	tst.b	d0						; Were any buttons tapped at all?
	beq.s	.NotActivated					; If not, branch
	clr.b	menu.sound_test_cheat(a0)			; Reset cheat

.NotActivated:
	moveq	#0,d0						; Not activated
	rts

.Activate:
	bsr.w	PlayRingSound					; Play ring sound
	moveq	#7,d0						; Exit to sound test
	rts

; ------------------------------------------------------------------------------

.Cheat:
	dc.b	2, 2, 2, 4, 8, $40
.CheatEnd:
	dc.b	$FF
	even

; ------------------------------------------------------------------------------

CheckStageSelectCheat:
	moveq	#0,d0						; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	menu.stage_select_cheat(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1_ctrl_tap,d0					; Get current buttons being tapped
	move.b	(a2),d1						; Get current cheat button
	cmp.b	d1,d0						; Do they match?
	bne.s	.Failed						; If not, branch

	addq.b	#1,menu.stage_select_cheat(a0)			; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,menu.stage_select_cheat(a0)
	beq.s	.Activate					; If the cheat is now done, branch
	bra.s	.NotActivated					; Not done yet

.Failed:
	tst.b	d0						; Were any buttons tapped at all?
	beq.s	.NotActivated					; If not, branch
	clr.b	menu.stage_select_cheat(a0)			; Reset cheat

.NotActivated:
	moveq	#0,d0						; Not activated
	rts

.Activate:
	bsr.w	PlayRingSound					; Play ring sound
	moveq	#8,d0						; Exit to stage select
	rts

; ------------------------------------------------------------------------------

.Cheat:
	dc.b	1, 2, 2, 4, 8, $10
.CheatEnd:
	dc.b	$FF
	even

; ------------------------------------------------------------------------------

CheckBestTimesCheat:
	moveq	#0,d0						; Get pointer to current cheat button
	lea	.Cheat(pc),a2
	move.b	menu.best_times_cheat(a0),d0
	lea	(a2,d0.w),a2

	move.b	p1_ctrl_tap,d0					; Get current buttons being tapped
	move.b	(a2),d1						; Get current cheat button
	cmp.b	d1,d0						; Do they match?
	bne.s	.Failed						; If not, branch

	addq.b	#1,menu.best_times_cheat(a0)			; Advance cheat
	cmpi.b	#.CheatEnd-.Cheat,menu.best_times_cheat(a0)
	beq.s	.Activate					; If the cheat is now done, branch
	bra.s	.NotActivated					; Not done yet

.Failed:
	tst.b	d0						; Were any buttons tapped at all?
	beq.s	.NotActivated					; If not, branch
	clr.b	menu.best_times_cheat(a0)			; Reset cheat

.NotActivated:
	moveq	#0,d0						; Not activated
	rts

.Activate:
	bsr.w	PlayRingSound					; Play ring sound
	moveq	#9,d0						; Exit to best times screen
	rts

; ------------------------------------------------------------------------------

.Cheat:
	dc.b	8, 8, 1, 1, 2, $20
.CheatEnd:
	dc.b	$FF
	even

; ------------------------------------------------------------------------------
; Play ring sound
; ------------------------------------------------------------------------------

PlayRingSound:
	move.b	#FM_RING,fm_sound_queue				; Play ring sound
	rts

; ------------------------------------------------------------------------------
; Set option and load text art
; ------------------------------------------------------------------------------

SetOption:
	moveq	#0,d0						; Get option
	move.b	menu.option(a0),d0
	move.b	d0,obj.sprite_frame(a0)

	move.l	a0,-(sp)					; Load text art
	add.w	d0,d0
	move.w	.Text(pc,d0.w),d0
	lea	.Text(pc,d0.w),a0
	vdpCmd move.l,$D800,VRAM,WRITE,VDP_CTRL
	bsr.w	DecompressNemesisVdp
	movea.l	(sp)+,a0
	rts

; ------------------------------------------------------------------------------

.Text:
	dc.w	PressStartTextArt-.Text
	dc.w	PressStartTextArt-.Text
	dc.w	NewGameTextArt-.Text
	dc.w	ContinueTextArt-.Text
	dc.w	TimeAttackTextArt-.Text
	dc.w	RamDataTextArt-.Text
	dc.w	DaGardenTextArt-.Text
	dc.w	VisualModeTextArt-.Text

; ------------------------------------------------------------------------------
; Menu sprites
; ------------------------------------------------------------------------------

	xdef MenuSprites
MenuSprites:
	include	"../../data/menu_sprites.asm"
	even

; ------------------------------------------------------------------------------
; Menu arrow
; ------------------------------------------------------------------------------

	xdef MenuArrowObject
MenuArrowObject:
	move.l	#MenuArrowSprites,obj.sprites(a0)		; Set sprites
	move.w	#$A000|($DC00/$20),obj.sprite_tile(a0)		; Set sprite tile ID
	move.b	#%1,obj.flags(a0)				; Set flags
	move.w	#181,obj.y(a0)					; Set Y position
	
	move.w	#72,obj.x(a0)					; Set left arrow X position
	tst.b	arrow.id(a0)					; Is this the right arrow?
	beq.s	LeftMenuArrow					; If not, branch
	move.w	#168,obj.x(a0)					; Set right arrow X position

; ------------------------------------------------------------------------------
; Menu arrow (right)
; ------------------------------------------------------------------------------

RightMenuArrow:
	movea.w	arrow.parent(a0),a1				; Get parent object
	tst.b	menu.allow_selection(a1)			; Is selection enabled?
	bne.s	.CheckOption					; If so, branch

.Invisible:
	clr.b	obj.sprite_frame(a0)				; Don't display
	clr.w	arrow.delay(a0)

	bsr.w	BookmarkObject					; Set bookmark
	bra.s	RightMenuArrow					; Check display

.CheckOption:
	lea	menu_options,a2					; Get option on the right
	moveq	#0,d0
	move.b	menu_selection,d0
	addq.b	#1,d0
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0						; Is there no options on the right?
	beq.s	.Invisible					; If so, branch

	moveq	#0,d0						; Display animation frame
	move.b	arrow.frame(a0),d0
	move.b	.Frames(pc,d0.w),obj.sprite_frame(a0)

	addi.b	#$10,arrow.delay(a0)				; Increment animation delay counter
	bcc.s	.Displayed					; If it hasn't overflowed, branch
	
	addq.b	#1,arrow.frame(a0)				; Increment animation frame
	cmpi.b	#.FramesEnd-.Frames,arrow.frame(a0)
	bcs.s	.Displayed					; Branch if it doesn't need to wrap
	clr.b	arrow.frame(a0)					; Wrap to the start

.Displayed:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	RightMenuArrow					; Check display

; ------------------------------------------------------------------------------

.Frames:
	dc.b	4, 5, 6
.FramesEnd:
	even

; ------------------------------------------------------------------------------
; Menu arrow (left)
; ------------------------------------------------------------------------------

LeftMenuArrow:
	movea.w	arrow.parent(a0),a1				; Get parent object
	tst.b	menu.allow_selection(a1)			; Is selection enabled?
	bne.s	.CheckOption					; If so, branch

.Invisible:
	clr.b	obj.sprite_frame(a0)				; Don't display
	clr.w	arrow.delay(a0)

	bsr.w	BookmarkObject					; Set bookmark
	bra.s	LeftMenuArrow					; Check display

.CheckOption:
	lea	menu_options,a2					; Get option on the left
	moveq	#0,d0
	move.b	menu_selection,d0
	subq.b	#1,d0
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0						; Is there no options on the right?
	beq.s	.Invisible					; If so, branch

	moveq	#0,d0						; Display animation frame
	move.b	arrow.frame(a0),d0
	move.b	.Frames(pc,d0.w),obj.sprite_frame(a0)

	addi.b	#$10,arrow.delay(a0)				; Increment animation delay counter
	bcc.s	.Displayed					; If it hasn't overflowed, branch
	
	addq.b	#1,arrow.frame(a0)				; Increment animation frame
	cmpi.b	#.FramesEnd-.Frames,arrow.frame(a0)
	bcs.s	.Displayed					; Branch if it doesn't need to wrap
	clr.b	arrow.frame(a0)					; Wrap to the start

.Displayed:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	LeftMenuArrow					; Check display

; ------------------------------------------------------------------------------

.Frames:
	dc.b	1, 2, 3
.FramesEnd:
	even

; ------------------------------------------------------------------------------
; Menu arrow sprites
; ------------------------------------------------------------------------------

	xdef MenuArrowSprites
MenuArrowSprites:
	include	"../../data/menu_arrow_sprites.asm"
	even

; ------------------------------------------------------------------------------
