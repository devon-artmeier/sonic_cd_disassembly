; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Check object spawning
; ------------------------------------------------------------------------------

	xdef CheckObjectSpawn
CheckObjectSpawn:
	btst	#0,track_selection_flags			; Is track selection active?
	beq.s	.CheckTimers					; If not, branch
	rts

.CheckTimers:
	lea	object_spawn_timers,a2				; Spawn timers
	moveq	#OBJECT_TYPE_COUNT-1,d5				; Number of object types

.CheckTimerLoop:
	subq.w	#1,(a2)						; Decrement current timer
	bcs.s	.SpawnObject					; If it has run out, branch
	adda.w	#2,a2						; Next timer
	dbf	d5,.CheckTimerLoop				; Loop until all timers are checked
	rts

; ------------------------------------------------------------------------------

.SpawnObject:
	move.w	d5,d0						; Reset timer
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnTimes(pc,d0.w),a1
	move.w	(a1)+,(a2)
	
	movem.l	d5/a1-a2,-(sp)					; Add random value to timer
	jsr	Random(pc)
	movem.l	(sp)+,d5/a1-a2
	andi.l	#$FFFF,d0
	moveq	#0,d1
	move.w	(a1),d1
	divs.w	d1,d0
	swap	d0
	add.w	d0,(a2)
	
	move.w	d5,d0						; Spawn object
	add.w	d0,d0
	move.w	.SpawnIndex(pc,d0.w),d0
	jmp	.SpawnIndex(pc,d0.w)

; ------------------------------------------------------------------------------

.SpawnTimes:
	dc.w	300, 600
	dc.w	360, 660
	dc.w	420, 720
	dc.w	480, 780
	dc.w	540, 840
	dc.w	600, 900
	
.SpawnIndex:
	dc.w	SpawnFlickies-.SpawnIndex
	dc.w	SpawnStars-.SpawnIndex
	dc.w	SpawnUfos-.SpawnIndex
	dc.w	SpawnEggman-.SpawnIndex
	dc.w	SpawnMetalSonic-.SpawnIndex
	dc.w	SpawnTails-.SpawnIndex

; ------------------------------------------------------------------------------
; Spawn flickies
; ------------------------------------------------------------------------------

SpawnFlickies:
	btst	#0,object_spawn_flags				; Is spawn slot 0 occupied?
	beq.s	.First						; If not, branch
	btst	#1,object_spawn_flags				; Is spawn slot 1 occupied?
	beq.s	.Second						; If not, branch
	rts

.First:
	bset	#0,object_spawn_flags				; Occupy spawn slot 0
	move.b	#1,object_spawn_id
	moveq	#1,d0						; Load art
	jsr	LoadArt
	bra.s	.GetX

.Second:
	bset	#1,object_spawn_flags				; Occupy spawn slot 1
	move.b	#2,object_spawn_id
	moveq	#2,d0						; Load art
	jsr	LoadArt

.GetX:
	jsr	Random(pc)					; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromLeft
	move.l	#264,d5
	bra.s	.GetCount

.StartFromLeft:
	moveq	#-6,d5

.GetCount:
	jsr	Random(pc)					; Get core Y position
	andi.l	#$7FFF,d0
	divs.w	#160,d0
	swap	d0
	move.w	d0,d6
	addi.w	#16,d6
	
	move.w	d7,d0						; Pick spawn group
	andi.l	#$7FFF,d0
	divu.w	#4,d0
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnGroups,a2
	adda.w	d0,a2
	
	move.w	(a2)+,d2					; Get number of flickies
	move.w	(a2),d0						; Get flicky position offsets
	lea	.SpawnGroups,a2
	adda.w	d0,a2

	btst	#0,object_spawn_id				; Get sprite tile ID
	beq.s	.SecondTileId
	move.w	#$5B8,d3
	bra.s	.SpawnObjects

.SecondTileId:
	move.w	#$5DC,d3

.SpawnObjects:
	bsr.w	SpawnObject					; Spawn flicky
	bne.w	.End
	bsr.w	SpawnFlicky
	dbf	d2,.SpawnObjects				; Loop until flickies are spawned

.End:
	move.b	#0,object_spawn_id				; Reset spawn slot ID
	rts

; ------------------------------------------------------------------------------

.SpawnGroups:
	dc.w	4-1, .Group0-.SpawnGroups
	dc.w	4-1, .Group1-.SpawnGroups
	dc.w	6-1, .Group2-.SpawnGroups
	dc.w	6-1, .Group2-.SpawnGroups

