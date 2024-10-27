; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Handle fading out
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef HandleFadeOut
HandleFadeOut:
	moveq	#0,d0						; Get number of steps left
	move.b	pcm.fade_steps(a5),d0
	beq.s	.End						; If there are none, branch

	move.b	pcm.fade_delay_timer(a5),d0			; Get fade out delay counter
	beq.s	.FadeOut					; If it has run out, branch
	subq.b	#1,pcm.fade_delay_timer(a5)			; If it hasn't decrement it

.End:
	rts

.FadeOut:
	subq.b	#1,pcm.fade_steps(a5)				; Decrement step counter
	beq.w	ResetDriver					; If it has run out, branch
	move.b	pcm.fade_delay(a5),pcm.fade_delay_timer(a5)

	lea	pcm.rhythm(a5),a3				; Fade out music tracks
	moveq	#TRACK_COUNT-1,d7
	move.b	pcm.fade_speed(a5),d6				; Get fade speed
	add.b	d6,pcm.unk_fade_volume(a5)			; Add to unknown fade volume

.FadeTracks:
	tst.b	(a3)						; Is this track playing?
	bpl.s	.NextTrack					; If not, branch
	
	sub.b	d6,track.volume(a3)				; Fade out track
	bcc.s	.UpdateVolume					; If it hasn't gone silent yet, branch
	
	clr.b	track.volume(a3)				; Otherwise, cap volume at 0
	bclr	#TRACK_PLAY,(a3)				; Stop track

.UpdateVolume:
	move.b	track.channel(a3),d0				; Update volume register
	ori.b	#$C0,d0
	move.b	d0,PCM_CTRL-PCM_REGS(a4)
	move.b	track.volume(a3),PCM_VOLUME-PCM_REGS(a4)

.NextTrack:
	adda.w	#track.struct_size,a3				; Next track
	dbf	d7,.FadeTracks					; Loop until all tracks are processed
	rts

; ------------------------------------------------------------------------------
