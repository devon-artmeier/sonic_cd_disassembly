; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Run object routine
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
;	a1.l - Pointer to routine table
; ------------------------------------------------------------------------------

	xdef RunObjectRoutine
RunObjectRoutine:
	move.w	obj.routine(a0),d0				; Run routine
	add.w	d0,d0
	adda.w	(a1,d0.w),a1
	jmp	(a1)

; ------------------------------------------------------------------------------
; Delete object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef DeleteObject
DeleteObject:
	move.b	obj.spawn_id(a0),d0				; Stop occupying spawn slot
	eor.b	d0,object_spawn_flags
	bset	#4,obj.flags(a0)				; Mark for deletion
	rts

; ------------------------------------------------------------------------------
; Delete object from group
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef DeleteObjectFromGroup
DeleteObjectFromGroup:
	move.w	obj.id(a0),d0					; Get object ID and clear it
	move.w	#0,obj.id(a0)

	lea	objects,a1					; Object slots
	moveq	#OBJECT_COUNT-1,d7				; Number of object slots

.Find:
	cmp.w	obj.id(a1),d0					; Does this object have the same ID?
	beq.s	.Found						; If so, branch
	lea	obj.struct_size(a1),a1				; Next object
	dbf	d7,.Find					; Loop until all objects are checked
	
	move.b	obj.spawn_id(a0),d1				; If this was the last in the group, stop occupying spawn slot
	eor.b	d1,object_spawn_flags

.Found:
	bset	#4,obj.flags(a0)				; Mark for deletion
	rts

; ------------------------------------------------------------------------------
; Check if an object is offscreen
; ------------------------------------------------------------------------------
; PARAMETERS:
;	eq/ne - Not offscreen/Offscreen
;	a0.l  - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef CheckObjectOffscreen
CheckObjectOffscreen:
	cmpi.w	#-80,obj.x(a0)					; Are we past the left side?
	ble.s	.Offscreen					; If so, branch
	cmpi.w	#336,obj.x(a0)					; Are we past the rigjt side?
	bge.s	.Offscreen					; If so, branch
	cmpi.w	#-5,obj.y(a0)					; Are we past the top side?
	ble.s	.Offscreen					; If so, branch
	cmpi.w	#224,obj.y(a0)					; Are we past the bottom side?
	bge.s	.Offscreen					; If so, branch

	moveq	#0,d0						; Not offscreen
	rts

.Offscreen:
	moveq	#1,d0						; Offscreen
	rts

; ------------------------------------------------------------------------------
; Find object by ID
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w  - Object ID
;	a0.l  - Pointer to object slot
; RETURNS:
;	eq/ne - Not found/Found
;	a1.l  - Found pointer to object slot
; ------------------------------------------------------------------------------

	xdef FindObjectById
FindObjectById:
	lea	objects,a1					; Object slots
	move.w	#OBJECT_COUNT-1,d7				; Number of object slots

.Find:
	cmp.w	(a1),d0						; Does this object use this ID?
	bne.s	.NextObject					; If not, branch
	cmpa.w	a0,a1						; Is this object slot ours?
	bne.s	.End						; If not, branch

.NextObject:
	lea	obj.struct_size(a1),a1				; Next object
	dbf	d7,.Find					; Loop until all objects are checked
	
	moveq	#0,d0						; Not found

.End:
	rts

; ------------------------------------------------------------------------------
; Move floating object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef MoveFloatingObject
MoveFloatingObject:
	bsr.w	CheckObjectOffscreen				; Are we offscreen?
	bne.w	DeleteObjectFromGroup				; If so, delete object

	move.w	obj.y_offset(a0),d0				; Apply Y offset
	sub.w	d0,obj.y(a0)

	move.w	obj.float_angle(a0),d3				; Update Y offset
	jsr	CalcSine(pc)
	move.w	obj.float_amplitude(a0),d0
	muls.w	d0,d3
	asr.l	#8,d3
	move.w	d3,obj.y_offset(a0)
	add.w	d3,obj.y(a0)

	jsr	Random(pc)					; Increment float angle
	andi.l	#$7FFF,d0
	move.w	obj.float_speed(a0),d1
	divs.w	d1,d0
	swap	d0
	add.w	d0,obj.float_angle(a0)
	
	cmpi.w	#$1FF,obj.float_angle(a0)
	blt.s	.GetSpeedX
	subi.w	#$1FF,obj.float_angle(a0)

.GetSpeedX:
	move.l	obj.x_speed(a0),d0				; Get X velocity
	tst.b	track_selection_flags				; Is track selection active?
	beq.s	.MoveX						; If not, branch
	asl.l	#3,d0						; If, so, go 8 times as fast

.MoveX:
	add.l	d0,obj.x(a0)					; Move X position
	move.l	obj.y_speed(a0),d1				; Move Y position
	add.l	d1,obj.y(a0)
	rts

; ------------------------------------------------------------------------------
