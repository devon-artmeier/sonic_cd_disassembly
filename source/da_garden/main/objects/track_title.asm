; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code
	
; ------------------------------------------------------------------------------

	xdef TrackTitleObject
TrackTitleObject:
	lea	.Index,a1					; Run routine
	lea	track_data,a2
	jmp	RunObjectRoutine

; ------------------------------------------------------------------------------

.Index:
	dc.w	InitTrackTitle-.Index
	dc.w	EnterTrackTitle-.Index
	dc.w	WaitTrackSelection-.Index
	dc.w	ExitTrackTitle-.Index

; ------------------------------------------------------------------------------

InitTrackTitle:
	move.w	#0,obj.anim_frame(a0)				; Reset animation
	move.w	track.selection_id(a2),d0
	add.w	d0,d0
	lea	TrackTitleSprites,a1
	move.w	(a1,d0.w),d1
	lea	(a1,d1.w),a1
	move.l	a1,obj.sprites(a0)
	
	btst	#0,track.direction(a2)				; Are we entering from the right?
	beq.s	.EnterFromRight					; If so, branch
	
	move.w	#-128,obj.x(a0)					; Set at left side of the screen
	move.l	#$200000,obj.x_speed(a0)			; Move right
	bset	#3,obj.flags(a0)
	bra.s	.Setup

.EnterFromRight:
	move.w	#256,obj.x(a0)					; Set at right side of the screen
	move.l	#-$200000,obj.x_speed(a0)			; Move left
	bclr	#3,obj.flags(a0)

.Setup:
	move.w	#208,obj.y(a0)					; Set Y position
	
	lea	TrackInfo,a1					; Set X offset
	move.w	d0,d1
	add.w	d1,d1
	move.w	2(a1,d1.w),d2
	move.w	d2,obj.x_offset(a0)
	
	addi.w	#$E000,obj.sprite_tile(a0)			; Set to selection menu palette
	move.w	#1,obj.routine(a0)				; Set to enter routine
	move.w	#0,track.routine(a2)				; Reset track selection routine
	rts

; ------------------------------------------------------------------------------
; Entrance
; ------------------------------------------------------------------------------

EnterTrackTitle:
	move.l	obj.x_speed(a0),d0				; Move
	add.l	d0,obj.x(a0)
	
	move.w	obj.x(a0),d0					; Get X position
	btst	#3,obj.flags(a0)				; Are we entering in from the right?
	bne.s	.EnterFromRight					; If so, branch
	
	cmp.w	obj.x_offset(a0),d0				; Are we at the destination?
	bgt.s	.End						; If not, branch
	bra.s	.Stop

.EnterFromRight:
	cmp.w	obj.x_offset(a0),d0				; Are we at the destination?
	blt.s	.End						; If not, branch

.Stop:
	clr.l	obj.x_speed(a0)					; Stop
	move.w	obj.x_offset(a0),obj.x(a0)
	move.w	#2,obj.routine(a0)				; Set to wait routine

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for track selection
; ------------------------------------------------------------------------------

WaitTrackSelection:
	btst	#3,sub_p2_ctrl_hold				; Has right been pressed?
	beq.s	.CheckLeft					; If not, branch

	move.w	#3,obj.routine(a0)				; Set to exit routine
	move.l	#$200000,obj.x_speed(a0)			; Move right
	bset	#3,obj.flags(a0)				; Mark as moving right

.CheckLeft:
	btst	#2,sub_p2_ctrl_hold				; Has left been pressed?
	beq.s	.End						; If not, branch
	
	move.l	#-$200000,obj.x_speed(a0)			; Move left
	move.w	#3,obj.routine(a0)				; Set to exit routine
	bclr	#3,obj.flags(a0)				; Mark as moving left

.End:
	rts

; ------------------------------------------------------------------------------
; Exit
; ------------------------------------------------------------------------------

ExitTrackTitle:
	move.l	obj.x_speed(a0),d0				; Move
	add.l	d0,obj.x(a0)
	
	btst	#3,obj.flags(a0)				; Are we exiting to the right?
	bne.s	.ExitRight					; If so, branch

.ExitLeft:
	cmpi.w	#-$80,obj.x(a0)					; Are we offscreen?
	bgt.s	.End						; If not, branch
	
	bset	#2,track_selection_flags			; Mark as spawning
	bclr	#0,track.direction(a2)				; Spawn new title track from the right
	
	move.b	obj.spawn_id(a0),d0				; Delete this title track object
	eor.b	d0,object_spawn_flags
	bset	#4,obj.flags(a0)
	
	addq.w	#1,track.selection_id(a2)			; Increment track ID
	move.w	track.selection_id(a2),d0			; Should it wrap?
	cmpi.w	#TRACK_COUNT-1,d0
	ble.s	.End						; If not, branch
	move.w	#0,track.selection_id(a2)			; If so, wrap it
	bra.s	.End

.ExitRight:
	cmpi.w	#$120,obj.x(a0)					; Are we offscreen?
	blt.s	.End						; If not, branch
	
	bset	#2,track_selection_flags			; Mark as spawning
	bset	#0,track.direction(a2)				; Spawn new title track from the left
	
	move.b	obj.spawn_id(a0),d0				; Delete this title track object
	eor.b	d0,object_spawn_flags
	bset	#4,obj.flags(a0)
	
	subq.w	#1,track.selection_id(a2)			; Decrement track ID
	bge.s	.End						; If it shouldn't wrap, branch
	move.w	#TRACK_COUNT-1,track.selection_id(a2)		; Wrap it

.End:
	rts

; ------------------------------------------------------------------------------
