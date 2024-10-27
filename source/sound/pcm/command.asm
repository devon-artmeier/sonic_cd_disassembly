; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Run a driver command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d7.b - Command ID
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef RunCommand
RunCommand:
	move.b	d7,d0						; Run command
	subi.b	#PCMC_START,d7
	lsl.w	#2,d7
	jmp	.Commands(pc,d7.w)

; ------------------------------------------------------------------------------

.Commands:
	jmp	FadeOutCommand(pc)				; Fade out
	jmp	StopSound(pc)					; Stop
	jmp	PauseCommand(pc)				; Pause
	jmp	UnpauseCommand(pc)				; Unpause
	jmp	MuteCommand(pc)					; Mute

; ------------------------------------------------------------------------------
; Fade out command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

FadeOutCommand:
	move.b	#$60,pcm.fade_steps(a5)				; Initialize fade out
	move.b	#1,pcm.fade_delay(a5)
	move.b	#2,pcm.fade_speed(a5)
	rts

; ------------------------------------------------------------------------------
; Pause command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

PauseCommand:
	move.b	#1,pcm.pause_mode(a5)				; Pause
	rts

; ------------------------------------------------------------------------------
; Unpause command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

UnpauseCommand:
	move.b	#$80,pcm.pause_mode(a5)				; Unpause
	rts

; ------------------------------------------------------------------------------
; Mute command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

MuteCommand:
	move.b	#$FF,PCM_ON_OFF-PCM_REGS(a4)			; Mute all channels
	rts

; ------------------------------------------------------------------------------
