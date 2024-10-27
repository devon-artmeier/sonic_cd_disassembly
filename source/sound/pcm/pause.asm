; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Handle pausing
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef HandlePause
HandlePause:
	tst.b	pcm.pause_mode(a5)				; Are we already paused?
	beq.s	.End						; If not, branch
	bmi.s	.Unpause					; If we are unpausing, branch
	cmpi.b	#2,pcm.pause_mode(a5)				; Has the pause already been processed?
	beq.s	.Paused						; If so, branch
	
	move.b	#$FF,PCM_ON_OFF-PCM_REGS(a4)			; Mute all channels
	move.b	#2,pcm.pause_mode(a5)				; Mark pause as processed

.Paused:
	addq.w	#4,sp						; Exit the driver

.End:
	rts

; ------------------------------------------------------------------------------

.Unpause:
	clr.b	pcm.pause_mode(a5)				; Unpause
	rts

; ------------------------------------------------------------------------------
