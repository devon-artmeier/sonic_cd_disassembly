; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; Star object
; ------------------------------------------------------------------------------

	xdef StarObject
StarObject:
	lea	.Index,a1					; Run routine
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitStar-.Index
	dc.w	UpdateStar-.Index

; ------------------------------------------------------------------------------
; Initialize
; ------------------------------------------------------------------------------

InitStar:
	addi.w	#$4000,obj.sprite_tile(a0)			; Set to sprite palette
	
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	lea	StarSprites(pc),a1
	move.l	a1,obj.sprites(a0)
	move.w	2(a1),obj.anim_delay(a0)
	
	clr.w	obj.x_offset(a0)				; Reset position offset
	clr.w	obj.y_offset(a0)

	move.w	#1,obj.routine(a0)				; Set to main routine
	rts

; ------------------------------------------------------------------------------
; Update
; ------------------------------------------------------------------------------

UpdateStar:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObjectFromGroup				; If so, delete object
	
	bra.s	.SkipFloat					; Stars don't float

	move.w	obj.y_offset(a0),d0				; Apply Y offset		
	sub.w	d0,obj.y(a0)
	
	move.w	obj.float_angle(a0),d3				; Update Y offset
	jsr	CalcSine(pc)
	muls.w	#10,d3
	asr.l	#8,d3
	move.w	d3,obj.y_offset(a0)
	add.w	d3,obj.y(a0)

.SkipFloat:
	jsr	Random(pc)					; Increment float angle
	andi.l	#$7FFF,d0
	divs.w	#$28,d0
	swap	d0
	add.w	d0,obj.float_angle(a0)
	cmpi.w	#$1FF,obj.float_angle(a0)
	blt.s	.Move
	subi.w	#$1FF,obj.float_angle(a0)

.Move:
	move.l	obj.x_speed(a0),d0				; Move
	add.l	d0,obj.x(a0)
	move.l	obj.y_speed(a0),d0
	add.l	d0,obj.y(a0)
	rts

; ------------------------------------------------------------------------------
