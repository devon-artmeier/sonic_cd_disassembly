; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.l	#GraphicsIrq,_LEVEL1+2				; Set graphics interrupt handler
	move.l	#MegaDriveIrq,_USERCALL2+2			; Set Mega Drive interrupt handler
	move.b	#0,MCD_MEM_MODE					; Set to 2M mode

	moveq	#0,d0						; Clear communication registers
	move.w	d0,MCD_SUB_COMM_0
	move.b	d0,MCD_SUB_COMM_2
	move.l	d0,MCD_SUB_COMM_4
	move.l	d0,MCD_SUB_COMM_8
	move.l	d0,MCD_SUB_COMM_12

	bset	#7,MCD_SUB_FLAG					; Mark as started
	bclr	#1,MCD_IRQ_MASK					; Disable graphics interrupt
	bclr	#3,MCD_IRQ_MASK					; Disable timer interrupt
	move.b	#3,MCD_CDC_DEVICE				; Set CDC device to "Sub CPU"

	lea	VARIABLES,a0					; Clear variables
	move.w	#VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables

	bsr.w	InitCloudRender					; Initialize cloud rendering
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	WORD_RAM_2M,a0					; Clear Word RAM
	move.w	#WORD_RAM_2M_SIZE/8-1,d7

.ClearWordRam:
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	dbf	d7,.ClearWordRam

	lea	WORD_RAM_2M+$30000,a0				; Load unknown data
	move.w	#$8000/4-1,d7

.LoadUnkData:
	move.l	#$01080108,(a0)+
	dbf	d7,.LoadUnkData

	bsr.w	LoadCloudData					; Load cloud data
	bsr.w	InitCloudRenderParams				; Initialize cloud rendering parameters

	bset	#1,MCD_IRQ_MASK					; Enable graphics interrupt
	bclr	#7,MCD_SUB_FLAG					; Mark as initialized

; ------------------------------------------------------------------------------

MainLoop:
	btst	#0,MCD_MAIN_FLAG				; Is the Main CPU finished?
	beq.s	.NotDone					; If not, branch
	bset	#0,MCD_SUB_FLAG					; Respond to the Main CPU

.WaitMainCPUDone:
	btst	#0,MCD_MAIN_FLAG				; Has the Main CPU responded?
	bne.s	.WaitMainCPUDone				; If not, wait
	bclr	#0,MCD_SUB_FLAG					; Communication is done

	move.w	#FDRCHG,d0					; Fade CD audio out
	moveq	#$20,d1
	jsr	_CDBIOS

	moveq	#0,d1
	rts

.NotDone:
	move.b	MCD_MAIN_COMM_2,d0				; Should we run a cloud rendering?
	beq.s	MainLoop					; If not, branch
	move.b	MCD_MAIN_COMM_2,MCD_SUB_COMM_2			; Tell Main CPU we received the tip

.WaitMainCPU:
	tst.b	MCD_MAIN_COMM_2					; Has the Main CPU received our tip?
	bne.s	.WaitMainCPU					; If not, wait
	move.b	#0,MCD_SUB_COMM_2				; Communication is done

	bsr.w	GetCloudRenderSines				; Get sines for cloud rendering
	bsr.w	RenderClouds					; Render clouds
	bsr.w	ControlClouds					; Control the clouds
	bsr.w	WaitCloudsRender				; Wait for cloud rendering to be done
	
	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access
	bra.w	MainLoop					; Loop

; ------------------------------------------------------------------------------
; Initialize cloud rendering parameters
; ------------------------------------------------------------------------------

InitCloudRenderParams:
	lea	cloud_render_vars,a1				; Cloud rendering variables
	move.w	#$480,clouds.camera_x(a1)			; Camera X
	move.w	#$480,clouds.camera_y(a1)			; Camera Y
	move.w	#$140,clouds.camera_z(a1)			; Camera Z
	move.w	#$44,clouds.pitch(a1)				; Pitch
	move.w	#$100,clouds.yaw(a1)				; Yaw
	rts

; ------------------------------------------------------------------------------
; Control the clouds (if the cheat is entered, uses player 2 controls)
; ------------------------------------------------------------------------------

ControlClouds:
	lea	cloud_render_vars,a1				; Cloud rendering variables
	move.w	#4,d0						; Yaw rotation speed
	
	btst	#6,p2_ctrl_hold					; Is A being held?
	beq.s	.CheckC						; If not, branch
	
	sub.w	d0,clouds.yaw(a1)				; Rotate yaw
	andi.w	#$1FF,clouds.yaw(a1)

