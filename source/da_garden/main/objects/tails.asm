; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Tails object
; ------------------------------------------------------------------------------

	xdef TailsObject
TailsObject:
	lea	.Index,a1					; Run routine
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitTails-.Index
	dc.w	NextTailsMode-.Index
	dc.w	FloatTails-.Index
	dc.w	MoveObjectToTarget-.Index

; ------------------------------------------------------------------------------
; Initialize
; ------------------------------------------------------------------------------

InitTails:
	addi.w	#$4000,obj.sprite_tile(a0)			; Set to sprite palette
	
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	lea	TailsSprites(pc),a1
	move.l	a1,obj.sprites(a0)
	move.w	2(a1),obj.anim_delay(a0)
	
	jsr	Random(pc)					; Set mode counter
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#5,d0
	swap	d0
	addq.b	#1,d0
	move.b	d0,obj.mode_counter(a0)
	
	divs.w	#48,d1						; Set timer
	swap	d1
	move.b	d1,obj.timer_2(a0)
	
	move.w	#2,obj.routine(a0)				; Set to float routine
	rts

; ------------------------------------------------------------------------------
; Next mode
; ------------------------------------------------------------------------------

NextTailsMode:
	bsr.w	GetObjectTargetX				; Get target X position
	cmpi.b	#3,obj.mode_counter(a0)				; Should we move vertically?
	bne.s	.MoveY						; If so, branch
	bsr.w	MoveTailsStraight				; Move straight
	bra.s	.CheckTimer

.MoveY:
	bsr.w	MoveTailsY					; Move vertically

.CheckTimer:
	tst.b	obj.mode_counter(a0)				; Has the mode counter run out?
	blt.s	.End						; If so, branch
	subq.b	#1,obj.mode_counter(a0)				; Decrement it

.End:
	rts

; ------------------------------------------------------------------------------
; Move straight
; ------------------------------------------------------------------------------

MoveTailsStraight:
	move.l	#$20000,obj.x_speed(a0)				; Move straight ahead
	move.l	#0,obj.y_speed(a0)
	
	move.w	#0,obj.anim_frame(a0)				; Set straight animation
	lea	TailsSprites(pc),a3
	move.l	a3,obj.sprites(a0)
	
	btst	#7,obj.flags(a0)				; Are we facing right?
	beq.s	.End						; If so, branch
	neg.l	obj.x_speed(a0)					; Move left
	neg.l	obj.y_speed(a0)

.End:
	move.b	#24,obj.timer_2(a0)				; Set timer
	move.w	#2,obj.routine(a0)				; Set to float routine
	rts

; ------------------------------------------------------------------------------
; Move vertically
; ------------------------------------------------------------------------------

MoveTailsY:
	move.w	#3,obj.routine(a0)				; Set to move routine
	
	jsr	Random(pc)					; Set X speed
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#16,d0
	clr.w	d0
	asr.l	#4,d0
	addi.l	#$20000,d0
	move.l	d0,obj.x_speed(a0)
	btst	#7,obj.flags(a0)
	beq.s	.GetSpeedY
	neg.l	obj.x_speed(a0)

.GetSpeedY:
	move.l	obj.y_speed(a0),d7				; Set Y speed
	divs.w	#$28,d1
	clr.w	d1
	asr.l	#4,d1
	move.l	d1,obj.y_speed(a0)
	addq.w	#1,obj.y_speed(a0)
	
	jsr	Random(pc)					; Get random target Y position
	andi.l	#$7FFF,d0
	divs.w	#56,d0
	swap	d0
	tst.l	d7						; Are we moving?
	bne.s	.CheckDirectionY				; If so, branch
	
	cmpi.w	#100,obj.y(a0)					; Are we below the center?
	bgt.s	.MoveUp						; If so, branch
	bra.s	.MoveDown					; Move down

.CheckDirectionY:
	ble.s	.MoveDown					; If we are moving up, then move down instead

.MoveUp:
	neg.l	obj.y_speed(a0)					; Move up
	addi.w	#32,d0						; Set target Y position
	move.w	d0,obj.target_y(a0)
	
	lea	TailsUpSprites(pc),a1				; Set upwards animation
	move.l	a1,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)
	bra.s	.End

.MoveDown:
	addi.w	#160,d0						; Set target Y position
	move.w	d0,obj.target_y(a0)
	
	lea	TailsDownSprites(pc),a1				; Set downwards animation
	move.l	a1,obj.sprites(a0)
	move.w	#0,obj.anim_frame(a0)

.End:
	rts

; ------------------------------------------------------------------------------
; Float
; ------------------------------------------------------------------------------

FloatTails:
	bsr.w	MoveFloatingObject				; Move
	subq.b	#1,obj.timer_2(a0)				; Decrement float time
	bgt.s	.End						; If it hasn't run out, branch
	move.w	#1,obj.routine(a0)				; Set to next mode

.End:
	rts

; ------------------------------------------------------------------------------
