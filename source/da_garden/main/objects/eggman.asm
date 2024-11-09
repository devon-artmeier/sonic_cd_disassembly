; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; Eggman object
; ------------------------------------------------------------------------------

	xdef EggmanObject
EggmanObject:
	lea	.Index,a1					; Run routine
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitEggman-.Index
	dc.w	UpdateEggman-.Index

; ------------------------------------------------------------------------------
; Initialize
; ------------------------------------------------------------------------------

InitEggman:
	addi.w	#$4000,obj.sprite_tile(a0)			; Set to sprite palette
	
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	lea	EggmanSprites(pc),a1
	move.l	a1,obj.sprites(a0)
	move.w	2(a1),obj.anim_delay(a0)
	
	clr.w	obj.x_offset(a0)				; Reset position offset
	clr.w	obj.y_offset(a0)
	
	move.b	#3,obj.timer(a0)				; Set face timer
	move.w	#1,obj.routine(a0)				; Set to main routine
	rts

; ------------------------------------------------------------------------------
; Update
; ------------------------------------------------------------------------------

UpdateEggman:
	tst.b	obj.timer(a0)					; Has the face timer run out?
	ble.s	.CheckHeadTurn					; If not, branch
	subq.b	#1,obj.timer(a0)				; Decrement timer
	bgt.s	.Move						; If it hasn't run out, branch
	
	lea	EggmanSprites(pc),a3				; Turn our head back
	move.l	a3,obj.sprites(a0)

.CheckHeadTurn:
	jsr	Random(pc)					; Should we turn our head?
	andi.l	#$7FFF,d0
	move.w	d0,d1
	divs.w	#16,d0
	swap	d0
	tst.w	d0
	bne.s	.Move						; If not, branch
	
	divs.w	#16,d1						; Set face timer
	swap	d1
	addi.w	#32,d1
	move.b	d1,obj.timer(a0)
	
	lea	EggmanTurnSprites(pc),a3			; Turn head
	move.l	a3,obj.sprites(a0)

.Move:
	bsr.w	MoveFloatingObject				; Move and float
	rts

; ------------------------------------------------------------------------------
