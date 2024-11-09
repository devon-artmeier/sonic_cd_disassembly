; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; Metal Sonic object
; ------------------------------------------------------------------------------

	xdef MetalSonicObject
MetalSonicObject:
	lea	.Index,a1					; Run routine
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitMetalSonic-.Index
	dc.w	EnterMetalSonic-.Index
	dc.w	FloatMetalSonic-.Index
	dc.w	BackUpMetalSonic-.Index
	dc.w	ExitMetalSonic-.Index

; ------------------------------------------------------------------------------
; Initialize
; ------------------------------------------------------------------------------

InitMetalSonic:
	addi.w	#$4000,obj.sprite_tile(a0)			; Set to sprite palette
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	
	lea	MetalSonicSprites(pc),a1
	move.l	a1,obj.sprites(a0)
	move.w	2(a1),obj.anim_delay(a0)
	
	move.w	#1,obj.routine(a0)				; Set to main routine
	rts

; ------------------------------------------------------------------------------
; Entrance
; ------------------------------------------------------------------------------

EnterMetalSonic:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObject					; If so, delete object
	
	move.l	obj.x_speed(a0),d0				; Get speed
	move.l	obj.y_speed(a0),d1
	
	tst.b	track_selection_flags				; Is track selection active?
	beq.s	.Move						; If not, branch
	
	move.l	#$180000,obj.x_speed(a0)			; Set exit speed
	move.l	#0,obj.y_speed(a0)
	btst	#7,obj.flags(a0)
	beq.s	.Exit
	neg.l	obj.x_speed(a0)

.Exit:
	move.w	#4,obj.routine(a0)				; Set to exit routine
	bra.s	.End

.Move:
	add.l	d0,obj.x(a0)					; Move
	add.l	d1,obj.y(a0)
	btst	#7,obj.flags(a0)				; Are we moving from the left side of the screen?
	beq.s	.CheckCenterXFromLeft				; If so, branch
	
.CheckCenterXFromRight:
	cmpi.w	#128,obj.x(a0)					; Are we at the horizontal center of the screen?
	bgt.s	.CheckY						; If not, branch
	bra.s	.StopAtCenterX

.CheckCenterXFromLeft:
	cmpi.w	#128,obj.x(a0)					; Are we at the horizontal center of the screen?
	blt.s	.CheckY						; If not, branch

.StopAtCenterX:
	move.w	#128,obj.x(a0)					; Stop at horizontal center of the screen
	move.l	#0,obj.x_speed(a0)

.CheckY:
	btst	#3,obj.flags(a0)				; Are we moving from the top side of the screen?
	bne.s	.CheckCenterYFromTop				; If so, branch
	
.CheckCenterYFromBtm:
	cmpi.w	#100,obj.y(a0)					; Are we at the vertical center of the screen?
	bgt.s	.CheckStop					; If not, branch
	bra.s	.StopAtCenterY

.CheckCenterYFromTop:
	cmpi.w	#100,obj.y(a0)					; Are we at the vertical center of the screen?
	blt.s	.CheckStop					; If not, branch

.StopAtCenterY:
	move.w	#100,obj.y(a0)					; Stop at vertical center of the screen
	move.l	#0,obj.y_speed(a0)

.CheckStop:
	cmpi.w	#128,obj.x(a0)					; Are we at the center of the screen?
	bne.s	.End						; If not, branch
	cmpi.w	#100,obj.y(a0)
	bne.s	.End						; If not, branch
	
	move.b	#64,obj.timer(a0)				; Set float timer
	move.b	#8,obj.timer_2(a0)				; Set direction timer
	move.w	#2,obj.routine(a0)				; Set to float routine

.End:
	rts

; ------------------------------------------------------------------------------
; Float
; ------------------------------------------------------------------------------

FloatMetalSonic:
	tst.b	track_selection_flags				; Is track selection active?
	bne.s	.BackUp						; If so, branch
	
	tst.b	obj.timer(a0)					; Has the float run out?
	blt.s	.Float						; If so, branch
	tst.b	obj.timer_2(a0)					; Has the direction timer run out?
	bne.s	.DecTimer					; If not, branch
	
	move.b	#24,obj.timer_2(a0)				; Reset direction timer
	jsr	Random(pc)					; Face random direction
	btst	#0,d0
	bne.s	.FaceOtherDirection
	bclr	#7,obj.flags(a0)
	bra.s	.DecTimer

.FaceOtherDirection:
	bset	#7,obj.flags(a0)

.DecTimer:
	subq.b	#1,obj.timer_2(a0)				; Decrement direction timer
	subq.b	#1,obj.timer(a0)				; Decrement float timer
	bge.s	.Float						; If it hasn't run out, branch

.BackUp:
	move.b	#48,obj.timer(a0)				; Set back up timer
	move.w	#$100,obj.float_speed(a0)			; Set float speed
	move.w	#2,obj.float_amplitude(a0)			; Set float amplitude
	
	lea	MetalSonicBackUpSprites(pc),a3			; Set back up animation
	move.l	a3,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)
	
	move.l	#-$10000,obj.x_speed(a0)			; Set back up speed
	btst	#7,obj.flags(a0)
	beq.s	.SetBackUpRoutine
	neg.l	obj.x_speed(a0)

.SetBackUpRoutine:
	move.w	#3,obj.routine(a0)				; Set to back up routine
	bra.s	.End

.Float:
	bsr.w	MoveFloatingObject				; Move

.End:
	rts

; ------------------------------------------------------------------------------
; Back up
; ------------------------------------------------------------------------------

BackUpMetalSonic:
	tst.b	track_selection_flags				; Is track selection active?
	bne.s	.Exit						; If so, branch
	subq.b	#1,obj.timer(a0)					; Decrement back up timer
	bgt.s	.Float						; If it hasn't run out, branch

.Exit:
	move.w	#0,obj.float_speed(a0)				; Stop floating
	move.w	#0,obj.float_amplitude(a0)

	move.l	#$180000,obj.x_speed(a0)			; Set exit speed
	btst	#7,obj.flags(a0)
	beq.s	.SetExitRoutine
	neg.l	obj.x_speed(a0)

.SetExitRoutine:
	move.w	#4,obj.routine(a0)				; Set to exit routine
	bra.s	.End

.Float:
	bsr.w	MoveFloatingObject				; Move

.End:
	rts

; ------------------------------------------------------------------------------
; Exit
; ------------------------------------------------------------------------------

ExitMetalSonic:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObject					; If so, delete object
	
	move.l	obj.x_speed(a0),d0				; Get speed
	move.l	obj.y_speed(a0),d1
	
	tst.b	track_selection_flags				; Is track selection active?
	beq.s	.Move						; If not, branch
	
	asl.l	#1,d0						; Move twice as fast
	asl.l	#1,d1
	add.l	d0,obj.x(a0)
	add.l	d1,obj.y(a0)
	bra.s	.End

.Move:
	add.l	d0,obj.x(a0)					; Move
	add.l	d1,obj.y(a0)

.End:
	rts

; ------------------------------------------------------------------------------
