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
	bsr.s	FadeToBlackFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade to black
; ------------------------------------------------------------------------------

	xdef FadeToBlackFrame
FadeToBlackFrame:
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

	xdef FadeColorToBlack
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
	bsr.s	FadeFromBlackFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade from black
; ------------------------------------------------------------------------------

	xdef FadeFromBlackFrame
FadeFromBlackFrame:
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

	xdef FadeColorFromBlack
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
	
	bsr.s	FadeFromWhiteFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	
	clr.b	unk_palette_fade_flag				; Clear unknown flag
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade from white
; ------------------------------------------------------------------------------

	xdef FadeFromWhiteFrame
FadeFromWhiteFrame:
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

	xdef FadeColorFromWhite
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
	bsr.s	FadeToWhiteFrame				; Do a frame of fading
	dbf	d4,.Loop					; Loop until palette is faded
	
	clr.b	unk_palette_fade_flag				; Clear unknown flag
	rts

; ------------------------------------------------------------------------------
; Do a frame of a fade to white
; ------------------------------------------------------------------------------

	xdef FadeToWhiteFrame
FadeToWhiteFrame:
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

	xdef FadeColorToWhite
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
; Decompress Nemesis art into VRAM (Note: VDP write command must be
; set beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis art pointer
; ------------------------------------------------------------------------------

	xdef DecompressNemesisVdp
DecompressNemesisVdp:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRowVdp,a3				; Write all data to the same location
	lea	VDP_DATA,a4					; VDP data port
	bra.s	DecompressNemesisMain

; ------------------------------------------------------------------------------
; Decompress Nemesis data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Nemesis data pointer
;	a4.l - Destination buffer pointer
; ------------------------------------------------------------------------------

	xdef DecompressNemesis
DecompressNemesis:
	movem.l	d0-a1/a3-a5,-(sp)				; Save registers
	lea	WriteNemesisRow,a3				; Advance to the next location after each write

; ------------------------------------------------------------------------------

DecompressNemesisMain:
	lea	nem_code_table,a1				; Prepare decompression buffer
	
	move.w	(a0)+,d2					; Get number of tiles
	lsl.w	#1,d2						; Should we use XOR mode?
	bcc.s	.GetRows					; If not, branch
	adda.w	#WriteNemesisRowVdpXor-WriteNemesisRowVdp,a3	; Use XOR mode

.GetRows:
	lsl.w	#2,d2						; Get number of rows
	movea.w	d2,a5
	moveq	#8,d3						; 8 pixels per row
	moveq	#0,d2						; XOR row buffer
	moveq	#0,d4						; Row buffer
	
	bsr.w	BuildNemesisCodeTable				; Build code table
	
	move.b	(a0)+,d5					; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6						; Set bitstream read data position
	
	bsr.s	GetNemesisCode					; Decompress data
	
	movem.l	(sp)+,d0-a1/a3-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

GetNemesisCode:
	move.w	d6,d7						; Peek 8 bits from bitstream
	subq.w	#8,d7
	move.w	d5,d1
	lsr.w	d7,d1
	cmpi.b	#%11111100,d1					; Should we read inline data?
	bcc.s	ReadInlineNemesisData				; If so, branch
	
	andi.w	#$FF,d1						; Get code length
	add.w	d1,d1
	move.b	(a1,d1.w),d0
	ext.w	d0
	
	sub.w	d0,d6						; Advance bitstream read data position
	cmpi.w	#9,d6						; Does a new byte need to be read?
	bcc.s	.NoNewByte					; If not, branch
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte:
	move.b	1(a1,d1.w),d1					; Get palette index
	move.w	d1,d0
	andi.w	#$F,d1
	andi.w	#$F0,d0						; Get repeat count

GetNemesisCodeLength:
	lsr.w	#4,d0						; Isolate repeat count

WriteNemesisPixel:
	lsl.l	#4,d4						; Shift up by a nibble
	or.b	d1,d4						; Write pixel
	subq.w	#1,d3						; Has an entire 8-pixel row been written?
	bne.s	NextNemesisPixel				; If not, loop
	jmp	(a3)						; Otherwise, write the row to its destination

; ------------------------------------------------------------------------------

ResetNemesisRow:
	moveq	#0,d4						; Reset row
	moveq	#8,d3						; Reset nibble counter

NextNemesisPixel:
	dbf	d0,WriteNemesisPixel				; Loop until finished
	bra.s	GetNemesisCode					; Read next code

; ------------------------------------------------------------------------------

ReadInlineNemesisData:
	subq.w	#6,d6						; Advance bitstream read data position
	cmpi.w	#9,d6						; Does a new byte need to be read?
	bcc.s	.NoNewByte					; If not, branch
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte:
	subq.w	#7,d6						; Read inline data
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1						; Get palette index
	andi.w	#$70,d0						; Get repeat count
	
	cmpi.w	#9,d6						; Does a new byte need to be read?
	bcc.s	GetNemesisCodeLength				; If not, branch
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5
	bra.s	GetNemesisCodeLength

; ------------------------------------------------------------------------------

WriteNemesisRowVdp:
	move.l	d4,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowVdpXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)						; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRow:
	move.l	d4,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

WriteNemesisRowXor:
	eor.l	d4,d2						; XOR the previous row with the current row
	move.l	d2,(a4)+					; Write row
	subq.w	#1,a5						; Decrement number of rows left
	move.w	a5,d4						; Are we done now?
	bne.s	ResetNemesisRow					; If not, branch
	rts

; ------------------------------------------------------------------------------

BuildNemesisCodeTable:
	move.b	(a0)+,d0					; Read first byte

.CheckEnd:
	cmpi.b	#$FF,d0						; Has the end of the code table been reached?
	bne.s	.NewPaletteIndex				; If not, branch
	rts

.NewPaletteIndex:
	move.w	d0,d7						; Set palette index

.Loop:
	move.b	(a0)+,d0					; Read next byte
	cmpi.b	#$80,d0						; Should we set a new palette index?
	bcc.s	.CheckEnd					; If so, branch

	move.b	d0,d1						; Copy repeat count
	andi.w	#$F,d7						; Get palette index
	andi.w	#$70,d1						; Get repeat count
	or.w	d1,d7						; Combine them
	
	andi.w	#$F,d0						; Get code length
	move.b	d0,d1
	lsl.w	#8,d1
	or.w	d1,d7						; Combine with palette index and repeat count
	
	moveq	#8,d1						; Is the code length 8 bits in size?
	sub.w	d0,d1
	bne.s	.ShortCode					; If not, branch
	
	move.b	(a0)+,d0					; Store code entry
	add.w	d0,d0
	move.w	d7,(a1,d0.w)
	bra.s	.Loop

.ShortCode:
	move.b	(a0)+,d0					; Get index
	lsl.w	d1,d0
	add.w	d0,d0
	
	moveq	#1,d5						; Get number of entries
	lsl.w	d1,d5
	subq.w	#1,d5

.ShortCode_Loop:
	move.w	d7,(a1,d0.w)					; Store code entry
	addq.w	#2,d0						; Increment index
	dbf	d5,.ShortCode_Loop				; Loop until finished
	bra.s	.Loop

; ------------------------------------------------------------------------------
