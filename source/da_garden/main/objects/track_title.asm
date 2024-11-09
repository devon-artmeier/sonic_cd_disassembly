; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------

TrackTitleObject:
	lea	.Index,a1			; Run routine
	lea	trackSelData.w,a2
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	TrackTitleObject_Init-.Index
	dc.w	TrackTitleObject_Enter-.Index
	dc.w	TrackTitleObject_Wait-.Index
	dc.w	TrackTitleObject_Exit-.Index

; ------------------------------------------------------------------------------

TrackTitleObject_Init:
	move.w	#0,oAnimFrame(a0)			; Reset animation
	move.w	trkSelID(a2),d0
	add.w	d0,d0
	lea	MapSpr_TrackTitle,a1
	move.w	(a1,d0.w),d1
	lea	(a1,d1.w),a1
	move.l	a1,oMap(a0)
	
	btst	#0,trkSelDir(a2)			; Are we entering from the right?
	beq.s	.EnterFromRight				; If so, branch
	move.w	#-128,oX(a0)				; Set at left side of the screen
	move.l	#$200000,oXVel(a0)			; Move right
	bset	#3,oFlags(a0)
	bra.s	.SetUp

.EnterFromRight:
	move.w	#256,oX(a0)				; Set at right side of the screen
	move.l	#-$200000,oXVel(a0)			; Move left
	bclr	#3,oFlags(a0)

.SetUp:
	move.w	#208,oY(a0)				; Set Y position
	
	lea	TrackInfo,a1				; Set X offset
	move.w	d0,d1
	add.w	d1,d1
	move.w	2(a1,d1.w),d2
	move.w	d2,oXOffset(a0)
	
	addi.w	#$E000,oTile(a0)			; Set to selection menu palette
	move.w	#1,oRoutine(a0)				; Set to enter routine
	move.w	#0,trkSelRout(a2)			; Reset track selection routine
	rts

; ------------------------------------------------------------------------------

TrackTitleObject_Enter:
	move.l	oXVel(a0),d0				; Move
	add.l	d0,oX(a0)
	
	move.w	oX(a0),d0				; Get X position
	btst	#3,oFlags(a0)				; Are we entering in from the right?
	bne.s	.EnterFromRight				; If so, branch
	cmp.w	oXOffset(a0),d0				; Are we at the destination?
	bgt.s	.End					; If not, branch
	bra.s	.Stop

.EnterFromRight:
	cmp.w	oXOffset(a0),d0				; Are we at the destination?
	blt.s	.End					; If not, branch

.Stop:
	clr.l	oXVel(a0)				; Stop
	move.w	oXOffset(a0),oX(a0)
	move.w	#2,oRoutine(a0)				; Set to wait routine

.End:
	rts

; ------------------------------------------------------------------------------

TrackTitleObject_Wait:
	btst	#3,ctrlHold				; Has right been pressed?
	beq.s	.CheckLeft				; If not, branch
	move.w	#3,oRoutine(a0)				; Set to exit routine
	move.l	#$200000,oXVel(a0)			; Move right
	bset	#3,oFlags(a0)				; Mark as moving right

.CheckLeft:
	btst	#2,ctrlHold				; Has left been pressed?
	beq.s	.End					; If not, branch
	move.l	#-$200000,oXVel(a0)			; Move left
	move.w	#3,oRoutine(a0)				; Set to exit routine
	bclr	#3,oFlags(a0)				; Mark as moving left

.End:
	rts

; ------------------------------------------------------------------------------

TrackTitleObject_Exit:
	move.l	oXVel(a0),d0				; Move
	add.l	d0,oX(a0)
	
	btst	#3,oFlags(a0)				; Are we exiting to the right?
	bne.s	.ExitRight				; If so, branch

.ExitLeft:
	cmpi.w	#-$80,oX(a0)				; Are we offscreen?
	bgt.s	.End					; If not, branch
	
	bset	#2,trackSelFlags.w			; Mark as spawning
	bclr	#0,trkSelDir(a2)			; Spawn new title track from the right
	move.b	oSpawnID(a0),d0				; Delete this title track object
	eor.b	d0,objSpawnFlags.w
	bset	#4,oFlags(a0)
	
	addq.w	#1,trkSelID(a2)				; Increment track ID
	move.w	trkSelID(a2),d0				; Should it wrap?
	cmpi.w	#TRACKCNT-1,d0
	ble.s	.End					; If not, branch
	move.w	#0,trkSelID(a2)				; If so, wrap it
	bra.s	.End

.ExitRight:
	cmpi.w	#$120,oX(a0)				; Are we offscreen?
	blt.s	.End					; If not, branch
	
	bset	#2,trackSelFlags.w			; Mark as spawning
	bset	#0,trkSelDir(a2)			; Spawn new title track from the left
	move.b	oSpawnID(a0),d0				; Delete this title track object
	eor.b	d0,objSpawnFlags.w
	bset	#4,oFlags(a0)
	
	subq.w	#1,trkSelID(a2)				; Decrement track ID
	bge.s	.End					; If it shouldn't wrap, branch
	move.w	#TRACKCNT-1,trkSelID(a2)		; Wrap it

.End:
	rts

; ------------------------------------------------------------------------------
