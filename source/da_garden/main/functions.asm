; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Mass fill
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Fill128, Fill64
Fill128:
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
Fill64:
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	rts

; ------------------------------------------------------------------------------
; Mass fill (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d1.l - Value to fill with
;	a1.l - VDP control port
; ------------------------------------------------------------------------------

	xdef FillVdp128
FillVdp128:
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	move.l	d1,(a1)
	rts

; ------------------------------------------------------------------------------
; Mass copy
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - Pointer to destination buffer
; ------------------------------------------------------------------------------

	xdef Copy128
Copy128:
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------
; Mass copy (VDP)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - Pointer to source data
;	a2.l - VDP control port
; ------------------------------------------------------------------------------

	xdef CopyVdp128
CopyVdp128:
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	move.l	(a1)+,(a2)
	rts

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
	move.w	#$FF00,ctrl_data				; Set all buttons
	rts

; ------------------------------------------------------------------------------
; Get a random number
; ------------------------------------------------------------------------------
; RETURNS:
;	d0.l - Random number
; ------------------------------------------------------------------------------

	xdef Random
Random:
	move.l	d1,-(sp)
	move.l	rng_seed,d1					; Get RNG seed
	bne.s	.GotSeed					; If it's set, branch
	move.l	#$2A6D365A,d1					; Reset RNG seed otherwise

.GotSeed:
	move.l	d1,d0						; Get random number
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
	move.l	(sp)+,d1
	rts

; ------------------------------------------------------------------------------
; Get sine or cosine of a value
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Value
; RETURNS:
;	d3.w - Sine/cosine of value
; ------------------------------------------------------------------------------

	xdef CalcCosine, CalcSine
CalcCosine:
	addi.w	#$80,d3						; Offset value for cosine

CalcSine:
	andi.w	#$1FF,d3					; Keep within range
	move.w	d3,d4
	btst	#7,d3						; Is the value the 2nd or 4th quarters of the sinewave?
	beq.s	.NoInvert					; If not, branch
	not.w	d4						; Invert value to fit sinewave pattern

.NoInvert:
	andi.w	#$7F,d4						; Get sine/cosine value
	add.w	d4,d4
	move.w	SineTable(pc,d4.w),d4

	btst	#8,d3						; Was the input value in the 2nd half of the sinewave?
	beq.s	.SetValue					; If not, branch
	neg.w	d4						; Negate value

.SetValue:
	move.w	d4,d3						; Set final value
	rts

; ------------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0003, $0006, $0009, $000C, $000F, $0012, $0016
	dc.w	$0019, $001C, $001F, $0022, $0025, $0028, $002B, $002F
	dc.w	$0032, $0035, $0038, $003B, $003E, $0041, $0044, $0047
	dc.w	$004A, $004D, $0050, $0053, $0056, $0059, $005C, $005F
	dc.w	$0062, $0065, $0068, $006A, $006D, $0070, $0073, $0076
	dc.w	$0079, $007B, $007E, $0081, $0084, $0086, $0089, $008C
	dc.w	$008E, $0091, $0093, $0096, $0099, $009B, $009E, $00A0
	dc.w	$00A2, $00A5, $00A7, $00AA, $00AC, $00AE, $00B1, $00B3
	dc.w	$00B5, $00B7, $00B9, $00BC, $00BE, $00C0, $00C2, $00C4
	dc.w	$00C6, $00C8, $00CA, $00CC, $00CE, $00D0, $00D1, $00D3
	dc.w	$00D5, $00D7, $00D8, $00DA, $00DC, $00DD, $00DF, $00E0
	dc.w	$00E2, $00E3, $00E5, $00E6, $00E7, $00E9, $00EA, $00EB
	dc.w	$00EC, $00EE, $00EF, $00F0, $00F1, $00F2, $00F3, $00F4
	dc.w	$00F5, $00F6, $00F7, $00F7, $00F8, $00F9, $00FA, $00FA
	dc.w	$00FB, $00FB, $00FC, $00FC, $00FD, $00FD, $00FE, $00FE
	dc.w	$00FE, $00FF, $00FF, $00FF, $00FF, $00FF, $00FF, $0100

; ------------------------------------------------------------------------------