.Group0:
	dc.w	 0,   0
	dc.w	-24,  8
	dc.w	-48, -8
	dc.w	-34,  20

.Group1:
	dc.w	 0,   0
	dc.w	-16, -24
	dc.w	-16,  24
	dc.w	-32,  0

.Group2:
	dc.w	 0,   0
	dc.w	-16, -22
	dc.w	-40, -28
	dc.w	-32,  16
	dc.w	-16,  24
	dc.w	-48, -5

; ------------------------------------------------------------------------------

SpawnFlicky:
	move.w	d3,obj.sprite_tile(a1)				; Set sprite tile ID
	move.b	object_spawn_id,obj.spawn_id(a1)		; Set spawn slot ID
	move.w	d5,obj.x(a1)					; Set position
	move.w	d6,obj.y(a1)
	move.w	#$30,obj.float_speed(a1)			; Set float speed
	move.w	#4,obj.float_amplitude(a1)			; Set float amplitude

	tst.w	d2						; Is this the last flicky?
	bgt.s	.Normal						; If not, branch

	jsr	Random(pc)					; Randomly determine if this flicky is normal, slow, or glides
	andi.l	#$7FFF,d0
	divs.w	#3,d0
	swap	d0
	beq.s	.Normal						; If normal, branch
	cmpi.w	#1,d0
	beq.s	.Slow						; If slow, branch
	bset	#1,obj.flags(a1)				; Mark as gliding
	move.l	#$14000,obj.x_speed(a1)				; Set velocity
	move.l	#$E000,obj.y_speed(a1)
	lea	FlickyGlideSprites(pc),a3			; Get gliding sprites
	bra.s	.Setup

.Slow:
	bset	#0,obj.flags(a1)				; Mark as slow
	move.l	#$A000,obj.x_speed(a1)				; Set velocity
	move.l	#0,obj.y_speed(a1)
	lea	FlickySlowSprites(pc),a3			; Get slow sprites
	bra.s	.Setup

.Normal:
	move.l	#$14000,obj.x_speed(a1)				; Set velocity
	move.l	#0,obj.y_speed(a1)
	lea	FlickySprites(pc),a3				; Get normal sprites

.Setup:
	move.l	a3,obj.sprites(a1)				; Set sprites
	move.w	2(a3),obj.anim_delay(a1)			; Set initial animation delay

	bset	#3,obj.flags(a1)				; Mark as facing right
	move.w	#1,(a1)						; Set object ID
	move.w	(a2)+,d0					; Get X offset
	tst.w	d7						; Is the Flicky moving from the left side of the screen?
	bge.s	.SetOffset					; If so, branch
	bset	#7,obj.flags(a1)				; Mark as facing left
	bclr	#3,obj.flags(a1)
	neg.w	d0						; Move left
	neg.l	obj.x_speed(a1)

.SetOffset:
	add.w	d0,obj.x(a1)					; Set X offset
	move.w	(a2)+,d0					; Set Y offset
	add.w	d0,obj.y(a1)
	rts

; ------------------------------------------------------------------------------
; Spawn stars
; ------------------------------------------------------------------------------

SpawnStars:
	cmpi.w	#$A,palette_cycle_frame				; Is it night?
	ble.w	.End						; If not, branch
	cmpi.w	#$18,palette_cycle_frame
	bge.w	.End						; If not, branch

	btst	#0,object_spawn_flags				; Is spawn slot 0 occupied?
	beq.s	.First						; If not, branch
	btst	#1,object_spawn_flags				; Is spawn slot 1 occupied?
	beq.s	.Second						; If not, branch
	rts

.First:
	bset	#0,object_spawn_flags				; Occupy spawn slot 0
	move.b	#1,object_spawn_id
	moveq	#3,d0						; Load art
	jsr	LoadArt
	bra.s	.Spawn

.Second:
	bset	#1,object_spawn_flags				; Occupy spawn slot 1
	move.b	#2,object_spawn_id
	moveq	#4,d0						; Load art
	jsr	LoadArt

.Spawn:
	jsr	Random(pc)					; Get spawn group ID
	move.w	d0,d7

	moveq	#0,d3						; Move right
	jsr	Random(pc)					; Get core X position within left side of the screen
	andi.l	#$7FFF,d0
	divs.w	#128,d0
	swap	d0
	move.w	d0,d5
	addi.w	#0,d5
	cmpi.w	#128,d5						; Is the core X position on the right side of the screen (never happens)?
	bgt.s	.GetTileId					; If so, branch
	moveq	#1,d3						; Move left

