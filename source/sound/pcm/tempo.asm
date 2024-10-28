; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Handle tempo
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef HandleTempo
HandleTempo:
	tst.b	pcm.tempo(a5)					; Is the tempo set to 0?
	beq.s	.End						; If so, branch
	
	subq.b	#1,pcm.tempo_timer(a5)				; Decrement tempo counter
	bne.s	.End						; If it hasn't run out, branch
	move.b	pcm.tempo(a5),pcm.tempo_timer(a5)		; Reset counter

	lea	pcm.rhythm(a5),a0				; Delay tracks by 1 tick
	move.w	#track.struct_size,d1
	moveq	#TRACK_COUNT-1,d0

.DelayTracks:
	addq.b	#1,track.duration_timer(a0)
	adda.w	d1,a0
	dbf	d0,.DelayTracks

.End:
	rts

; ------------------------------------------------------------------------------
