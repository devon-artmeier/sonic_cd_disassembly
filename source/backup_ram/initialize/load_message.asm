; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Load message art
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Message art ID queue
; ------------------------------------------------------------------------------

	xdef LoadMessageArt
LoadMessageArt:
	lea	VDP_CTRL,a5					; VDP control port
	moveq	#4-1,d2						; Number of IDs to check

.QueueLoop:
	moveq	#0,d1						; Get ID from queue
	move.b	d0,d1
	beq.s	.Next						; If it's blank, branch

	lsl.w	#3,d1						; Get art metadata
	lea	.MessageArt(pc),a0

	move.l	-8(a0,d1.w),(a5)				; VDP command
	movea.l	-4(a0,d1.w),a0					; Art data
	jsr	DecompressNemesisVdp(pc)			; Decompress and load art

.Next:
	ror.l	#8,d0						; Shift queue
	dbf	d2,.QueueLoop					; Loop until queue is scanned
	rts

; ------------------------------------------------------------------------------

.MessageArt:
	vdpCmd dc.l,$20,VRAM,WRITE				; Eggman art
	dc.l	EggmanArt
	vdpCmd dc.l,$340,VRAM,WRITE				; Message art
	dc.l	MessageArt
	ifne REGION=USA
		vdpCmd dc.l,$1C40,VRAM,WRITE			; Message art (extension)
		dc.l	MessageUsaArt
	endif

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
	
	jsr	BuildNemesisCodeTable(pc)			; Build code table
	
	move.b	(a0)+,d5					; Get first word of compressed data
	asl.w	#8,d5
	move.b	(a0)+,d5
	move.w	#16,d6						; Set bitstream read data position
	
	bsr.s	GetNemesisCode					; Decompress data
	
	nop
	nop
	nop
	nop
	
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
; Draw message tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Tilemap ID
; ------------------------------------------------------------------------------

	xdef DrawMessageTilemap
DrawMessageTilemap:
	andi.l	#$FFFF,d0					; Get mappings metadata
	mulu.w	#14,d0
	lea	.Tilemaps,a1
	adda.w	d0,a1

	movea.l	(a1)+,a0					; Mappings data
	move.w	(a1)+,d0					; Base tile attributes

	move.l	a1,-(sp)					; Decompress mappings
	lea	decomp_buffer,a1
	bsr.w	DecompressEnigma
	movea.l	(sp)+,a1

	move.w	(a1)+,d3					; Width
	move.w	(a1)+,d2					; Height
	move.l	(a1),d0						; VDP command
	
	lea	decomp_buffer,a0				; Load mappings into VRAM
	movea.l	#VDP_DATA,a1					; VDP data port

.Row:
	move.l	d0,VDP_CTRL					; Set VDP command
	move.w	d3,d1						; Get width

.Tile:
	move.w	(a0)+,(a1)					; Copy tile
	dbf	d1,.Tile					; Loop until row is copied
	addi.l	#$800000,d0					; Next row
	dbf	d2,.Row						; Loop until map is copied
	rts

; ------------------------------------------------------------------------------

.Tilemaps:
	; Backup RAM data corrupted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	dc.l	DataCorruptTilemap
	dc.w	$201A
	ifne REGION=JAPAN
		dc.w	$24-1, 6-1
		vdpCmd dc.l,$E584,VRAM,WRITE
	else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif
	
	; Internal Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	$A-1, 6-1
	vdpCmd dc.l,$C31E,VRAM,WRITE

	ifne REGION=JAPAN
		dc.l	UnformattedTilemap
		dc.w	$201A
		dc.w	$24-1, 6-1
		vdpCmd dc.l,$E584,VRAM,WRITE
	endif
	ifne REGION=USA
		dc.l	UnformattedUsaTilemap
		dc.w	$20E2
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif
	ifne REGION=EUROPE
		dc.l	UnformattedTilemap
		dc.w	$201A
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif
	
	; Cartridge Backup RAM unformatted
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	ifne REGION=JAPAN
		vdpCmd dc.l,$C21E,VRAM,WRITE
	else
		vdpCmd dc.l,$C29E,VRAM,WRITE
	endif

	dc.l	CartUnformattedTilemap
	dc.w	$201A
	ifne REGION=JAPAN
		dc.w	$24-1, $A-1
		vdpCmd dc.l,$E484,VRAM,WRITE
	else
		dc.w	$1D-1, 8-1
		vdpCmd dc.l,$E50A,VRAM,WRITE
	endif
	
	; Backup RAM full
	dc.l	EggmanTilemap
	dc.w	1
	dc.w	9, 5
	ifne REGION=JAPAN
		vdpCmd dc.l,$C29E,VRAM,WRITE
	else
		vdpCmd dc.l,$C31E,VRAM,WRITE
	endif

	dc.l	BuramFullTilemap
	dc.w	$201A
	ifne REGION=JAPAN
		dc.w	$24-1, 8-1
		vdpCmd dc.l,$E504,VRAM,WRITE
	else
		dc.w	$1D-1, 6-1
		vdpCmd dc.l,$E58A,VRAM,WRITE
	endif

