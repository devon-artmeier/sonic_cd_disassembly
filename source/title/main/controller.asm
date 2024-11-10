; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Read controller data
; ------------------------------------------------------------------------------

	xdef ReadControllers
ReadControllers:
	lea	p1_ctrl_data,a0					; Player 1 controller data buffer
	lea	IO_DATA_1,a1					; Controller port 1
	bsr.s	ReadController					; Read controller data
	
	lea	p2_ctrl_data,a0					; Player 2 controller data buffer
	lea	IO_DATA_2,a1					; Controller port 2

	tst.b	control_clouds					; Are the clouds controllable?
	beq.s	ReadController					; If not, branch
	
	move.w	p2_ctrl_data,sub_p2_ctrl_data			; Send controller data to Sub CPU for controlling the clouds

; ------------------------------------------------------------------------------

	xdef ReadController
ReadController:
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
