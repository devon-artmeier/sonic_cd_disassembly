; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Run objects
; ------------------------------------------------------------------------------

	xdef RunObjects
RunObjects:
	lea	objects,a0					; Object pool
	moveq	#OBJECT_COUNT-1,d7				; Number of objects

.RunLoop:
	tst.b	obj.active(a0)					; Is this slot active?
	beq.s	.NextObjectRun					; If not, branch

	move.l	d7,-(sp)					; Run object
	jsr	RunObject
	move.l	(sp)+,d7

	btst	#1,obj.flags(a0)				; Should the global Y speed be applied?
	beq.s	.NextObjectRun					; If not, branch
	
	moveq	#0,d0						; Apply global Y speed
	move.w	global_object_y_speed,d0
	swap	d0
	sub.l	d0,obj.y(a0)

.NextObjectRun:
	lea	obj.struct_size(a0),a0				; Next object
	dbf	d7,.RunLoop					; Loop until all objects are run

	lea	objects_end-obj.struct_size,a0			; Start from the bottom of the object pool
	moveq	#OBJECT_COUNT-1,d7				; Number of objects

.DrawLoop:
	tst.b	obj.active(a0)					; Is this slot active?
	beq.s	.NextObjectDraw					; If not, branch
	btst	#0,obj.flags(a0)				; Is this object set to be drawn?
	beq.s	.NextObjectDraw					; If not, branch
	
	bsr.w	DrawObject					; Draw object

.NextObjectDraw:
	lea	-obj.struct_size(a0),a0				; Next object
	dbf	d7,.DrawLoop					; Loop until all objects are drawn
	rts

; ------------------------------------------------------------------------------
; Run an object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef RunObject
RunObject:
	moveq	#$FFFFFFFF,d0					; Run object
	move.w	obj.addr(a0),d0
	movea.l	d0,a1
	jmp	(a1)

; ------------------------------------------------------------------------------
; Spawn an object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to object code
; RETURNS:
;	eq/ne - Object slot not found/Found
;	a1.l  - Found object slot
; ------------------------------------------------------------------------------

	xdef SpawnObject
SpawnObject:
	moveq	#-1,d0						; Active flag
	lea	objects,a1					; Object pool
	moveq	#OBJECT_COUNT-1,d2				; Number of objects

.FindSlot:
	tst.b	obj.active(a1)					; Is this slot active?
	beq.s	.Found						; If not, branch
	lea	obj.struct_size(a1),a1				; Next object slot
	dbf	d2,.FindSlot					; Loop until all slots are checked

.NotFound:
	ori	#1,ccr						; Object slot not found
	rts

.Found:
	move.b	d0,obj.active(a1)				; Set active flag
	move.w	a2,obj.addr(a1)					; Set code address
	rts

; ------------------------------------------------------------------------------
; Clear objects
; ------------------------------------------------------------------------------

	xdef ClearObjects
ClearObjects:
	lea	objects,a0					; Clear object data
	
	ifle OBJECT_COUNT-8
		moveq	#(objects_end-objects)/4-1,d7
	else
		move.l	#(objects_end-objects)/4-1,d7
	endif

.ClearObjects:
	clr.l	(a0)+
	dbf	d7,.ClearObjects
	ifne (objects_end-objects)&2
		clr.w	(a0)+
	endif
	ifne (objects_end-objects)&1
		clr.b	(a0)+
	endif
	rts

; ------------------------------------------------------------------------------
; Set object bookmark and exit
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef BookmarkObject
BookmarkObject:
	move.l	(sp)+,d0					; Set bookmark and exit
	move.w	d0,obj.addr(a0)
	rts

; ------------------------------------------------------------------------------
; Set object bookmark and continue
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef BookmarkObjectContinue
BookmarkObjectContinue:
	; BUG: Overwrites object slot pointer
	move.l	(sp)+,d0					; Set bookmark
	move.w	d0,obj.addr(a0)
	movea.l	d0,a0
	jmp	(a0)						; Go back to object code

