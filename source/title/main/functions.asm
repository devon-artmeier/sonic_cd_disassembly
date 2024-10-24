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
; Render clouds
; ------------------------------------------------------------------------------

	xdef RenderClouds
RenderClouds:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	move.b	#1,MCD_MAIN_COMM_2				; Tell Sub CPU to render clouds

.WaitSubCpu:
	cmpi.b	#1,MCD_SUB_COMM_2				; Has the Sub CPU responded?
	beq.s	.CommDone					; If so, branch
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.WaitSubCpu					; If we should wait some more, loop

.CommDone:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	move.b	#0,MCD_MAIN_COMM_2				; Respond to the Sub CPU

.WaitSubCpu2:
	tst.b	MCD_SUB_COMM_2					; Has the Sub CPU responded?
	beq.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.WaitSubCpu2					; If we should wait some more, loop

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to start
; ------------------------------------------------------------------------------

	xdef WaitSubCpuStart
WaitSubCpuStart:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program started?
	bne.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitSubCpuStart					; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Wait for the Sub CPU program to finish initializing
; ------------------------------------------------------------------------------

	xdef WaitSubCpuInit
WaitSubCpuInit:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch
	
	btst	#7,MCD_SUB_FLAG					; Has the Sub CPU program initialized?
	beq.s	.End						; If so, branch
	
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitSubCpuInit					; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

; ------------------------------------------------------------------------------
; Give Sub CPU Word RAM access
; ------------------------------------------------------------------------------

	xdef GiveWordRamAccess
GiveWordRamAccess:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.Done						; If so, branch
	
	btst	#1,MCD_MEM_MODE					; Does the Sub CPU already have Word RAM Access?
	bne.s	.End						; If so, branch
	bset	#1,MCD_MEM_MODE					; Give Sub CPU Word RAM access

.Wait:
	btst	#1,MCD_MEM_MODE					; Has it been given?
	bne.s	.Done						; If so, branch
	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	.Wait						; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.Done:
	clr.l	sub_wait_time					; Reset Sub CPU wait time

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

	xdef WaitWordRamAccess
WaitWordRamAccess:
	cmpi.b	#4,sub_fail_count				; Is the Sub CPU deemed unreliable?
	bcc.s	.End						; If so, branch

	btst	#0,MCD_MEM_MODE					; Do we have Word RAM access?
	bne.s	.End						; If so, branch

	addq.w	#1,sub_wait_time				; Increment wait time
	bcc.s	WaitWordRamAccess				; If we should wait some more, loop
	addq.b	#1,sub_fail_count				; Increment Sub CPU fail count

.End:
	clr.l	sub_wait_time					; Reset Sub CPU wait time
	rts

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

	lea	InitPalette(pc),a0					; Load palette
	lea	palette,a1
	moveq	#(InitPaletteEnd-InitPalette)/4-1,d7

.LoadPal:
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	dbf	d7,.LoadPal

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
	dc.b	0						; H-INT counter 0
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
	incbin	"data/palette_initial.pal"
InitPaletteEnd:
	even

; ------------------------------------------------------------------------------
; Palette
; ------------------------------------------------------------------------------

	xdef TitlePalette
TitlePalette:
	incbin	"data/palette.pal"
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
; Advance data bitstream
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Branch to take if no new byte is needed (optional)
; ------------------------------------------------------------------------------

advanceBitstream macro
	cmpi.w	#9,d6						; Does a new byte need to be read?
	ifgt \#							; If not, branch
		bcc.s	\1
	else
		bcc.s	.NoNewByte\@
	endif
	
	addq.w	#8,d6						; Read next byte from bitstream
	asl.w	#8,d5
	move.b	(a0)+,d5

.NoNewByte\@:
	endm

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
	advanceBitstream

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
	advanceBitstream

	subq.w	#7,d6						; Read inline data
	move.w	d5,d1
	lsr.w	d6,d1
	move.w	d1,d0
	andi.w	#$F,d1						; Get palette index
	andi.w	#$70,d0						; Get repeat count
	
	advanceBitstream GetNemesisCodeLength			; Advance bitstream read data position
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
