; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Handle track selection
; ------------------------------------------------------------------------------

	xdef TrackSelection
TrackSelection:
	lea	track_data,a2					; Track selection data
	
	moveq	#0,d0						; Run routine
	move.w	track.routine(a2),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; ------------------------------------------------------------------------------

.Index:
	dc.w	CheckTrackPlay-.Index
	dc.w	SpawnTrackTitle-.Index
	dc.w	WaitTrackTitle-.Index

; ------------------------------------------------------------------------------
; Check if a track can be played
; ------------------------------------------------------------------------------

CheckTrackPlay:
	btst	#5,ctrl_hold					; Is C being held?
	bne.s	.HeldC						; If so, branch
	btst	#5,button_flags					; If not, was it being held before?
	beq.s	.CheckB						; If not, branch
	
	btst	#0,track_selection_flags			; Is track selection active?
	beq.s	.ReleaseC					; If not, branch
	btst	#2,track_selection_flags			; Is the title track spawning?
	bne.s	.CheckB						; If so, branch
	
	bclr	#5,button_flags					; Mark as released
	bra.s	.DoPlayTrack					; Play track

.HeldC:
	bset	#5,button_flags					; Mark as held
	bra.s	.CheckB

.ReleaseC:
	bclr	#5,button_flags					; Mark as released

.CheckB:
	btst	#4,ctrl_hold					; Is B being held?
	bne.s	.HeldB						; If so, branch
	btst	#4,button_flags					; If not, was it being held before?
	beq.s	.CheckC						; If not, branch
	
	btst	#0,track_selection_flags			; Is track selection active?
	beq.s	.ReleaseB					; If not, branch
	btst	#2,track_selection_flags			; Is the title track spawning?
	bne.s	.CheckC						; If so, branch
	
	bclr	#4,button_flags					; Mark as released
	bra.s	.DoPlayTrack					; Play track

.HeldB:
	bset	#4,button_flags					; Mark as held
	bra.s	.CheckC

.ReleaseB:
	bclr	#4,button_flags					; Mark as released

.CheckC:
	btst	#6,ctrl_hold					; Is A being held?
	bne.s	.AHeld						; If so, branch
	btst	#6,button_flags					; If not, was it being held before?
	beq.s	.CheckTextSpawn					; If not, branch
	
	btst	#0,track_selection_flags			; Is track selection active?
	beq.s	.EnableSelection				; If not, branch
	btst	#2,track_selection_flags			; Is the title track spawning?
	bne.s	.CheckTextSpawn					; If so, branch
	
	bclr	#6,button_flags					; Mark as released

.DoPlayTrack:
	bsr.w	.PlayTrack					; Play track
	bra.s	.End

.EnableSelection:
	bset	#0,track_selection_flags			; Make track selection active
	bset	#2,track_selection_flags			; Mark title track as spawning
	
	bclr	#6,button_flags					; Mark as released
	bra.s	.CheckTextSpawn

.AHeld:
	bset	#6,button_flags					; Mark as held
	bra.s	.End
	
.CheckTextSpawn:
	btst	#2,track_selection_flags			; Is the title track set to spawn?
	beq.s	.End						; If not, branch
	bsr.w	CheckObjectsLoaded				; Are there objects currently on screen?
	bne.s	.End						; If so, branch
	
	bset	#4,MCD_MAIN_FLAG				; Mark title track as spawned
	bclr	#2,track_selection_flags
	move.w	#1,track.routine(a2)				; Set to title track spawn routine

.End:
	rts

; ------------------------------------------------------------------------------

.PlayTrack:
	move.b	#0,object_spawn_flags				; Reset object spawn flags
	
	move.w	track.selection_id(a2),d0			; Set track ID
	move.w	d0,MCD_MAIN_COMM_8
	
	add.w	d0,d0						; Set track time zone
	add.w	d0,d0
	lea	TrackInfo,a1
	move.w	(a1,d0.w),d1
	cmpi.w	#3,d1
	beq.s	.SetTimeZone
	move.w	d1,track_time_zone

.SetTimeZone:
	move.w	d1,MCD_MAIN_COMM_10
	
	bclr	#4,MCD_MAIN_FLAG				; Mark track selection as inactive on the Sub CPU side
	bset	#5,MCD_MAIN_FLAG				; Play new track
	rts

; ------------------------------------------------------------------------------
; Spawn track title
; ------------------------------------------------------------------------------

SpawnTrackTitle:
	bsr.w	SpawnObject					; Get title track object slot
	bne.w	.End						; If there's no slots available, branch
	
	move.w	a1,track.title(a2)				; Set object slot pointer
	bset	#1,track_selection_flags			; Mark title track as spawning
	move.w	#2,track.routine(a2)				; Set to wait routine

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for track title to spawn
; ------------------------------------------------------------------------------

WaitTrackTitle:
	rts

; ------------------------------------------------------------------------------
; Check if we should spawn the track title
; ------------------------------------------------------------------------------

	xdef CheckTrackTitleSpawn
CheckTrackTitleSpawn:
	btst	#1,track_selection_flags			; Is the title track spawning?
	beq.s	.End						; If not, branch
	bclr	#1,track_selection_flags			; Clear flag
	
	lea	track_data,a2					; Get object slot
	movea.w	track.title(a2),a1
	move.w	#7,obj.id(a1)					; Set object ID
	
	btst	#0,object_spawn_flags				; Is the spawn slot 0 occupied?
	bne.s	.Second						; If so, branch
	bset	#0,object_spawn_flags				; Occupy spawn slot 0
	
	move.w	#$5B8,obj.sprite_tile(a1)			; Set base tile ID
	move.b	#1,obj.spawn_id(a1)				; Set spawn slot ID
	
	move.w	#$A,d0						; Load art
	add.w	track.selection_id(a2),d0
	jsr	LoadArt(pc)
	bra.s	.End

.Second:
	bset	#1,object_spawn_flags				; Occupy spawn slot 1
	
	move.w	#$5DC,obj.sprite_tile(a1)			; Set base tile ID
	move.b	#2,obj.spawn_id(a1)				; Set spawn slot ID
	
	move.w	#$A+TRACK_COUNT,d0				; Load art
	add.w	track.selection_id(a2),d0
	jsr	LoadArt(pc)

.End:
	rts

; ------------------------------------------------------------------------------
