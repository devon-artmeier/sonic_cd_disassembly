; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"regions.inc"
	include	"system.inc"
	include	"system_symbols.inc"

	section code

; ------------------------------------------------------------------------------
; Load special stage 8 credits
; ------------------------------------------------------------------------------

	xdef LoadSpecialStage8End
LoadSpecialStage8End:
	lea	Special8EndFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayEndingSong					; Play ending song

; ------------------------------------------------------------------------------
; Load "Fun is infinite" screen
; ------------------------------------------------------------------------------

	xdef LoadFunIsInfinite
LoadFunIsInfinite:
	lea	FunIsInfiniteFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayBossSong					; Play boss song

; ------------------------------------------------------------------------------
; Load M.C. Sonic screen
; ------------------------------------------------------------------------------

	xdef LoadMcSonic
LoadMcSonic:
	lea	McSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayRound8ASong					; Play Metallic Madness Present song

; ------------------------------------------------------------------------------
; Load Tails screen
; ------------------------------------------------------------------------------

	xdef LoadTails
LoadTails:
	lea	TailsFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayDaGardenSong				; Play D.A. Garden song

; ------------------------------------------------------------------------------
; Load Batman Sonic screen
; ------------------------------------------------------------------------------

	xdef LoadBatman
LoadBatman:
	lea	BatmanSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayFinalBossSong				; Play final boss song

; ------------------------------------------------------------------------------
; Load cute Sonic screen
; ------------------------------------------------------------------------------

	xdef LoadCuteSonic
LoadCuteSonic:
	lea	CuteSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayRound1CSong					; Play Palmtree Panic Good Future song

; ------------------------------------------------------------------------------
; Load best staff times screen
; ------------------------------------------------------------------------------

	xdef LoadBestStaffTimes
LoadBestStaffTimes:
	lea	BestStaffTimesFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	SpeedShoesSong(pc),a0				; Play speed shoes song
	bsr.w	ResetCddaVolume
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS

; ------------------------------------------------------------------------------
