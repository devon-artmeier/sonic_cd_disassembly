; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Run palette cycle
; ------------------------------------------------------------------------------

	xdef PaletteCycle
PaletteCycle:
	addi.b	#$40,palette_cycle_delay			; Run delay timer
	bcs.s	.Update						; If it's time to update, branch
	rts

.Update:
	moveq	#0,d0						; Get frame
	move.b	palette_cycle_frame,d0
	addq.b	#1,d0						; Increment frame
	cmpi.b	#3,d0						; Is it time to wrap?
	bcs.s	.NoWrap						; If not, branch
	clr.b	d0						; Wrap back to start

.NoWrap:
	move.b	d0,palette_cycle_frame				; Update frame ID

	lea	.WaterPaletteCycle(pc),a1			; Set palette cycle colors
	lea	palette+(5*2),a2
	add.b	d0,d0
	add.b	d0,d0
	add.b	d0,d0
	lea	(a1,d0.w),a1
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	rts

; ------------------------------------------------------------------------------

.WaterPaletteCycle:
	dc.w	$ECC, $ECA, $EEE, $EA8
	dc.w	$EA8, $ECC, $ECC, $ECA
	dc.w	$ECA, $EA8, $ECA, $ECC

; ------------------------------------------------------------------------------
; Draw cloud tilemap
; ------------------------------------------------------------------------------

	xdef DrawCloudTilemap
DrawCloudTilemap:
	lea	VDP_CTRL,a2					; VDP control port
	lea	VDP_DATA,a3					; VDP data port

	move.w	#$8001,d6					; Draw buffer 1 tilemap
	vdpCmd move.l,$E000,VRAM,WRITE,d0
	moveq	#CLOUD_TILE_W-1,d1
	moveq	#CLOUD_TILE_H-1,d2
	bsr.s	.DrawMap

	move.w	#$8181,d6					; Draw buffer 2 tilemap
	vdpCmd move.l,$E040,VRAM,WRITE,d0
	moveq	#CLOUD_TILE_W-1,d1
	moveq	#CLOUD_TILE_H-1,d2

; ------------------------------------------------------------------------------

.DrawMap:
	move.l	#$800000,d4					; Row delta

.DrawRow:
	move.l	d0,(a2)						; Set VDP command
	move.w	d1,d3						; Get width
	move.w	d6,d5						; Get first column tile

.DrawTile:
	move.w	d5,(a3)						; Write tile ID
	addi.w	#CLOUD_TILE_H,d5				; Next column tile
	dbf	d3,.DrawTile					; Loop until row is written
	
	add.l	d4,d0						; Next row
	addq.w	#1,d6						; Next column tile
	dbf	d2,.DrawRow					; Loop until map is drawn
	rts

; ------------------------------------------------------------------------------