.CheckC:
	btst	#5,p2_ctrl_hold					; Is C being held?
	beq.s	.CheckB						; If not, branch
	
	add.w	d0,clouds.yaw(a1)				; Rotate yaw
	andi.w	#$1FF,clouds.yaw(a1)

.CheckB:
	moveq	#2,d0						; Normal scroll speed
	btst	#4,p2_ctrl_hold					; Is B being held?
	beq.s	.ScrollClouds					; If not, branch
	moveq	#4,d0						; Fast scroll speed

.ScrollClouds:
	add.w	d0,clouds.camera_y(a1)				; Scroll clouds

	btst	#0,p2_ctrl_hold					; Is up being held?
	beq.s	.CheckDown					; If not, branch
	
	subq.w	#2,clouds.pitch(a1)				; Rotate pitch
	bcc.s	.CheckDown					; If it hasn't underflowed, branch
	clr.w	clouds.pitch(a1)				; Cap pitch rotation

.CheckDown:
	btst	#1,p2_ctrl_hold					; Is down being held?
	beq.s	.CheckLeft					; If not, branch
	
	addq.w	#2,clouds.pitch(a1)				; Rotate pitch
	cmpi.w	#$50,clouds.pitch(a1)				; Has it rotated too much?
	bcs.s	.CheckLeft					; If not, branch
	move.w	#$50,clouds.pitch(a1)				; Cap pitch rotation

.CheckLeft:
	btst	#2,p2_ctrl_hold					; Is up being held?
	beq.s	.CheckRight					; If not, branch
	
	addq.w	#8,clouds.camera_z(a1)				; Rotate pitch
	cmpi.w	#$7FF,clouds.camera_z(a1)			; Have we zoomed too much?
	bcs.s	.CheckRight					; If not, branch
	move.w	#$7FF,clouds.camera_z(a1)			; Cap camera Z

.CheckRight:
	btst	#3,p2_ctrl_hold					; Is down being held?
	beq.s	.End						; If not, branch
	
	subq.w	#8,clouds.camera_z(a1)				; Rotate pitch
	cmpi.w	#$80,clouds.camera_z(a1)			; Have we zoomed too much?
	bcc.s	.End						; If not, branch
	move.w	#$80,clouds.camera_z(a1)			; Cap camera Z

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for the clouds to be rendered
; ------------------------------------------------------------------------------

WaitCloudsRender:
	move.b	#1,clouds_rendering				; Set flag
	move	#$2000,sr					; Enable interrupts

.Wait:
	tst.b	clouds_rendering				; Is the rendering finished?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Give Main CPU Word RAM access
; ------------------------------------------------------------------------------

GiveWordRamAccess:
	btst	#0,MCD_MEM_MODE					; Do we have Word RAM access?
	bne.s	.End						; If not, branch
	bset	#0,MCD_MEM_MODE					; Give Main CPU Word RAM access
	btst	#0,MCD_MEM_MODE					; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait

.End:
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

WaitWordRamAccess:
	btst	#1,MCD_MEM_MODE					; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
; Initialize cloud rendering
; ------------------------------------------------------------------------------

InitCloudRender:
	lea	cloud_render_vars,a1				; Cloud rendering variables
	
	move.w	#%111,MCD_IMG_CTRL				; 32x32 stamps, 4096x4096 map, repeated
	move.w	#CLOUD_TILE_H-1,MCD_IMG_STRIDE			; Image buffer stride
	move.w	#CLOUD_IMAGE_BUFFER/4,MCD_IMG_START		; Image buffer address
	move.w	#0,MCD_IMG_OFFSET				; Image buffer offset
	move.w	#CLOUD_WIDTH,MCD_IMG_WIDTH			; Image buffer width
	
	move.w	#$80,clouds.fov(a1)				; Set FOV
	move.w	#-$40,clouds.center(a1)				; Set center point
	rts

; ------------------------------------------------------------------------------
; Get cloud rendering sines
; ------------------------------------------------------------------------------

GetCloudRenderSines:
	lea	cloud_render_vars,a6				; Cloud rendering variables
	
	move.w	clouds.pitch(a6),d3				; sin(pitch)
	bsr.w	CalcSine
	move.w	d3,clouds.pitch_sin(a6)

	move.w	clouds.pitch(a6),d3				; cos(pitch)
	bsr.w	CalcCosine
	move.w	d3,clouds.pitch_cos(a6)

	move.w	clouds.yaw(a6),d3				; sin(yaw)
	bsr.w	CalcSine
	move.w	d3,clouds.yaw_sin(a6)
	
	move.w	clouds.yaw(a6),d3				; cos(yaw)
	bsr.w	CalcCosine
	move.w	d3,clouds.yaw_cos(a6)

	move.w	clouds.yaw(a6),d3				; -sin(yaw)
	addi.w	#$100,d3
	bsr.w	CalcSine
	move.w	d3,clouds.yaw_sin_neg(a6)
	
	move.w	clouds.yaw(a6),d3				; -cos(yaw)
	addi.w	#$100,d3
	bsr.w	CalcCosine
	move.w	d3,clouds.yaw_cos_neg(a6)
	rts

