; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Draw tilemaps
; ------------------------------------------------------------------------------

	xdef DrawTilemaps
DrawTilemaps:
	lea	VDP_CTRL,a2					; VDP control port
	lea	VDP_DATA,a3					; VDP data port

	lea	EmblemTilemap(pc),a0				; Draw emblem
	vdpCmd move.l,$C206,VRAM,WRITE,d0
	moveq	#$1A-1,d1
	moveq	#$13-1,d2
	bsr.s	DrawFgTilemap

	lea	WaterTilemap(pc),a0				; Draw water (left side)
	vdpCmd move.l,$EA00,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	DrawBgTilemap

	lea	WaterTilemap(pc),a0				; Draw water (right side)
	vdpCmd move.l,$EA40,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#8-1,d2
	bsr.s	DrawBgTilemap

	lea	MountainsTilemap(pc),a0				; Draw mountains
	vdpCmd move.l,$E580,VRAM,WRITE,d0
	moveq	#$20-1,d1
	moveq	#9-1,d2

; ------------------------------------------------------------------------------
; Draw background tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
;	a2.l - VDP control port
;	a3.l - VDP data port
; ------------------------------------------------------------------------------

	xdef DrawBgTilemap
DrawBgTilemap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width

.DrawTile:
	move.w	#$300,d6					; Get tile ID
	move.b	(a0)+,d6
	bne.s	.WriteTile					; If it's not blank, branch
	move.w	#0,d6

.WriteTile:
	move.w	d6,(a3)						; Write tile ID
	dbf	d3,.DrawTile					; Loop until row is drawn
	
	add.l	d4,d0						; Next row
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
; Draw foreground tilemap
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
;	a2.l - VDP control port
;	a3.l - VDP data port
; ------------------------------------------------------------------------------

	xdef DrawFgTilemap
DrawFgTilemap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width

.DrawTile:
	move.w	(a0)+,d6					; Get tile ID
	beq.s	.WriteTile					; If it's blank, branch
	addi.w	#$C000|($6D80/$20),d6				; Add base tile ID

.WriteTile:
	addi.w	#0,d6						; Write tile ID
	move.w	d6,(a3)
	dbf	d3,.DrawTile					; Loop until row is written
	
	add.l	d4,d0						; Next row
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