; ------------------------------------------------------------------------------
; Decompress Enigma tilemap data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to Enigma data
;	a1.l - Pointer to destination buffer
;	d0.w - Base tile attributes
; ------------------------------------------------------------------------------

	xdef DecompressEnigma
DecompressEnigma:
	movem.l	d0-d7/a1-a5,-(sp)				; Save registers
	
	movea.w	d0,a3						; Get base tile
	
	move.b	(a0)+,d0					; Get size of inline copy value
	ext.w	d0
	movea.w	d0,a5

	move.b	(a0)+,d4					; Get tile flags
	lsl.b	#3,d4

	movea.w	(a0)+,a2					; Get incremental copy word
	adda.w	a3,a2
	
	movea.w	(a0)+,a4					; Get static copy word
	adda.w	a3,a4

	move.b	(a0)+,d5					; Get read first word
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#16,d6						; Initial shift value

GetEnigmaCode:
	moveq	#7,d0						; Assume a code entry is 7 bits
	move.w	d6,d7
	sub.w	d0,d7
	
	move.w	d5,d1						; Get code entry
	lsr.w	d7,d1
	andi.w	#$7F,d1
	move.w	d1,d2

	cmpi.w	#$40,d1						; Is this code entry actually 6 bits long?
	bcc.s	.GotCode					; If not, branch
	
	moveq	#6,d0						; Code entry is actually 6 bits
	lsr.w	#1,d2

.GotCode:
	bsr.w	AdvanceEnigmaBitstream				; Advance bitstream
	
	andi.w	#$F,d2						; Handle code
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	HandleEnigmaCode(pc,d1.w)

; ------------------------------------------------------------------------------

EnigmaCopyInc:
	move.w	a2,(a1)+					; Copy incremental copy word
	addq.w	#1,a2						; Increment it
	dbf	d2,EnigmaCopyInc				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyStatic:
	move.w	a4,(a1)+					; Copy static copy word
	dbf	d2,EnigmaCopyStatic				; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInline:
	bsr.w	ReadInlineEnigmaData				; Read inline data	

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineInc:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	addq.w	#1,d1						; Increment it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineDec:
	bsr.w	ReadInlineEnigmaData				; Read inline data

.Loop:
	move.w	d1,(a1)+					; Copy inline value
	subq.w	#1,d1						; Decrement it
	dbf	d2,.Loop					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

EnigmaCopyInlineMult:
	cmpi.w	#$F,d2						; Are we done?
	beq.s	EnigmaDone					; If so, branch

.Loop4:
	bsr.w	ReadInlineEnigmaData				; Read inline data
	move.w	d1,(a1)+					; Copy it
	dbf	d2,.Loop4					; Loop until finished
	bra.s	GetEnigmaCode

; ------------------------------------------------------------------------------

HandleEnigmaCode:
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyInc
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyStatic
	bra.s	EnigmaCopyInline
	bra.s	EnigmaCopyInlineInc
	bra.s	EnigmaCopyInlineDec
	bra.s	EnigmaCopyInlineMult

; ------------------------------------------------------------------------------

EnigmaDone:
	subq.w	#1,a0						; Go back by one byte
	cmpi.w	#16,d6						; Were we going to start a completely new byte?
	bne.s	.NotNewByte					; If not, branch
	subq.w	#1,a0						; Go back another

