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
; Load time attack menu
; ------------------------------------------------------------------------------

	xdef LoadTimeAttack
LoadTimeAttack:
	lea	TimeAttackMainFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bsr.w	ResetCddaVolume					; Play time attack song
	ifne REGION=USA
		lea	DaGardenSong(pc),a0
	else
		lea	TimeAttackSong(pc),a0
	endif
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS
	rts

; ------------------------------------------------------------------------------
