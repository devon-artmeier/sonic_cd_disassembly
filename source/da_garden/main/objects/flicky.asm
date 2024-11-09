; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; Flicky object
; ------------------------------------------------------------------------------

	xdef FlickyObject
FlickyObject:
	lea	.Index,a1					; Run routine
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitFlicky-.Index
	dc.w	NormalFlicky-.Index
	dc.w	SlowFlicky-.Index
	dc.w	GlideFlicky-.Index

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

InitFlicky:
	addi.w	#$4000,obj.sprite_tile(a0)			; Set to sprite palette
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	
	clr.w	obj.x_offset(a0)				; Reset position offset
	clr.w	obj.y_offset(a0)
	
	btst	#1,obj.flags(a0)				; Are we gliding?
	beq.s	.CheckSlow					; If not, branch
	move.w	#3,obj.routine(a0)				; Set to gliding routine
	rts

.CheckSlow:
	btst	#0,obj.flags(a0)				; Are we going slow?
	beq.s	.Normal						; If not, branch
	move.w	#2,obj.routine(a0)				; Set to slow routine
	rts

.Normal:
	move.w	#1,obj.routine(a0)				; Set to normal routine
	rts

; ------------------------------------------------------------------------------
; Normal flicky
; ------------------------------------------------------------------------------

NormalFlicky:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObjectFromGroup				; If so, delete object
	
	bsr.w	MoveFlicky					; Move
	rts

; ------------------------------------------------------------------------------
; Slow flicky
; ------------------------------------------------------------------------------

SlowFlicky:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObjectFromGroup				; If so, delete object

	bsr.w	MoveFlicky					; Move
	bsr.w	MoveSlowFlicky					; Handle slow movement
	rts

; ------------------------------------------------------------------------------
; Gliding flicky
; ------------------------------------------------------------------------------

GlideFlicky:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObjectFromGroup				; If so, delete object

	bsr.w	MoveFlicky					; Move
	bsr.w	MoveGlideFlicky					; Handle glide movement
	rts

; ------------------------------------------------------------------------------
; Movement
; ------------------------------------------------------------------------------

MoveFlicky:
	btst	#1,obj.flags(a0)				; Are we gliding?
	beq.s	.NotGliding					; If not, branch
	tst.l	obj.y_speed(a0)					; Are we moving down?
	bgt.s	.GetSpeedX					; If so, branch

.NotGliding:
	move.w	obj.y_offset(a0),d0				; Apply Y offset
	sub.w	d0,obj.y(a0)

	move.w	obj.float_angle(a0),d3				; Update Y offset
	jsr	CalcSine(pc)
	muls.w	#4,d3
	asr.l	#8,d3
	move.w	d3,obj.y_offset(a0)
	add.w	d3,obj.y(a0)

	jsr	Random(pc)					; Increment float angle
	andi.l	#$7FFF,d0
	divs.w	#$30,d0
	swap	d0
	add.w	d0,obj.float_angle(a0)
	cmpi.w	#$1FF,obj.float_angle(a0)
	blt.s	.GetSpeedX
	subi.w	#$1FF,obj.float_angle(a0)

.GetSpeedX:
	move.l	obj.x_speed(a0),d0				; Get X speed
	tst.b	track_selection_flags				; Is track selection active?
	beq.s	.Move						; If not, branch
	asl.l	#3,d0						; If, so, go 8 times as fast

.Move:
	add.l	d0,obj.x(a0)					; Move X position
	move.l	obj.y_speed(a0),d0				; Move Y position
	add.l	d0,obj.y(a0)
	rts

; ------------------------------------------------------------------------------
; Slow flicky movement
; ------------------------------------------------------------------------------

MoveSlowFlicky:
	move.w	obj.id(a0),d0					; Find flicky group
	bsr.w	FindObjectById
	beq.s	.CatchUp					; If we are the only flicky, branch

	move.w	obj.x(a0),d0					; Get distance from group
	sub.w	obj.x(a1),d0
	bge.s	.CheckDist
	neg.w	d0

.CheckDist:
	cmpi.w	#72,d0						; Are we too far from the group?
	blt.s	.Slow						; If not, branch

.CatchUp:
	lea	FlickyCatchUpSprites(pc),a3			; Catch up animation
	move.l	a3,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)

	tst.l	obj.x_speed(a0)					; Are we moving right?
	bge.s	.CatchUpRight					; If so, branch
	move.l	#-$30000,obj.x_speed(a0)			; Catch up left
	bra.s	.End

.CatchUpRight:
	move.l	#$30000,obj.x_speed(a0)				; Catch up right
	bra.s	.End

.Slow:
	cmpi.w	#32,d0						; Are we too close to the group?
	bgt.s	.End						; If not, branch

	lea	FlickySlowSprites(pc),a3			; Slow animation
	move.l	a3,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)

	tst.l	obj.x_speed(a0)					; Are we moving right?
	bge.s	.SlowRight					; If so, branch
	move.l	#-$A000,obj.x_speed(a0)				; Slow down left
	bra.s	.End

.SlowRight:
	move.l	#$A000,obj.x_speed(a0)				; Slow down right

.End:
	rts

; ------------------------------------------------------------------------------
; Gliding flicky movement
; ------------------------------------------------------------------------------

MoveGlideFlicky:
	move.w	obj.id(a0),d0					; Find flicky group
	bsr.w	FindObjectById
	beq.s	.CatchUp					; If we are the only flicky, branch

	move.w	obj.y(a0),d0					; Get distance from group
	sub.w	obj.y(a1),d0
	bgt.s	.CheckDist
	moveq	#0,d0

.CheckDist:
	cmpi.w	#58,d0						; Are we too far up?
	blt.s	.Glide						; If so, branch

.CatchUp:
	lea	FlickyCatchUpSprites(pc),a3			; Catch up animation
	move.l	a3,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)
	
	move.l	#-$B000,obj.y_speed(a0)				; Move up
	bra.s	.End

.Glide:
	cmpi.w	#8,d0						; Are we close enough to the group?
	bgt.s	.End						; If so, branch
	
	lea	FlickyGlideSprites(pc),a3			; Glide animation
	move.l	a3,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)

	move.l	#$E000,obj.y_speed(a0)				; Glide down

.End:
	rts

; ------------------------------------------------------------------------------
