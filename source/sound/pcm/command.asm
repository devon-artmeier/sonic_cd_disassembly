; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Define command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command label
;	\3 - Priority
; ------------------------------------------------------------------------------

__cmd_id	set PCM_CMD_START
command macro
	xdef \1
	section data_cmd_priorities
	dc.b	\3
	section code
	jmp	\2(pc)
	\1:		equ __cmd_id
	__cmd_id:	set __cmd_id+1
	endm

; ------------------------------------------------------------------------------
; Priority table labels
; ------------------------------------------------------------------------------

	section data_cmd_priorities
	xdef CmdPriorities
CmdPriorities:
	section data_cmd_priorities_end
	even
	
; ------------------------------------------------------------------------------
; Run a driver command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d7.b - Command ID
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	section code
	xdef RunCommand
RunCommand:
	move.b	d7,d0						; Run command
	subi.b	#PCM_CMD_START,d7
	lsl.w	#2,d7
	jmp	.Commands(pc,d7.w)

; ------------------------------------------------------------------------------

.Commands:
	command PCM_CMD_FADE_OUT, FadeOutCommand, $80
	command PCM_CMD_STOP,     StopSound,      $80
	command PCM_CMD_PAUSE,    PauseCommand,   $80
	command PCM_CMD_UNPAUSE,  UnpauseCommand, $80
	command PCM_CMD_MUTE,     MuteCommand,    $80

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