.GetTileId:
	moveq	#0,d6						; Get core Y position

	btst	#0,object_spawn_id				; Get sprite tile ID
	beq.s	.SecondTileId
	move.w	#$5B8,d1
	bra.s	.GetCount

.SecondTileId:
	move.w	#$5DC,d1

.GetCount:
	move.w	d7,d0						; Pick spawn group
	andi.l	#$7FFF,d0
	divu.w	#5,d0
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnGroups(pc,d0.w),a2

	move.w	(a2)+,d2					; Get number of stars
	move.w	(a2),d0						; Get star position offsets
	lea	.SpawnGroups(pc,d0.w),a2

.SpawnObjects:
	bsr.w	SpawnObject					; Spawn star
	bne.w	.End
	bsr.w	SpawnStar
	dbf	d2,.SpawnObjects				; Loop until stars are spawned

.End:
	move.b	#0,object_spawn_id				; Reset spawn slot ID
	rts

; ------------------------------------------------------------------------------

.SpawnGroups:
	dc.w	3-1, .Group0-.SpawnGroups
	dc.w	3-1, .Group0-.SpawnGroups
	dc.w	2-1, .Group0-.SpawnGroups
	dc.w	1-1, .Group0-.SpawnGroups
	dc.w	3-1, .Group0-.SpawnGroups
	
.Group0:
	; BUG: this second column should not exist
	dc.w	 0,  0
	dc.w	 32, 0
	dc.w	-32, 0

; ------------------------------------------------------------------------------

SpawnStar:
	move.w	#2,obj.id(a1)					; Set object ID
	move.w	d1,obj.sprite_tile(a1)				; Set sprite tile ID
	move.b	object_spawn_id,obj.spawn_id(a1)		; Set spawn slot ID
	move.w	d5,obj.x(a1)					; Set position
	move.w	d6,obj.y(a1)
	
	move.l	#$20000,obj.x_speed(a1)				; Move right
	tst.w	d3						; Are the stars set to move right?
	beq.s	.GetYVel					; If so, branch
	neg.l	obj.x_speed(a1)					; Move left

.GetYVel:
	jsr	Random(pc)					; Set Y velocity
	andi.l	#$7FFF,d0
	divs.w	#$80,d0
	andi.l	#$7FFF0000,d0
	asr.l	#4,d0
	move.l	#$40000,obj.y_speed(a1)
	add.l	d0,obj.y_speed(a1)

	jsr	Random(pc)					; Add random X offset
	andi.l	#$7FFF,d0
	divs.w	#240,d0
	swap	d0
	add.w	d0,obj.x(a1)

	move.w	(a2)+,d0					; Add Y offset
	add.w	d0,obj.y(a1)
	rts

; ------------------------------------------------------------------------------
; Spawn UFOs
; ------------------------------------------------------------------------------

SpawnUfos:
	nop
	btst	#0,object_spawn_flags				; Is spawn slot 0 occupied?
	beq.s	.First						; If not, branch
	btst	#1,object_spawn_flags				; Is spawn slot 1 occupied?
	beq.s	.Second						; If not, branch
	rts

.First:
	bset	#0,object_spawn_flags				; Occupy spawn slot 0
	move.b	#1,object_spawn_id
	moveq	#5,d0						; Load art
	jsr	LoadArt
	bra.s	.GetX

.Second:
	bset	#1,object_spawn_flags				; Occupy spawn slot 1
	move.b	#2,object_spawn_id
	moveq	#6,d0						; Load art
	jsr	LoadArt

.GetX:
	jsr	Random(pc)					; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromLeft
	move.l	#264,d5
	bra.s	.GetTileId

.StartFromLeft:
	moveq	#-6,d5

.GetTileId:
	jsr	Random(pc)					; Get core Y position
	andi.l	#$7FFF,d0
	divs.w	#160,d0
	swap	d0
	move.w	d0,d6
	addi.w	#16,d6

	btst	#0,object_spawn_id				; Get sprite tile ID
	beq.s	.SecondTileId
	move.w	#$5B8,d1
	bra.s	.GetCount

.SecondTileId:
	move.w	#$5DC,d1

.GetCount:
	move.w	d7,d0						; Pick spawn group
	andi.l	#$7FFF,d0
	divu.w	#5,d0
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.SpawnGroups(pc,d0.w),a2

	move.w	(a2)+,d2					; Get number of UFOs
	move.w	(a2),d0						; Get UFO position offsets
	lea	.SpawnGroups(pc,d0.w),a2

