; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Unused functions to show a buffer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l - VDP control port
;	a2.l - VDP data port
; ------------------------------------------------------------------------------

	xdef ShowClouds1
ShowClouds1:
	move.w	#$8F20,(a1)					; Set for every 8 scanlines
	vdpCmd move.l,$D002,VRAM,WRITE,VDP_CTRL			; Write background scroll data
	moveq	#0,d0						; Show buffer 1
	bra.s	ShowClouds

; ------------------------------------------------------------------------------

	xdef ShowClouds2
ShowClouds2:
	move.w	#$8F20,(a1)					; Set for every 8 scanlines
	vdpCmd move.l,$D002,VRAM,WRITE,VDP_CTRL			; Write background scroll data
	move.w	#$100,d0					; Show buffer 2

; ------------------------------------------------------------------------------

	xdef ShowClouds
ShowClouds:
	rept	(CLOUD_HEIGHT-8)/8				; Set scroll offset for clouds
		move.w	d0,(a2)
	endr
	move.w	#$8F02,(a1)					; Restore autoincrement
	rts

; ------------------------------------------------------------------------------
; Scroll background (show buffer 1)
; ------------------------------------------------------------------------------

	xdef ScrollBackground1
ScrollBackground1:
	lea	hscroll,a1					; Show buffer 1
	moveq	#(CLOUD_HEIGHT-8)-1,d1

.ShowClouds:
	clr.l	(a1)+
	dbf	d1,.ShowClouds

	lea	water_scroll,a2					; Water scroll buffer
	moveq	#64-1,d2					; 64 scanlines
	move.l	#$1000,d1					; Speed accumulator
	move.l	#$4000,d0					; Initial speed

.MoveWaterSections:
	add.l	d0,(a2)+					; Move water line
	add.l	d1,d0						; Increase speed
	dbf	d2,.MoveWaterSections				; Loop until all lines are moved

	lea	water_scroll,a2					; Set water scroll positions
	lea	hscroll+(160*4),a1
	moveq	#64-1,d2					; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0						; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2					; Next line
	dbf	d2,.SetWaterScroll				; Loop until all scanlines are set
	rts

; ------------------------------------------------------------------------------
; Scroll background (show buffer 2)
; ------------------------------------------------------------------------------

	xdef ScrollBackground2
ScrollBackground2:
	lea	hscroll,a1					; Show buffer 2
	moveq	#(CLOUD_HEIGHT-8)-1,d1

.ShowClouds:
	move.l	#$100,(a1)+
	dbf	d1,.ShowClouds

	lea	water_scroll,a2					; Water scroll buffer
	moveq	#64-1,d2					; 64 scanlines
	move.l	#$1000,d1					; Speed accumulator
	move.l	#$4000,d0					; Initial speed

.MoveWaterSections:
	add.l	d0,(a2)+					; Move water line
	add.l	d1,d0						; Increase speed
	dbf	d2,.MoveWaterSections				; Loop until all lines are moved

	lea	water_scroll,a2					; Set water scroll positions
	lea	hscroll+(160*4),a1
	moveq	#64-1,d2					; 64 scanlines
	moveq	#0,d0

.SetWaterScroll:
	move.w	(a2),d0						; Set scanline offset
	move.l	d0,(a1)+
	lea	4(a2),a2					; Next line
	dbf	d2,.SetWaterScroll				; Loop until all scanlines are set
	rts

; ------------------------------------------------------------------------------