.NotNewByte:
	move.w	a0,d0						; Are we on an odd byte?
	lsr.w	#1,d0
	bcc.s	.Even						; If not, branch
	addq.w	#1,a0						; Ensure we're on an even byte

.Even:
	movem.l	(sp)+,d0-d7/a1-a5				; Restore registers
	rts

; ------------------------------------------------------------------------------

ReadInlineEnigmaData:
	move.w	a3,d3						; Copy base tile
	move.b	d4,d1						; Copy tile flags
	
	add.b	d1,d1						; Is the priority bit set?
	bcc.s	.NoPriority					; If not, branch
	
	subq.w	#1,d6						; Is the priority bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPriority					; If not, branch
	
	ori.w	#$8000,d3					; Set priority bit in the base tile

.NoPriority:
	add.b	d1,d1						; Is the high palette line bit set?
	bcc.s	.NoPal1						; If not, branch
	
	subq.w	#1,d6						; Is the high palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal1						; If not, branch
	
	addi.w	#$4000,d3					; Set high palette bit

.NoPal1:
	add.b	d1,d1						; Is the low palette line bit set?
	bcc.s	.NoPal0						; If not, branch
	
	subq.w	#1,d6						; Is the low palette bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoPal0						; If not, branch
	
	addi.w	#$2000,d3					; Set low palette bit

.NoPal0:
	add.b	d1,d1						; Is the Y flip bit set?
	bcc.s	.NoYFlip					; If not, branch
	
	subq.w	#1,d6						; Is the Y flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoYFlip					; If not, branch
	
	ori.w	#$1000,d3					; Set Y flip bit

.NoYFlip:
	add.b	d1,d1						; Is the X flip bit set?
	bcc.s	.NoXFlip					; If not, branch
	
	subq.w	#1,d6						; Is the X flip bit set in the inline flags?
	btst	d6,d5
	beq.s	.NoXFlip					; If not, branch
	
	ori.w	#$800,d3					; Set X flip bit

.NoXFlip:
	move.w	d5,d1						; Prepare to advance bitstream to tile ID
	move.w	d6,d7
	sub.w	a5,d7
	bcc.s	.GotEnoughBits					; If we don't need a new word, branch
	
	move.w	d7,d6						; Make space for the rest of the tile ID
	addi.w	#16,d6
	neg.w	d7
	lsl.w	d7,d1
	
	move.b	(a0),d5						; Add in the rest of the tile ID
	rol.b	d7,d5
	add.w	d7,d7
	and.w	EnigmaInlineMasks-2(pc,d7.w),d5
	add.w	d5,d1

.CombineBits:
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1

	add.w	d3,d1						; Add base tile
	
	move.b	(a0)+,d5					; Read another word from the bitstream
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts

.GotEnoughBits:
	beq.s	.JustEnough					; If the word has been exactly exhausted, branch
	
	lsr.w	d7,d1						; Shift tile data down
	
	move.w	a5,d0						; Mask out garbage
	add.w	d0,d0
	and.w	EnigmaInlineMasks-2(pc,d0.w),d1	
	
	add.w	d3,d1						; Add base tile

	move.w	a5,d0						; Advance bitstream
	bra.s	AdvanceEnigmaBitstream

.JustEnough:
	moveq	#16,d6						; Reset shift value
	bra.s	.CombineBits

; ------------------------------------------------------------------------------

EnigmaInlineMasks:
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001111
	dc.w	%0000000000011111
	dc.w	%0000000000111111
	dc.w	%0000000001111111
	dc.w	%0000000011111111
	dc.w	%0000000111111111
	dc.w	%0000001111111111
	dc.w	%0000011111111111
	dc.w	%0000111111111111
	dc.w	%0001111111111111
	dc.w	%0011111111111111
	dc.w	%0111111111111111
	dc.w	%1111111111111111

; ------------------------------------------------------------------------------

AdvanceEnigmaBitstream:
	sub.w	d0,d6						; Advance bitstream
	cmpi.w	#9,d6						; Does a new byte need to be read?
	bcc.s	.NoNewByte					; If not, branch
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte:
	rts

; ------------------------------------------------------------------------------
