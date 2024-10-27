; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Stop sound
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef StopSound
StopSound:
	jsr	ResetDriver(pc)					; Reset driver
	jsr	ClearSamples(pc)				; Clear samples
	bra.w	LoadSamples					; Reload samples

; ------------------------------------------------------------------------------
; Clear samples
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

ClearSamples:
	move.b	#$80,d3						; Start with bank 0
	moveq	#$10-1,d1					; Number of banks

.ClearBank:
	lea	PCM_WAVE_RAM,a0					; Sample RAM
	move.b	d3,PCM_CTRL-PCM_REGS(a4)			; Set bank ID
	moveq	#-1,d2						; Fill with loop flag
	move.w	#$1000-1,d0					; Number of bytes to fill

.ClearBankLoop:
	move.b	d2,(a0)+					; Clear sample RAM bank
	addq.w	#1,a0						; Skip over even addresses
	dbf	d0,.ClearBankLoop				; Loop until finished

	addq.w	#1,d3						; Next bank
	dbf	d1,.ClearBank					; Loop until finished
	rts

; ------------------------------------------------------------------------------
