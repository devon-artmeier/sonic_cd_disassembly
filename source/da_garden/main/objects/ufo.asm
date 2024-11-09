; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; UFO object
; ------------------------------------------------------------------------------

	xdef UfoObject
UfoObject:
	lea	.Index,a1					; Run routine
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitUfo-.Index
	dc.w	NextUfoMode-.Index
	dc.w	FloatUfo-.Index
	dc.w	MoveObjectToTarget-.Index

; ------------------------------------------------------------------------------
; Initialization
; ------------------------------------------------------------------------------

InitUfo:
	addi.w	#$4000,obj.sprite_tile(a0)			; Set to sprite palette
	
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	lea	UfoSprites(pc),a1
	move.l	a1,obj.sprites(a0)
	move.w	2(a1),obj.anim_delay(a0)
	
	clr.w	obj.x_offset(a0)				; Reset position offset
	clr.w	obj.y_offset(a0)
	
	jsr	Random(pc)					; Set mode counter
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#5,d0
	swap	d0
	addq.b	#1,d0
	move.b	d0,obj.mode_counter(a0)
	
	divs.w	#64,d1						; Set float time
	swap	d1
	move.b	d1,obj.timer_2(a0)
	
	move.w	#2,obj.routine(a0)				; Set to float routine
	rts

; ------------------------------------------------------------------------------
; Next mode
; ------------------------------------------------------------------------------

NextUfoMode:
	cmpi.b	#3,obj.mode_counter(a0)				; Should we stop?
	bne.s	.NoStop						; If not, branch
	bsr.w	StopUfo						; Stop
	bra.s	.CheckTimer

.NoStop:
	bsr.w	GetObjectTargetX				; Get target X position
	bsr.w	StartMovingUfo					; Start moving

.CheckTimer:
	tst.b	obj.mode_counter(a0)				; Has the mode counter run out?
	blt.s	.End						; If so, branch
	subq.b	#1,obj.mode_counter(a0)				; Decrement it

.End:
	rts

; ------------------------------------------------------------------------------
; Get target X position
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef GetObjectTargetX
GetObjectTargetX:
	jsr	Random(pc)					; Get random horizontal distance
	andi.l	#$7FFF,d0
	divs.w	#32,d0
	swap	d0
	addi.w	#64,d0
	
	btst	#7,obj.flags(a0)				; Are we facing right?
	beq.s	.RightTarget					; If so, branch
	
	move.w	obj.x(a0),d1					; Get distance from the left
	sub.w	d0,d1
	bra.s	.SetTargetX

.RightTarget:
	move.w	obj.x(a0),d1					; Get distance from the right
	add.w	d0,d1

.SetTargetX:
	move.w	d1,obj.target_x(a0)				; Set target X position
	rts

; ------------------------------------------------------------------------------
; Stop
; ------------------------------------------------------------------------------

StopUfo:
	move.w	#2,obj.routine(a0)				; Set to float routine
	move.l	#0,obj.x_speed(a0)				; Stop movement
	move.l	#0,obj.y_speed(a0)
	
	lea	UfoSprites(pc),a1				; Set normal animation
	move.l	a1,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)
	
	move.b	#24,obj.timer_2(a0)				; Set time
	rts

; ------------------------------------------------------------------------------
; Start moving
; ------------------------------------------------------------------------------

StartMovingUfo:
	move.w	#3,obj.routine(a0)				; Set to move routine
	
	jsr	Random(pc)					; Set X speed
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#64,d0
	clr.w	d0
	asr.l	#4,d0
	addi.l	#$20000,d0
	move.l	d0,obj.x_speed(a0)
	btst	#3,obj.flags(a0)
	bne.s	.GetSpeedY
	neg.l	obj.x_speed(a0)

.GetSpeedY:
	move.l	obj.y_speed(a0),d7				; Set Y speed
	divs.w	#96,d1
	clr.w	d1
	asr.l	#4,d1
	move.l	d1,obj.y_speed(a0)
	addq.w	#5,obj.y_speed(a0)
	
	jsr	Random(pc)					; Get random target Y position
	andi.l	#$7FFF,d0
	divs.w	#56,d0
	swap	d0
	tst.l	d7						; Are we moving down?
	ble.s	.MoveDown					; If so, branch
	
.MoveUp:
	neg.l	obj.y_speed(a0)					; Move up
	addi.w	#32,d0						; Set target Y position
	move.w	d0,obj.target_y(a0)
	
	lea	UfoUpSprites(pc),a1				; Set upwards animation
	move.l	a1,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)
	bra.s	.End

.MoveDown:
	addi.w	#160,d0						; Set target Y position
	move.w	d0,obj.target_y(a0)
	
	lea	UfoDownSprites(pc),a1				; Set downwards animation
	move.l	a1,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)

.End:
	rts

; ------------------------------------------------------------------------------
; Move object to target
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef MoveObjectToTarget
MoveObjectToTarget:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObjectFromGroup				; If so, delete object
	
	move.l	obj.x_speed(a0),d0				; Get X speed
	tst.b	track_selection_flags				; Is track selection active?
	beq.s	.MoveX						; If not, branch
	asl.l	#3,d0						; If, so, go 8 times as fast

.MoveX:
	add.l	d0,obj.x(a0)					; Move X
	
	move.w	obj.x(a0),d0					; Get current X position
	tst.l	obj.x_speed(a0)					; Are we moving right?
	bge.s	.CheckRightTargetX				; If so, branch
	
.CheckLeftTargetX:
	cmp.w	obj.target_x(a0),d0				; Are we at the target?
	ble.s	.NextMode					; If so, branch
	bra.s	.MoveY

.CheckRightTargetX:
	cmp.w	obj.target_x(a0),d0				; Are we at the target?
	blt.s	.MoveY						; If not, branch

.NextMode:
	tst.b	obj.mode_counter(a0)				; Are there any more modes left to set?
	blt.s	.MoveY						; If not, branch
	move.w	#1,obj.routine(a0)				; Set to next mode

.MoveY:
	move.l	obj.y_speed(a0),d1				; Move Y
	add.l	d1,obj.y(a0)
	
	move.w	obj.y(a0),d1					; Get current Y position
	tst.l	obj.y_speed(a0)					; Are we moving down?
	bge.s	.CheckBottomTargetY				; If so, branch
	
.CheckTopTargetY:
	cmp.w	obj.target_y(a0),d1				; Are we at the target?
	ble.s	.NextMode2					; If so, branch
	bra.s	.End

.CheckBottomTargetY:
	cmp.w	obj.target_y(a0),d1				; Are we at the target?
	blt.s	.End						; If not, branch

.NextMode2:
	tst.b	obj.mode_counter(a0)				; Are there any more modes left to set?
	blt.s	.End						; If not, branch
	move.w	#1,obj.routine(a0)				; Set to next mode

.End:
	rts

; ------------------------------------------------------------------------------
; Float
; ------------------------------------------------------------------------------

FloatUfo:
	tst.l	obj.x_speed(a0)					; Are we moving?
	bne.s	.SlowFloat					; If so, branch
	move.w	#$48,obj.float_speed(a0)			; Float up and down quickly
	bra.s	.Move

.SlowFloat:
	move.w	#$28,obj.float_speed(a0)			; Float up and down slowly

.Move:
	bsr.w	MoveFloatingObject				; Move
	subq.b	#1,obj.timer_2(a0)				; Decrement time
	bgt.s	.End						; If it hasn't run out, branch
	move.w	#1,obj.routine(a0)				; Set to next mode

.End:
	rts

; ------------------------------------------------------------------------------
