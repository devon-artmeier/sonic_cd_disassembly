; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Reset driver
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef ResetDriver
ResetDriver:
	move.b	#$FF,PCM_ON_OFF-PCM_REGS(a4)			; Mute all channels
	move.l	pcm.ptr_offset(a5),d1				; Save pointer offset

	movea.l	a5,a0						; Clear variables
	move.w	#pcm.struct_size/4-1,d0

.ClearVars:
	clr.l	(a0)+
	dbf	d0,.ClearVars
	ifne pcm.struct_size&2
		clr.w	(a0)+
	endif
	ifne pcm.struct_size&1
		clr.b	(a0)+
	endif

	move.l	d1,pcm.ptr_offset(a5)				; Restore pointer offset
	move.b	#$FF,pcm.on(a5)					; Mute all channels
	move.b	#$80,pcm.sound_play(a5)				; Mark sound queue as processed
	rts

; ------------------------------------------------------------------------------