.SpawnObjects:
	bsr.w	SpawnObject					; Spawn UFO
	bne.w	.End

	move.w	d1,obj.sprite_tile(a1)				; Set tile ID
	move.b	object_spawn_id,obj.spawn_id(a1)		; Set spawn slot ID
	move.w	d5,obj.x(a1)					; Set position
	move.w	d6,obj.y(a1)
	move.w	#$28,obj.float_speed(a1)			; Set float speed
	move.w	#6,obj.float_amplitude(a1)			; Set float amplitude
	move.l	#$20000,obj.x_speed(a1)				; Set velocity
	move.l	#0,obj.y_speed(a1)
	bset	#3,obj.flags(a1)				; Mark as facing right
	move.w	#4,obj.id(a1)					; Set object ID

	move.w	(a2)+,d0					; Get X offset
	
	tst.w	d7						; Is the UFO moving from the left side of the screen?
	bge.s	.SetPosOffset					; If so, branch
	
	bset	#7,obj.flags(a1)				; Mark as facing left
	bclr	#3,obj.flags(a1)
	
	neg.w	d0						; Move left
	neg.l	obj.x_speed(a1)
	neg.l	obj.y_speed(a1)

.SetPosOffset:
	add.w	d0,obj.x(a1)					; Set X offset
	move.w	(a2)+,d0					; Set Y offset
	add.w	d0,obj.y(a1)

	dbf	d2,.SpawnObjects				; Loop until UFOs are spawned

.End:
	move.b	#0,object_spawn_id				; Reset spawn slot ID
	rts

; ------------------------------------------------------------------------------

.SpawnGroups:
	dc.w	1-1, .Group0-.SpawnGroups
	dc.w	2-1, .Group0-.SpawnGroups
	dc.w	1-1, .Group0-.SpawnGroups
	dc.w	2-1, .Group0-.SpawnGroups
	dc.w	1-1, .Group0-.SpawnGroups
	
.Group0:
	dc.w	0,  0
	dc.w	16, 48

; ------------------------------------------------------------------------------
; Spawn Eggman
; ------------------------------------------------------------------------------

SpawnEggman:
	btst	#0,object_spawn_flags				; Is spawn slot 0 occupied?
	bne.w	.End						; If so, branch
	btst	#1,object_spawn_flags				; Is spawn slot 1 occupied?
	bne.w	.End						; If so, branch
	bset	#0,object_spawn_flags				; Occupy both spawn slots
	bset	#1,object_spawn_flags
	move.b	#%11,object_spawn_id

	moveq	#7,d0						; Load art
	jsr	LoadArt

	jsr	Random(pc)					; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromRight
	moveq	#-6,d5
	bra.s	.SpawnObject

.StartFromRight:
	move.l	#264,d5

.SpawnObject:
	jsr	Random(pc)					; Get Y position
	andi.l	#$7FFF,d0
	divs.w	#64,d0
	swap	d0
	move.w	d0,d6
	addi.w	#128,d6

	bsr.w	SpawnObject					; Spawn Eggman
	bne.w	.End
	
	move.w	#$5B8,obj.sprite_tile(a1)			; Set sprite tile ID
	move.b	object_spawn_id,obj.spawn_id(a1)		; Set spawn slot ID
	move.w	d5,obj.x(a1)					; Set position
	move.w	d6,obj.y(a1)
	move.w	#$28,obj.float_speed(a1)			; Set float speed
	move.w	#$A,obj.float_amplitude(a1)			; Set float amplitude
	move.l	#-$14000,obj.x_speed(a1)			; Set velocity
	move.l	#-$8000,obj.y_speed(a1)
	move.w	#3,obj.id(a1)					; Set object ID
	
	tst.w	d7						; Is Eggman moving from the right side of the screen?
	bge.s	.End						; If so, branch
	
	bset	#7,obj.flags(a1)				; Mark as facing right
	neg.l	obj.x_speed(a1)					; Move right

.End:
	move.b	#0,object_spawn_id				; Reset spawn slot ID
	rts

; ------------------------------------------------------------------------------
; Spawn Metal Sonic
; ------------------------------------------------------------------------------

