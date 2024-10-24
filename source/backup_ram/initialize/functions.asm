; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	move.b	#1,vsync_flag					; Set VSync flag
	move	#$2500,sr					; Enable interrupts

.Wait:
	tst.b	vsync_flag					; Has the V-BLANK handler run?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Set all buttons
; ------------------------------------------------------------------------------

	xdef SetAllButtons
SetAllButtons:
	move.w	#$FF00,ctrl_data				; Press down all buttons
	rts

; ------------------------------------------------------------------------------
; Random number generator
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; ------------------------------------------------------------------------------

	xdef Random
Random:
	move.l	d1,-(sp)					; Save registers
	move.l	rng_seed,d1					; Get RNG seed
	bne.s	.GetRandom					; If it's set, branch
	move.l	#$2A6D365A,d1					; If not, initialize it

.GetRandom:
	move.l	d1,d0						; Perform various operations
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1

	move.l	d1,rng_seed					; Update RNG seed
	move.l	(sp)+,d1					; Restore registers
	rts

; ------------------------------------------------------------------------------
