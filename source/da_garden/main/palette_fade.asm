; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Fade the screen to white
; ------------------------------------------------------------------------------

	xdef FadeToWhite
FadeToWhite:
	move.w	#$3F,palette_fade_params			; Set palette fade start and length

	move.w	#(7*3),d4					; Prepare to do fading

.Fade:
	move.b	#$A,vsync_flag_2				; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToWhite				; Fade colors once
	dbf	d4,.Fade					; Loop until fading is done

	rts

; ------------------------------------------------------------------------------

FadeColorsToWhite:
	moveq	#0,d0						; Get starting palette fade location
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	move.b	palette_fade_length,d0				; Get palette fade length

.Loop:
	bsr.s	FadeColorToWhite				; Fade a color
	dbf	d0,.Loop					; Loop until finished

	moveq	#0,d0						; Get starting palette fade location for fade buffer
	lea	fade_palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	move.b	palette_fade_length,d0				; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToWhite				; Fade a color
	dbf	d0,.LoopWater					; Loop until finished
	rts

; ------------------------------------------------------------------------------

FadeColorToWhite:
	move.w	(a0),d2						; Get color
	cmpi.w	#$EEE,d2					; Is it already white?
	beq.s	.Skip						; If so, branch

.Red:
	move.w	d2,d1						; Get red component
	andi.w	#$E,d1						; Is it already 0?
	cmpi.w	#$E,d1
	beq.s	.Green						; If so, check green
	addq.w	#2,(a0)+					; Fade red
	rts

.Green:
	move.w	d2,d1						; Get green component
	andi.w	#$E0,d1						; Is it already 0?
	cmpi.w	#$E0,d1
	beq.s	.Blue						; If so, check blue
	addi.w	#$20,(a0)+					; Fade green
	rts

.Blue:
	move.w	d2,d1						; Get blue component
	andi.w	#$E00,d1					; Is it already 0?
	cmpi.w	#$E00,d1
	beq.s	.Skip						; If so, we're done
	addi.w	#$200,(a0)+					; Fade blue
	rts

.Skip:
	addq.w	#2,a0						; Skip over this color
	rts

; ------------------------------------------------------------------------------
; Fade the screen from white
; ------------------------------------------------------------------------------

	xdef FadeFromWhite
FadeFromWhite:
	move.w	#$3F,palette_fade_params			; Set palette fade start and length

	moveq	#0,d0						; Get starting palette fill location
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	move.w	#$EEE,d1					; Get palette fill value (whiyte)
	move.b	palette_fade_length,d0				; Get palette fill length

.Fill:
	move.w	d1,(a0)+
	dbf	d0,.Fill					; Fill until finished

	move.w	#(7*3),d4					; Prepare to do fading

.Fade:
	move.b	#$A,vsync_flag					; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromWhite				; Fade colors once
	dbf	d4,.Fade					; Loop until fading is done

	rts

; ------------------------------------------------------------------------------

FadeColorsFromWhite:
	moveq	#0,d0						; Get starting palette fade locations
	lea	palette,a0
	lea	fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palette_fade_length,d0				; Get palette fade length

.Loop:
	bsr.s	FadeColorFromWhite				; Fade a color
	dbf	d0,.Loop					; Loop until finished

	bra.s	.End						; Skip water fade update

	moveq	#0,d0						; Get starting palette fade locations for water
	lea	water_palette,a0
	lea	water_fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palette_fade_length,d0				; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromWhite				; Fade a color
	dbf	d0,.LoopWater					; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------

FadeColorFromWhite:
	move.w	(a1)+,d2					; Get target color
	move.w	(a0),d3						; Get current color
	cmp.w	d2,d3						; Are they the same?
	beq.s	.Skip						; If so, branch

	move.w	d3,d1						; Fade blue
	subi.w	#$200,d1					; Is it already 0?
	bcs.s	.Green						; If so, start fading green
	cmp.w	d2,d1						; Is the blue component done?
	bcs.s	.Green						; If so, start fading green
	move.w	d1,(a0)+					; Update color
	rts

.Green:
	move.w	d3,d1						; Fade green
	subi.w	#$20,d1						; Is it already 0?
	bcs.s	.Red						; If so, start fading red
	cmp.w	d2,d1						; Is the green component done?
	bcs.s	.Red						; If so, start fading red
	move.w	d1,(a0)+					; Update color
	rts

.Red:
	subq.w	#2,(a0)+					; Fade red
	rts

