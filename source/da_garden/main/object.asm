; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Find free object slot
; ------------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Found/Not found
;	a1.l  - Found object slot
; ------------------------------------------------------------------------------

	xdef SpawnObject
SpawnObject:
	lea	objects,a1					; Object slots
	move.w	#OBJECT_COUNT-1,d0				; Number of slots to check
	
.Find:
	tst.w	(a1)						; Is this slot occupied?
	beq.s	.End						; If not, exit
	lea	obj.struct_size(a1),a1				; Next slot
	dbf	d0,.Find					; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------
; Check if any objects are loaded
; ------------------------------------------------------------------------------
; RETURNS:
;	eq/ne - No objects/Objects found
; ------------------------------------------------------------------------------

	xdef CheckObjectsLoaded
CheckObjectsLoaded:
	lea	objects,a1					; Object slots
	move.w	#OBJECT_COUNT-1,d0				; Number of slots to check
	
.Check:
	tst.w	(a1)						; Is this slot occupied?
	bne.s	.End						; If so, exit
	lea	obj.struct_size(a1),a1				; Next slot
	dbf	d0,.Check					; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------
; Update objects
; ------------------------------------------------------------------------------

	xdef UpdateObjects
UpdateObjects:
	bsr.w	UpdateObjSpawns					; Update object spawns
	lea	objects,a0					; Run objects
	bsr.s	RunObjects
	bsr.w	DrawObjects					; Draw objects
	rts

; ------------------------------------------------------------------------------
; Run objects
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object pool
; ------------------------------------------------------------------------------

	xdef RunObjects
RunObjects:
	moveq	#OBJECT_COUNT-1,d7				; Number of slots
	
.Run:
	move.w	(a0),d0						; Get object ID
	beq.s	.NextObject					; If there's no object in this slot, branch
	
	movem.l	d7-a0,-(sp)					; Run object
	bsr.s	RunObject
	movem.l	(sp)+,d7-a0
	
.NextObject:
	lea	obj.struct_size(a0),a0				; Next object
	dbf	d7,.Run						; Loop until all objects are run
	rts

; ------------------------------------------------------------------------------
; Run object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Object ID
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef RunObject
RunObject:
	add.w	d0,d0						; Run object
	add.w	d0,d0
	movea.l	.Index-4(pc,d0.w),a1
	jsr	(a1)
	
	btst	#4,obj.flags(a0)				; Is this object marked for deletion?
	beq.s	.End						; If not, branch
	bsr.w	ClearObjectSlot					; If so, clear object slot
	
.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.l	FlickyObject					; Flicky
	dc.l	StarObject					; Star
	dc.l	EggmanObject					; Eggman
	dc.l	UfoObject					; UFO
	dc.l	MetalSonicObject				; Metal Sonic
	dc.l	TailsObject					; Tails
	dc.l	TrackTitleObject				; Track title
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	dc.l	NullObject					; Blank
	

; ------------------------------------------------------------------------------
; Null object
; ------------------------------------------------------------------------------

NullObject:
	rts

; ------------------------------------------------------------------------------
; Draw objects
; ------------------------------------------------------------------------------

	xdef DrawObjects
DrawObjects:
	lea	sprites,a1					; Clear first sprite slot
	clr.l	(a1)+
	clr.l	(a1)+
	
	lea	objects,a0					; Objects
	lea	sprites,a1					; Sprite table
	moveq	#0,d5						; Reset link value
	moveq	#OBJECT_COUNT-1,d7				; Number of object slots
	
.DrawLoop:
	tst.w	obj.id(a0)					; Is this object slot occupied?
	beq.w	.NextObject					; If not, branch
	
	movea.l	obj.sprites(a0),a2				; Get mappings
	bsr.w	AnimateObject					; Animation sprite
	
	move.w	obj.anim_frame(a0),d0				; Get sprite data
	add.w	d0,d0
	add.w	d0,d0
	adda.w	2+2(a2,d0.w),a2
	
	move.w	(a2)+,d6					; Get number of sprite pieces
	moveq	#$D,d3						; Unknown
	
