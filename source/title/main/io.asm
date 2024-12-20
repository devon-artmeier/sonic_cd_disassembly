; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; ------------------------------------------------------------------------------

	xdef InitMegaDrive
InitMegaDrive:
	lea	VdpRegisters(pc),a0				; Set up VDP registers
	move.w	#$8000,d0
	moveq	#$13-1,d7

.SetVdpRegisters:
	move.b	(a0)+,d0
	move.w	d0,VDP_CTRL
	addi.w	#$100,d0
	dbf	d7,.SetVdpRegisters

	moveq	#$40,d0						; Set up controller ports
	move.b	d0,IO_CTRL_1
	move.b	d0,IO_CTRL_2
	move.b	d0,IO_CTRL_3
	move.b	#$C0,IO_DATA_1

	jsr	StopZ80(pc)					; Stop the Z80

	vramFill 0,$10000,0					; Clear VRAM

	lea	InitPalette(pc),a0				; Load palette
	lea	palette,a1
	moveq	#(InitPaletteEnd-InitPalette)/4-1,d7

.LoadPalette:
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	dbf	d7,.LoadPalette

	vdpCmd move.l,0,VSRAM,WRITE,VDP_CTRL			; Clear VSRAM
	move.l	#0,VDP_DATA

	jsr	StartZ80(pc)					; Start the Z80
	move.w	#$8134,ipx_vdp_reg_81				; Reset IPX VDP register 1 cache
	rts

; ------------------------------------------------------------------------------

VdpRegisters:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$E000/$2000					; Plane B location
	dc.b	$D400/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; BG color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-BLANK interrupt counter 0
	dc.b	%00000011					; Scroll by line
	dc.b	%00000000					; H32
	dc.b	$D000/$400					; Horizontal scroll table lcation
	dc.b	0						; Reserved
	dc.b	2						; Auto increment by 2
	dc.b	%00000001					; 64x32 tile plane size
	dc.b	0						; Window horizontal position 0
	dc.b	0						; Window vertical position 0
	even

InitPalette:
	incbin	"../data/palette_initial.pal"
InitPaletteEnd:

; ------------------------------------------------------------------------------
; Palette
; ------------------------------------------------------------------------------

	xdef TitlePalette
TitlePalette:
	incbin	"../data/palette.pal"
	even

; ------------------------------------------------------------------------------
; Stop the Z80
; ------------------------------------------------------------------------------

	xdef StopZ80
StopZ80:
	move	sr,saved_sr					; Save status register
	move	#$2700,sr					; Disable interrupts
	getZ80Bus						; Get Z80 bus access
	rts

; ------------------------------------------------------------------------------
; Start the Z80
; ------------------------------------------------------------------------------

	xdef StartZ80
StartZ80:
	releaseZ80Bus						; Release Z80 bus
	move	saved_sr,sr					; Restore status register
	rts

; ------------------------------------------------------------------------------
; Get cloud image
; ------------------------------------------------------------------------------

	xdef GetCloudImage
GetCloudImage:
	lea	WORD_RAM_2M+CLOUD_IMAGE_BUFFER,a1		; Rendered image in Word RAM
	lea	cloud_image,a2					; Destination buffer
	move.w	#(CLOUD_IMAGE_SIZE/$800)-1,d7			; Number of $800 byte chunks to copy

.CopyChunks:
	rept	$800/$80					; Copy $800 bytes
		bsr.s	Copy128
	endr
	dbf	d7,.CopyChunks					; Loop until chunks are copied
	rts

; ------------------------------------------------------------------------------
; Copy 128 bytes from a source to a destination buffer
; ------------------------------------------------------------------------------
; PARAMAETERS:
;	a1.l - Pointer to source
;	a2.l - Pointer to destination buffer
; RETURNS:
;	a2.l - Pointer to source buffer, advanced by $80 bytes
;	a2.l - Pointer to destination buffer, advanced by $80 bytes
; ------------------------------------------------------------------------------

	xdef Copy128
Copy128:
	movem.l	(a1)+,d0-d5/a3-a4				; Copy bytes
	movem.l	d0-d5/a3-a4,(a2)
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$20(a2)
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$40(a2)
	movem.l	(a1)+,d0-d5/a3-a4
	movem.l	d0-d5/a3-a4,$60(a2)
	lea	$80(a2),a2
	rts

; ------------------------------------------------------------------------------
