; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Set track as rested
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef RestTrack
RestTrack:
	move.b	track.channel(a3),d0				; Mute track
	bset	d0,pcm.on(a5)
	bset	#TRACK_REST,track.flags(a3)			; Mark track as rested
	rts

; ------------------------------------------------------------------------------
; Set key off for track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef SetKeyOff
SetKeyOff:
	move.b	track.channel(a3),d0				; Mute track
	bset	d0,pcm.on(a5)
	move.b	pcm.on(a5),PCM_ON_OFF-PCM_REGS(a4)		; Update channels on/off array
	rts

; ------------------------------------------------------------------------------
; Set key on for track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef SetKeyOn
SetKeyOn:
	btst	#TRACK_LEGATO,(a3)				; Is legato enabled?
	bne.s	.End						; If so, branch
	move.b	track.channel(a3),d0				; Unmute track
	bclr	d0,pcm.on(a5)

.End:
	rts

; ------------------------------------------------------------------------------