.DrawPieces:
	moveq	#0,d4						; Reset flip flags
	
	move.w	obj.x(a0),d0					; Get object X position
	btst	#7,obj.flags(a0)				; Is the X flip flag set?
	beq.s	.NoFlipX					; If not, branch
	sub.w	6(a2),d0					; Subtract flipped X offset
	bset	#$B,d4						; Set sprite X flip flag
	bra.s	.SetX

.NoFlipX:
	sub.w	4(a2),d0					; Subtract X offset

.SetX:
	addi.w	#128,d0						; Add origin offset
	move.w	d0,6(a1)					; Set X position in sprite table
	
	move.w	obj.y(a0),d0					; Get object Y position
	btst	#6,obj.flags(a0)				; Is the Y flip flag set?
	beq.s	.NoFlipY					; If not, branch
	sub.w	$A(a2),d0					; Subtract flipped Y offset
	bset	#$C,d4						; Set sprite Y flip flag
	bra.s	.SetY

.NoFlipY:
	sub.w	8(a2),d0					; Subtract Y offset

.SetY:
	addi.w	#128,d0						; Add origin offset
	move.w	d0,0(a1)					; Set Y position in sprite table
	
	addq.w	#1,d5						; Increment link value
	move.w	d5,d0						; Combine with sprite size
	or.w	0(a2),d0
	move.w	d0,2(a1)					; Store in sprite table
	
	move.w	obj.sprite_tile(a0),d0				; Get base tile ID
	btst	#5,obj.flags(a0)				; Is the force priority flag set?
	beq.s	.SetTile					; If not, branch
	bset	#$F,d0						; If so, force priority
	
.SetTile:
	add.w	2(a2),d0					; Add sprite tile ID offset
	eor.w	d4,d0						; Apply flip flags
	move.w	d0,4(a1)					; Store in sprite table
	
	addq.l	#8,a1						; Next sprite table entry
	adda.w	#$C,a2						; Next sprite piece
	dbf	d6,.DrawPieces					; Loop until all sprite pieces are drawn
	
.NextObject:
	lea	obj.struct_size(a0),a0				; Next object
	dbf	d7,.DrawLoop					; Loop until all objects are drawn
	
	tst.w	d5						; Were any objects drawn at all?
	beq.s	.End						; If not, branch
	move.b	#0,-5(a1)					; If so, set the termination link value
	
.End:
	rts

; ------------------------------------------------------------------------------
; Animate object
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef AnimateObject
AnimateObject:
	subq.w	#1,obj.anim_delay(a0)				; Decrement animation delay
	bhi.s	.End						; If it hasn't run out, branch
	
	move.w	obj.anim_frame(a0),d0				; Increment animation frame
	addq.w	#1,d0
	cmp.w	(a2),d0						; Have we reached the end?
	bcs.s	.Update						; If not, branch
	moveq	#0,d0						; If so, loop back to the start
	
.Update:
	move.w	d0,obj.anim_frame(a0)				; Set new animation frame
	add.w	d0,d0
	add.w	d0,d0
	move.w	2(a2,d0.w),obj.anim_delay(a0)			; Reset animation delay
	
.End:
	rts

; ------------------------------------------------------------------------------
; Clear object slot
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; ------------------------------------------------------------------------------

	xdef ClearObjectSlot
ClearObjectSlot:
	movea.l	a0,a1						; Clear object slot
	moveq	#0,d1
	bra.w	Fill64

; ------------------------------------------------------------------------------
; Initialize objects
; ------------------------------------------------------------------------------

	xdef InitObjects
InitObjects:
	lea	objects,a1					; Objects
	moveq	#0,d1						; Fill with zero
	moveq	#OBJECT_COUNT-1,d0				; Number of object slots
	
.ClearLoop:
	jsr	Fill64(pc)					; Clear object slot
	dbf	d0,.ClearLoop					; Loop until all objects are cleared
	rts

; ------------------------------------------------------------------------------
