; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Fade to black
; ------------------------------------------------------------------------------

	xdef FadeToBlack, FadeToBlack2
FadeToBlack:
	move.w	#(0<<9)|($40-1),palette_fade_params		; Fade entire palette

FadeToBlack2:
	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	bsr.s	FadeColorsToBlack				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade to black
; ------------------------------------------------------------------------------

FadeColorsToBlack:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0

	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorToBlack				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color to black
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
; RETURNS:
;	a0.l - Pointer to next color
; ------------------------------------------------------------------------------

FadeColorToBlack:
	move.w	(a0),d2						; Get color
	beq.s	.End						; If it's already black, branch

.CheckRed:
	move.w	d2,d1						; Check red channel
	andi.w	#$E,d1
	beq.s	.CheckGreen					; If it's already 0, branch
	subq.w	#2,(a0)+					; Decrement red channel
	rts

.CheckGreen:
	move.w	d2,d1						; Check green channel
	andi.w	#$E0,d1
	beq.s	.CheckBlue					; If it's already 0, branch
	subi.w	#$20,(a0)+					; Decrement green channel
	rts

.CheckBlue:
	move.w	d2,d1						; Check blue channel
	andi.w	#$E00,d1
	beq.s	.End						; If it's already 0, branch
	subi.w	#$200,(a0)+					; Decrement blue channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
; Fade from black
; ------------------------------------------------------------------------------

	xdef FadeFromBlack
FadeFromBlack:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	
	moveq	#0,d1						; Black
	move.b	palette_fade_length,d0				; Get color count

.FillBlack:
	move.w	d1,(a0)+					; Fill palette region with black
	dbf	d0,.FillBlack

	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	bsr.s	FadeColorsFromBlack				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade from black
; ------------------------------------------------------------------------------

FadeColorsFromBlack:
	moveq	#0,d0						; Get palette offsets
	lea	palette,a0
	lea	fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	
	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorFromBlack				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color from black
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
;	a1.l - Pointer to target palette color
; RETURNS:
;	a0.l - Pointer to next color
;	a1.l - Pointer to next target color
; ------------------------------------------------------------------------------

FadeColorFromBlack:
	move.w	(a1)+,d2					; Get target color
	move.w	(a0),d3						; Get color
	cmp.w	d2,d3						; Are they the same?
	beq.s	.End						; If so, branch

.CheckBlue:
	move.w	d3,d1						; Increment blue channel
	addi.w	#$200,d1
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bhi.s	.CheckGreen					; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.CheckGreen:
	move.w	d3,d1						; Increment green channel
	addi.w	#$20,d1
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bhi.s	.IncreaseRed					; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.IncreaseRed:
	addq.w	#2,(a0)+					; Increment red channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
; Fade from white
; ------------------------------------------------------------------------------

	xdef FadeFromWhite, FadeFromWhite2
FadeFromWhite:
	move.w	#($00<<9)|($40-1),palette_fade_params		; Fade entire palette
	
FadeFromWhite2:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	
	move.w	#$EEE,d1					; White
	move.b	palette_fade_length,d0				; Get color count

.FillWhite:
	move.w	d1,(a0)+					; Fill palette region with black
	dbf	d0,.FillWhite
	move.w	#0,palette+($2E*2)				; Set line 2 color 14 to black

	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	
	move.l	d4,-(sp)					; Scrapped code?
	move.l	(sp)+,d4
	
	bsr.s	FadeColorsFromWhite				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	
	clr.b	unk_palette_fade_flag				; Clear unknown flag
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade from white
; ------------------------------------------------------------------------------

FadeColorsFromWhite:
	moveq	#0,d0						; Get palette offsets
	lea	palette,a0
	lea	fade_palette,a1
	move.b	palette_fade_start,d0
	adda.w	d0,a0
	adda.w	d0,a1
	
	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorFromWhite				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color from white
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
;	a1.l - Pointer to target palette color
; RETURNS:
;	a0.l - Pointer to next color
;	a1.l - Pointer to next target color
; ------------------------------------------------------------------------------

FadeColorFromWhite:
	move.w	(a1)+,d2					; Get target color
	move.w	(a0),d3						; Get color
	cmp.w	d2,d3						; Are they the same?
	beq.s	.End						; If so, branch

.CheckBlue:
	move.w	d3,d1						; Decrement blue channel
	subi.w	#$200,d1
	bcs.s	.CheckGreen					; If it underflowed, branch
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bcs.s	.CheckGreen					; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.CheckGreen:
	move.w	d3,d1						; Decrement green channel
	subi.w	#$20,d1
	bcs.s	.IncreaseRed					; If it underflowed, branch
	cmp.w	d2,d1						; Have we gone past the target channel value?
	bcs.s	.IncreaseRed					; If so, branch
	move.w	d1,(a0)+					; Update color
	rts

.IncreaseRed:
	subq.w	#2,(a0)+					; Decrement red channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
; Fade to white
; ------------------------------------------------------------------------------

	xdef FadeToWhite, FadeToWhite2
FadeToWhite:
	move.w	#(0<<9)|($40-1),palette_fade_params		; Fade entire palette

FadeToWhite2:
	move.w	#(7*3),d4					; Number of fade frames

.Loop:
	move.b	#1,unk_palette_fade_flag			; Set unknown flag
	bsr.w	VSync						; VSync
	bsr.s	FadeColorsToWhite				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	
	clr.b	unk_palette_fade_flag				; Clear unknown flag
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade to white
; ------------------------------------------------------------------------------

FadeColorsToWhite:
	moveq	#0,d0						; Get palette offset
	lea	palette,a0
	move.b	palette_fade_start,d0
	adda.w	d0,a0

	move.b	palette_fade_length,d0				; Get color count

.FadeColors:
	bsr.s	FadeColorToWhite				; Fade color
	dbf	d0,.FadeColors					; Loop until all colors have faded a frame
	rts

; ------------------------------------------------------------------------------
; Fade a color to white
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to palette color
; RETURNS:
;	a0.l - Pointer to next color
; ------------------------------------------------------------------------------

FadeColorToWhite:
	move.w	(a0),d2						; Get color
	cmpi.w	#$EEE,d2					; Is it already white?
	beq.s	.End						; If so, branch

.CheckRed:
	move.w	d2,d1						; Check red channel
	andi.w	#$E,d1
	cmpi.w	#$E,d1						; Is it already at max?
	beq.s	.CheckGreen					; If so, branch
	addq.w	#2,(a0)+					; Decrement red channel
	rts

.CheckGreen:
	move.w	d2,d1						; Check green channel
	andi.w	#$E0,d1
	cmpi.w	#$E0,d1						; Is it already at max?
	beq.s	.CheckBlue					; If so, branch
	addi.w	#$20,(a0)+					; Decrement green channel
	rts

.CheckBlue:
	move.w	d2,d1						; Check blue channel
	andi.w	#$E00,d1
	cmpi.w	#$E00,d1					; Is it already at max?
	beq.s	.End						; If so, branch
	addi.w	#$200,(a0)+					; Decrement blue channel
	rts

.End:
	addq.w	#2,a0						; Skip to next color
	rts

; ------------------------------------------------------------------------------
