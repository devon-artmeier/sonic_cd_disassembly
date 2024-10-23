; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

	xdef ReadController
ReadController:
	lea	ctrl_data,a0					; Controller data buffer
	lea	IO_DATA_2,a1					; Controller port 2
	
	move.b	#0,(a1)						; TH = 0
	tst.w	(a0)						; Delay
	move.b	(a1),d0						; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a1)					; TH = 1
	tst.w	(a0)						; Delay
	move.b	(a1),d1						; Read B, C, and D-pad buttons
	andi.b	#$3F,d1

	or.b	d1,d0						; Combine button data
	not.b	d0						; Flip bits
	move.b	d0,d1						; Make copy

	move.b	(a0),d2						; Mask out tapped buttons
	eor.b	d2,d0
	move.b	d1,(a0)+					; Store pressed buttons
	and.b	d1,d0						; Store tapped buttons
	move.b	d0,(a0)+
	rts

; ------------------------------------------------------------------------------

	xdef ctrl_data, ctrl_press, ctrl_tap
ctrl_data:							; Controller data
ctrl_press:
	dc.b	0						; Controller pressed buttons data
ctrl_tap:
	dc.b	0						; Controller tapped buttons data

; ------------------------------------------------------------------------------