.Skip:
	addq.w	#2,a0						; Skip over this color
	rts

; ------------------------------------------------------------------------------
; Fade the screen from black
; ------------------------------------------------------------------------------

	xdef FadeFromBlack
FadeFromBlack:
	move.w	#$3F,palette_fade_params			; Set palette fade start and length

	moveq	#0,d0						; Get starting palette fill location
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	moveq	#0,d1						; Get palette fill value (black)
	move.b	palette_fade_length,d0				; Get palette fill length

.Clear:
	move.w	d1,(a0)+
	dbf	d0,.Clear					; Fill until finished

	move.w	#(7*3),d4					; Prepare to do fading

.Fade:
	move.b	#$A,vsync_flag					; VSync
	bsr.w	VSync
	bsr.s	FadeColorsFromBlack				; Fade colors once
	dbf	d4,.Fade					; Loop until fading is done

	rts

; ------------------------------------------------------------------------------

FadeColorsFromBlack:
	moveq	#0,d0						; Get starting palette fade locations
	lea	palette,a0
	lea	fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palette_fade_length,d0				; Get palette fade length

.Loop:
	bsr.s	FadeColorFromBlack				; Fade a color
	dbf	d0,.Loop					; Loop until finished

	bra.s	.End						; Skip water fade update

	moveq	#0,d0						; Get starting palette fade locations for water
	lea	water_palette,a0
	lea	water_fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	move.b	palette_fade_length,d0				; Get palette fade length

.LoopWater:
	bsr.s	FadeColorFromBlack				; Fade a color
	dbf	d0,.LoopWater					; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2					; Get target color
	move.w	(a0),d3						; Get current color
	cmp.w	d2,d3						; Are they the same?
	beq.s	.Skip						; If so, branch

.Blue:
	move.w	d3,d1						; Fade blue
	addi.w	#$200,d1
	cmp.w	d2,d1						; Is the blue component done?
	bhi.s	.Green						; If so, start fading green
	move.w	d1,(a0)+					; Update color
	rts

.Green:
	move.w	d3,d1						; Fade green
	addi.w	#$20,d1
	cmp.w	d2,d1						; Is the green component done?
	bhi.s	.Red						; If so, start fading red
	move.w	d1,(a0)+					; Update color
	rts

.Red:
	addq.w	#2,(a0)+					; Fade red
	rts


.Skip:
	addq.w	#2,a0						; Skip over this color
	rts

; ------------------------------------------------------------------------------
; Fade the screen to black
; ------------------------------------------------------------------------------

	xdef FadeToBlack
FadeToBlack:
	move.w	#$3F,palette_fade_params			; Set palette fade start and length

	move.w	#(7*3),d4					; Prepare to do fading

.Fade:
	move.b	#$A,vsync_flag					; VSync
	bsr.w	VSync
	bsr.s	FadeColorsToBlack				; Fade colors once
	dbf	d4,.Fade					; Loop until fading is done

	rts

; ------------------------------------------------------------------------------

FadeColorsToBlack:
	moveq	#0,d0						; Get starting palette fade location
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	move.b	palette_fade_length,d0				; Get palette fade length

.Loop:
	bsr.s	FadeColorToBlack				; Fade a color
	dbf	d0,.Loop					; Loop until finished

	moveq	#0,d0						; Get starting palette fade location for water
	lea	water_palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	move.b	palette_fade_length,d0				; Get palette fade length

.LoopWater:
	bsr.s	FadeColorToBlack				; Fade a color
	dbf	d0,.LoopWater					; Loop until finished

	rts

; ------------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2						; Get color
	beq.s	.Skip						; If it's already black, branch

.Red:
	move.w	d2,d1						; Get red component
	andi.w	#$E,d1						; Is it already 0?
	beq.s	.Green						; If so, check green
	subq.w	#2,(a0)+					; Fade red
	rts

.Green:
	move.w	d2,d1						; Get green component
	andi.w	#$E0,d1						; Is it already 0?
	beq.s	.Blue						; If so, check blue
	subi.w	#$20,(a0)+					; Fade green
	rts

.Blue:
	move.w	d2,d1						; Get blue component
	andi.w	#$E00,d1					; Is it already 0?
	beq.s	.Skip						; If so, we're done
	subi.w	#$200,(a0)+					; Fade blue
	rts

.Skip:
	addq.w	#2,a0						; Skip over this color
	rts

; ------------------------------------------------------------------------------
