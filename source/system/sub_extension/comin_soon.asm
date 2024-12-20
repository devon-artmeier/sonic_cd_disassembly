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
; Load "Comin' Soon" screen
; ------------------------------------------------------------------------------

	xdef LoadCominSoon
LoadCominSoon:
	lea	CominSoonFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bsr.w	ResetCddaVolume					; Play invincibility song
	lea	InvincibleSong(pc),a0
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS
	
; ------------------------------------------------------------------------------
