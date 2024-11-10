; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; MMD header
; ------------------------------------------------------------------------------

	mmd MMD_SUB, work_ram_file, $2000, Start, 0, 0

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	lea	game_variables,a0				; Clear variables
	move.w	#GAME_VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables
	ifne GAME_VARIABLES_SIZE&2
		clr.w	(a0)+
	endif
	ifne GAME_VARIABLES_SIZE&1
		clr.b	(a0)+
	endif

	lea	VdpRegisters(pc),a0				; Initialize Mega Drive hardware
	bsr.w	InitMegaDrive

	vdpCmd move.l,$E400,VRAM,WRITE,VDP_CTRL			; Reset horizontal scroll data
	move.l	#0,VDP_DATA

	vdpCmd move.l,0,CRAM,WRITE,VDP_CTRL			; Clear CRAM
	lea	VDP_DATA,a0
	moveq	#$80/4-1,d7

.ClearCram:
	move.l	#0,(a0)
	dbf	d7,.ClearCram
	
	resetZ80Off						; Set Z80 reset off
	bsr.w	StopZ80						; Stop the Z80

	lea	FmDriver(pc),a0					; Load FM sound driver
	lea	Z80_RAM,a1
	move.w	#FM_DRIVER_SIZE-1,d7

.LoadFmDriver:
	move.b	(a0)+,(a1)+
	dbf	d7,.LoadFmDriver

	resetZ80On						; Set Z80 reset on
	resetZ80Off						; Set Z80 reset off
	bsr.w	StartZ80					; Start the Z80

	move.b	#%10010000,title_flags				; Set title screen flags
	rts

; ------------------------------------------------------------------------------