; ------------------------------------------------------------------------------
; Set object address
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
;	a1.l - Pointer to object code
; ------------------------------------------------------------------------------

	xdef SetObjectAddress
SetObjectAddress:
	; BUG: Writes longword when it should've been truncated to a word
	move.l	a1,obj.addr(a0)					; Set object address
	rts

; ------------------------------------------------------------------------------
; Delete object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef DeleteObject
DeleteObject:
	; BUG: It advances a0, but doesn't restore it, so when it exits
	; back to RunObjects, it'll skip the object after this one
	moveq	#obj.struct_size/4-1,d0				; Clear object

.Clear:
	clr.l	(a0)+
	dbf	d0,.Clear
	ifne obj.struct_size&2
		clr.w	(a0)+
	endif
	ifne obj.struct_size&1
		clr.b	(a0)+
	endif
	rts

; ------------------------------------------------------------------------------
; Clear sprites
; ------------------------------------------------------------------------------

	xdef ClearSprites
ClearSprites:
	lea	sprites,a0					; Clear sprite buffer
	moveq	#(64*8)/4-1,d0					; H32 mode only allows 64 sprites

.Clear:
	clr.l	(a0)+
	dbf	d0,.Clear

	move.b	#1,sprite_count					; Reset sprite count
	lea	sprites,a0					; Reset sprite slot
	move.l	a0,cur_sprite_slot
	rts

; ------------------------------------------------------------------------------
; Draw an object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef DrawObject
DrawObject:
	move.l	d7,-(sp)					; Save d7

	move.w	obj.x(a0),d4					; Get X position
	move.w	obj.y(a0),d3					; Get Y position
	addi.w	#128,d4						; Add screen origin point
	addi.w	#128,d3
	move.w	obj.sprite_tile(a0),d5				; Get base sprite tile ID
	
	movea.l	obj.sprites(a0),a3				; Get pointer to sprite frame
	moveq	#0,d0
	move.b	obj.sprite_frame(a0),d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	lea	(a3,d0.w),a4
	
	movea.l	cur_sprite_slot,a5				; Get current sprite slot

	move.b	(a4)+,d7					; Get sprite count
	beq.s	.End						; If there are no sprites, branch
	subq.b	#1,d7						; Subtract 1 for loop

.DrawLoop:
	cmpi.b	#64,sprite_count				; Are there too many sprites?
	bcc.s	.End						; If so, branch

	move.b	(a4)+,d0					; Set sprite Y position
	ext.w	d0
	add.w	d3,d0
	move.w	d0,(a5)+

	move.b	(a4)+,(a5)+					; Set sprite size
	move.b	sprite_count,(a5)+				; Set sprite link
	addq.b	#1,sprite_count					; Increment sprite count

	move.b	(a4)+,d0					; Get sprite tile ID
	lsl.w	#8,d0
	move.b	(a4)+,d0
	add.w	d5,d0

	move.w	d0,d6						; Does this sprite point to the solid tiles?
	andi.w	#$7FF,d6
	cmpi.w	#$BC20/$20,d6
	bne.s	.SetSpriteTile					; If not, branch
	subi.w	#$2000,d0					; Decrement palette line

.SetSpriteTile:
	move.w	d0,(a5)+					; Set sprite tile ID

	move.b	(a4)+,d0					; Get sprite X position
	ext.w	d0
	add.w	d4,d0
	andi.w	#$1FF,d0
	bne.s	.SetSpriteX					; If it's not 0, branch
	addq.w	#1,d0						; Keep it away from 0

.SetSpriteX:
	move.w	d0,(a5)+					; Set sprite X position
	dbf	d7,.DrawLoop					; Loop until all sprites are drawn

.End:
	move.l	a5,cur_sprite_slot				; Update current sprite slot
	move.l	(sp)+,d7					; Restore d7
	rts

; ------------------------------------------------------------------------------
