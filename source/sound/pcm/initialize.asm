; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Initialize driver
; ------------------------------------------------------------------------------

	xdef InitDriver
InitDriver:
	jsr	GetPointers(pc)					; Get driver pointers

	move.b	#$FF,PCM_ON_OFF-PCM_REGS(a4)			; Mute all channels
	move.b	#$80,PCM_CTRL-PCM_REGS(a4)			; Set to sample RAM bank 0

	lea	PcmDriverOrigin(pc),a0				; Get pointer offset
	suba.l	info.origin(a6),a0
	move.l	a0,pcm.ptr_offset(a5)

	bra.s	StopSound					; Stop sound

; ------------------------------------------------------------------------------
; Get driver pointers
; ------------------------------------------------------------------------------
; RETURNS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
;	a6.l - Pointer to driver information table
; ------------------------------------------------------------------------------

	xdef GetPointers
GetPointers:
	lea	DriverInfo(pc),a6				; Driver info
	lea	PcmVariables(pc),a5				; Driver variables
	lea	PCM_REGS,a4					; PCM registers
	rts

; ------------------------------------------------------------------------------