; ------------------------------------------------------------------------------
; Render clouds
; ------------------------------------------------------------------------------

RenderClouds:
	bsr.w	GenerateTraceTable				; Generate trace table
	andi.b	#%11100111,MCD_MEM_MODE				; Disable priority mode
	move.w	#CLOUD_STAMP_MAP/4,MCD_IMG_STAMP_MAP		; Source image map address
	move.w	#CLOUD_HEIGHT,MCD_IMG_HEIGHT			; Image buffer height
	move.w	#CLOUD_TRACE_TABLE/4,MCD_IMG_TRACE		; Set trace table and start operation
	rts

; ------------------------------------------------------------------------------
; Generate trace table
; ------------------------------------------------------------------------------

GenerateTraceTable:
	lea	WORD_RAM_2M+CLOUD_TRACE_TABLE,a5		; Trace table buffer
	lea	cloud_render_vars,a6				; Cloud rendering variables
	
	move.w	clouds.camera_x(a6),d0				; Camera X
	lsl.w	#3,d0
	move.w	clouds.camera_y(a6),d1				; Camera Y
	lsl.w	#3,d1

	move.w	#-3,d2						; Initial line ID
	moveq	#8,d6						; 8 bit shifts

	move.w	clouds.pitch_cos(a6),d3				; cos(pitch) * sin(yaw)
	muls.w	clouds.yaw_sin(a6),d3
	asr.l	#5,d3
	move.w	d3,clouds.pc_ys(a6)

	move.w	clouds.pitch_cos(a6),d3				; cos(pitch) * cos(yaw)
	muls.w	clouds.yaw_cos(a6),d3
	asr.l	#5,d3
	move.w	d3,clouds.pc_yc(a6)

	move.w	clouds.fov(a6),d4				; FOV * sin(pitch) * sin(yaw)
	move.w	d4,d3
	muls.w	clouds.pitch_sin(a6),d3
	muls.w	clouds.yaw_sin(a6),d3
	asr.l	#5,d3
	move.l	d3,clouds.ps_ys_fov(a6)

	move.w	d4,d3						; FOV * sin(pitch) * cos(yaw)
	muls.w	clouds.pitch_sin(a6),d3
	muls.w	clouds.yaw_cos(a6),d3
	asr.l	#5,d3
	move.l	d3,clouds.ps_yc_fov(a6)

	move.w	d4,d3						; FOV * cos(pitch)
	muls.w	clouds.pitch_cos(a6),d3
	move.l	d3,clouds.pc_fov(a6)

	move.w	#-128,d3					; -128 * cos(yaw)
	muls.w	clouds.yaw_cos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a1

	move.w	#-128,d3					; -128 * sin(yaw)
	muls.w	clouds.yaw_sin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a2

	move.w	#127,d3						; 127 * cos(yaw)
	muls.w	clouds.yaw_cos(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a3

	move.w	#127,d3						; 127 * sin(yaw)
	muls.w	clouds.yaw_sin(a6),d3
	lsl.l	#3,d3
	movea.l	d3,a4

	move.w	clouds.pitch_sin(a6),d4				; (sin(pitch) * sin(yaw)) * (FOV + center point)
	muls.w	clouds.yaw_sin(a6),d4
	asr.l	#5,d4
	move.w	clouds.fov(a6),d3
	add.w	clouds.center(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,clouds.center_x(a6)

	move.w	clouds.pitch_sin(a6),d4				; (sin(pitch) * cos(yaw)) * (FOV + center point)
	muls.w	clouds.yaw_cos(a6),d4
	asr.l	#5,d4
	move.w	clouds.fov(a6),d3
	add.w	clouds.center(a6),d3
	muls.w	d4,d3
	asr.l	d6,d3
	move.w	d3,clouds.center_y(a6)

	move.w	#CLOUD_HEIGHT-1,d7				; Number of lines

; ------------------------------------------------------------------------------

.GenLoop:
	; X point = -(line * cos(pitch) * sin(yaw)) + (FOV * sin(pitch) * sin(yaw))
	; Y point =  (line * cos(pitch) * cos(yaw)) - (FOV * sin(pitch) * cos(yaw))
	; Z point =  (line * sin(pitch)) + (FOV * cos(pitch))
	
	; Shear left X  = Camera X + (((127 * cos(yaw)) + X point) * (Camera Z / Z point)) - Center X
	; Shear left Y  = Camera Y + (((127 * sin(yaw)) + Y point) * (Camera Z / Z point)) + Center Y
	; Shear right X = Camera X + (((-128 * cos(yaw)) + X point) * (Camera Z / Z point)) - Center X
	; Shear right Y = Camera Y + (((-128 * sin(yaw)) + Y point) * (Camera Z / Z point)) + Center Y

	move.w	d2,d3						; Z point
	muls.w	clouds.pitch_sin(a6),d3
	add.l	clouds.pc_fov(a6),d3
	asr.l	#5,d3
	bne.s	.NotZero
	moveq	#1,d3

.NotZero:
	move.l	a3,d4						; X start = Shear left X
	move.w	clouds.pc_ys(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	clouds.ps_ys_fov(a6),d4
	asr.l	d6,d4
	muls.w	clouds.camera_z(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	clouds.center_x(a6),d4
	move.w	d4,(a5)+
	
	move.l	a4,d4						; Y start = Shear left Y
	move.w	clouds.pc_yc(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	clouds.ps_yc_fov(a6),d4
	asr.l	d6,d4
	muls.w	clouds.camera_z(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	clouds.center_y(a6),d4
	move.w	d4,(a5)+
	
	move.l	a1,d4						; X delta = Shear right X - Shear left X
	move.w	clouds.pc_ys(a6),d5
	muls.w	d2,d5
	sub.l	d5,d4
	add.l	clouds.ps_ys_fov(a6),d4
	asr.l	d6,d4
	muls.w	clouds.camera_z(a6),d4
	divs.w	d3,d4
	add.w	d0,d4
	sub.w	clouds.center_x(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+
	
	move.l	a2,d4						; Y delta = Shear right Y - Shear left Y
	move.w	clouds.pc_yc(a6),d5
	muls.w	d2,d5
	add.l	d5,d4
	sub.l	clouds.ps_yc_fov(a6),d4
	asr.l	d6,d4
	muls.w	clouds.camera_z(a6),d4
	divs.w	d3,d4
	add.w	d1,d4
	add.w	clouds.center_y(a6),d4
	sub.w	-4(a5),d4
	move.w	d4,(a5)+

	subq.w	#1,d2						; Next line
	dbf	d7,.GenLoop					; Loop until entire table is generated
	rts

; ------------------------------------------------------------------------------
; Get sine or cosine of a value
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d3.w - Value
; RETURNS:
;	d3.w - Sine/cosine of value
; ------------------------------------------------------------------------------

CalcCosine:
	addi.w	#$80,d3						; Offset value for cosine

CalcSine:
	andi.w	#$1FF,d3					; Keep within range
	move.w	d3,d4
	btst	#7,d3						; Is the value the 2nd or 4th quarters of the sinewave?
	beq.s	.NoInvert					; If not, branch
	not.w	d4						; Invert value to fit sinewave pattern

.NoInvert:
	andi.w	#$7F,d4						; Get sine/cosine value
	add.w	d4,d4
	move.w	SineTable(pc,d4.w),d4

	btst	#8,d3						; Was the input value in the 2nd half of the sinewave?
	beq.s	.SetValue					; If not, branch
	neg.w	d4						; Negate value

.SetValue:
	move.w	d4,d3						; Set final value
	rts

; ------------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0003, $0006, $0009, $000C, $000F, $0012, $0016
	dc.w	$0019, $001C, $001F, $0022, $0025, $0028, $002B, $002F
	dc.w	$0032, $0035, $0038, $003B, $003E, $0041, $0044, $0047
	dc.w	$004A, $004D, $0050, $0053, $0056, $0059, $005C, $005F
	dc.w	$0062, $0065, $0068, $006A, $006D, $0070, $0073, $0076
	dc.w	$0079, $007B, $007E, $0081, $0084, $0086, $0089, $008C
	dc.w	$008E, $0091, $0093, $0096, $0099, $009B, $009E, $00A0
	dc.w	$00A2, $00A5, $00A7, $00AA, $00AC, $00AE, $00B1, $00B3
	dc.w	$00B5, $00B7, $00B9, $00BC, $00BE, $00C0, $00C2, $00C4
	dc.w	$00C6, $00C8, $00CA, $00CC, $00CE, $00D0, $00D1, $00D3
	dc.w	$00D5, $00D7, $00D8, $00DA, $00DC, $00DD, $00DF, $00E0
	dc.w	$00E2, $00E3, $00E5, $00E6, $00E7, $00E9, $00EA, $00EB
	dc.w	$00EC, $00EE, $00EF, $00F0, $00F1, $00F2, $00F3, $00F4
	dc.w	$00F5, $00F6, $00F7, $00F7, $00F8, $00F9, $00FA, $00FA
	dc.w	$00FB, $00FB, $00FC, $00FC, $00FD, $00FD, $00FE, $00FE
	dc.w	$00FE, $00FF, $00FF, $00FF, $00FF, $00FF, $00FF, $0100

; ------------------------------------------------------------------------------
; Graphics interrupt
; ------------------------------------------------------------------------------

GraphicsIrq:
	clr.b	clouds_rendering				; Clear cloud rendering flag
	rte

; ------------------------------------------------------------------------------
; Mega Drive interrupt
; ------------------------------------------------------------------------------

MegaDriveIrq:
	rts

; ------------------------------------------------------------------------------
; Decompress Kosinski data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Kosinski data pointer
;	a1.l - Destination buffer pointer
; ------------------------------------------------------------------------------

DecompressKosinski:
	subq.l	#2,sp						; Allocate 2 bytes on the stack
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

GetKosinskiCode:
	lsr.w	#1,d5						; Should we just copy a new byte?
	move	sr,d6
	dbf	d4,.NoNewDesc					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc:
	move	d6,ccr
	bcc.s	CopyKosinskiBack				; If not, branch

	move.b	(a0)+,(a1)+					; Copy new byte
	bra.s	GetKosinskiCode					; Get next code

; ------------------------------------------------------------------------------

CopyKosinskiBack:
	moveq	#0,d3						; Reset copy length
	
	lsr.w	#1,d5						; Should we read a larger copy length value?
	move	sr,d6
	dbf	d4,.NoNewDesc					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc:
	move	d6,ccr			
	bcs.s	LargeKosinskiCopy				; If so, branch

	lsr.w	#1,d5						; Get copy length bit 1
	dbf	d4,.NoNewDesc2					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc2:
	roxl.w	#1,d3						; Get copy length bit 0
	lsr.w	#1,d5
	dbf	d4,.NoNewDesc3					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc3:
	roxl.w	#1,d3
	addq.w	#1,d3

	moveq	#$FFFFFFFF,d2					; Get copy offset
	move.b	(a0)+,d2

	bra.s	CopyKosinskiBackLoop				; Start copying

; ------------------------------------------------------------------------------

LargeKosinskiCopy:
	move.b	(a0)+,d0					; Read 2 bytes
	move.b	(a0)+,d1
	
	moveq	#$FFFFFFFF,d2					; Get copy offset
	move.b	d1,d2
	lsl.w	#5,d2
	move.b	d0,d2

	andi.w	#7,d1						; Get 3-bit copy length
	beq.s	LargeKosinskiCopy8				; If we need an 8-bit copy length, branch
	
	move.b	d1,d3						;; Start copying
	addq.w	#1,d3

; ------------------------------------------------------------------------------

CopyKosinskiBackLoop:
	move.b	(a1,d2.w),d0					; Copy byte
	move.b	d0,(a1)+
	dbf	d3,CopyKosinskiBackLoop				; Loop until finished
	
	bra.s	GetKosinskiCode					; Get next code

; ------------------------------------------------------------------------------

LargeKosinskiCopy8:
	move.b	(a0)+,d1					; Get copy length
	beq.s	KosinskiDone					; If we are done, branch

	cmpi.b	#1,d1						; Should we get a new code?
	beq.w	GetKosinskiCode					; If so, branch

	move.b	d1,d3						; Start copying
	bra.s	CopyKosinskiBackLoop

; ------------------------------------------------------------------------------

KosinskiDone:
	addq.l	#2,sp						; Deallocate the 2 bytes
	rts

; ------------------------------------------------------------------------------
; Load clouds data
; ------------------------------------------------------------------------------

LoadCloudData:
	lea	CloudStamps(pc),a0				; Load stamp art
	lea	WORD_RAM_2M+$200,a1
	bsr.w	DecompressKosinski
	
	lea	CloudStampMap(pc),a0				; Load stamp map
	lea	WORD_RAM_2M+CLOUD_STAMP_MAP,a1
	bsr.w	DecompressKosinski
	rts

; ------------------------------------------------------------------------------