SpawnMetalSonic:
	btst	#0,object_spawn_flags				; Is spawn slot 0 occupied?
	bne.w	.End						; If so, branch
	btst	#1,object_spawn_flags				; Is spawn slot 1 occupied?
	bne.w	.End						; If so, branch
	bset	#0,object_spawn_flags				; Occupy both spawn slots
	bset	#1,object_spawn_flags
	move.b	#%11,object_spawn_id

	moveq	#8,d0						; Load art
	jsr	LoadArt

	jsr	Random(pc)					; Get X position and vertical side of screen to spawn from
	move.w	d0,d7
	andi.l	#$7FFF,d0
	divs.w	#$100,d0
	swap	d0
	move.w	d0,d5
	tst.w	d7
	bge.s	.StartFromRight
	move.w	#0,d6
	bra.s	.SpawnObject

.StartFromRight:
	move.w	#192,d6

.SpawnObject:
	bsr.w	SpawnObject					; Spawn Metal Sonic
	bne.w	.End
	
	move.w	#$5B8,obj.sprite_tile(a1)			; Set sprite tile ID
	move.b	object_spawn_id,obj.spawn_id(a1)		; Set spawn slot ID
	move.w	d5,obj.x(a1)					; Set position
	move.w	d6,obj.y(a1)
	move.w	#$28,obj.float_speed(a1)			; Set float speed
	move.w	#4,obj.float_amplitude(a1)			; Set float amplitude
	move.l	#$40000,obj.x_speed(a1)				; Set velocity
	move.l	#$50000,obj.y_speed(a1)
	bset	#3,obj.flags(a1)				; Mark as moving down
	move.w	#5,obj.id(a1)					; Set object ID

	cmpi.w	#128,obj.x(a1)					; Is Metal Sonic on the left side of the screen?
	blt.s	.CheckYDir					; If so, branch
	
	bset	#7,obj.flags(a1)				; Face left
	neg.l	obj.x_speed(a1)					; Move left

.CheckYDir:
	cmpi.w	#100,obj.y(a1)					; Is Metal Sonic spawning from the top of the screen?
	blt.s	.End						; If so, branch
	
	bclr	#3,obj.flags(a1)				; Mark as moving up
	neg.l	obj.y_speed(a1)					; Move up

.End:
	move.b	#0,object_spawn_id				; Reset spawn slot ID
	rts

; ------------------------------------------------------------------------------

	; Unknown
	dc.w	32
	dc.w	224

; ------------------------------------------------------------------------------
; Spawn Tails
; ------------------------------------------------------------------------------

SpawnTails:
	nop
	btst	#0,object_spawn_flags				; Is spawn slot 0 occupied?
	bne.w	.End						; If so, branch
	btst	#1,object_spawn_flags				; Is spawn slot 1 occupied?
	bne.w	.End						; If so, branch
	bset	#0,object_spawn_flags				; Occupy both spawn slots
	bset	#1,object_spawn_flags
	move.b	#%11,object_spawn_id

	moveq	#9,d0						; Load art
	jsr	LoadArt

	jsr	Random(pc)					; Pick horizontal side to spawn from
	move.w	d0,d7
	tst.w	d7
	bge.s	.StartFromLeft
	move.l	#264,d5
	bra.s	.SpawnObject

.StartFromLeft:
	moveq	#-6,d5

.SpawnObject:
	jsr	Random(pc)					; Get Y position
	andi.l	#$7FFF,d0
	divs.w	#160,d0
	swap	d0
	move.w	d0,d6
	addi.w	#32,d6

	bsr.w	SpawnObject
	bne.w	.End
	
	move.w	#$5B8,obj.sprite_tile(a1)			; Set sprite tile ID
	move.b	object_spawn_id,obj.spawn_id(a1)		; Set spawn slot ID
	move.w	d5,obj.x(a1)					; Set position
	move.w	d6,obj.y(a1)
	move.w	#$24,obj.float_speed(a1)			; Set float speed
	move.w	#2,obj.float_amplitude(a1)			; Set float amplitude
	move.l	#$20000,obj.x_speed(a1)				; Set velocity
	move.l	#0,obj.y_speed(a1)
	move.w	#6,obj.id(a1)					; Set object ID

	tst.w	d7						; Is Tails spawning from the left side of the screen?
	bge.s	.End						; If so, branch
	
	bset	#7,obj.flags(a1)				; Mark as facing left
	neg.l	obj.x_speed(a1)					; Move left
	neg.l	obj.y_speed(a1)

.End:
	move.b	#0,object_spawn_id				; Reset spawn slot ID
	rts

; ------------------------------------------------------------------------------
