; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Based on smps2asm by Flamewing, based on S1SMPS2ASM version 1.1
; by Marc Gordon (AKA Cinossu)
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Dirty macro to allow "dc.b" directives
; ------------------------------------------------------------------------------

dc.b macro
	ifnblank \1
		db	\1
	endif
	ifnblank \2
		db	\2
	endif
	ifnblank \3
		db	\3
	endif
	ifnblank \4
		db	\4
	endif
	ifnblank \5
		db	\5
	endif
	ifnblank \6
		db	\6
	endif
	ifnblank \7
		db	\7
	endif
	ifnblank \8
		db	\8
	endif
	ifnblank \9
		db	\9
	endif
	endm

; ------------------------------------------------------------------------------
; Note equates
; ------------------------------------------------------------------------------

nRst		equ $80
nC0		equ $81
nCs0		equ $82
nD0		equ $83
nEb0		equ $84
nE0		equ $85
nF0		equ $86
nFs0		equ $87
nG0		equ $88
nAb0		equ $89
nA0		equ $8A
nBb0		equ $8B
nB0		equ $8C
nC1		equ $8D
nCs1		equ $8E
nD1		equ $8F
nEb1		equ $90
nE1		equ $91
nF1		equ $92
nFs1		equ $93
nG1		equ $94
nAb1		equ $95
nA1		equ $96
nBb1		equ $97
nB1		equ $98
nC2		equ $99
nCs2		equ $9A
nD2		equ $9B
nEb2		equ $9C
nE2		equ $9D
nF2		equ $9E
nFs2		equ $9F
nG2		equ $A0
nAb2		equ $A1
nA2		equ $A2
nBb2		equ $A3
nB2		equ $A4
nC3		equ $A5
nCs3		equ $A6
nD3		equ $A7
nEb3		equ $A8
nE3		equ $A9
nF3		equ $AA
nFs3		equ $AB
nG3		equ $AC
nAb3		equ $AD
nA3		equ $AE
nBb3		equ $AF
nB3		equ $B0
nC4		equ $B1
nCs4		equ $B2
nD4		equ $B3
nEb4		equ $B4
nE4		equ $B5
nF4		equ $B6
nFs4		equ $B7
nG4		equ $B8
nAb4		equ $B9
nA4		equ $BA
nBb4		equ $BB
nB4		equ $BC
nC5		equ $BD
nCs5		equ $BE
nD5		equ $BF
nEb5		equ $C0
nE5		equ $C1
nF5		equ $C2
nFs5		equ $C3
nG5		equ $C4
nAb5		equ $C5
nA5		equ $C6
nBb5		equ $C7
nB5		equ $C8
nC6		equ $C9
nCs6		equ $CA
nD6		equ $CB
nEb6		equ $CC
nE6		equ $CD
nF6		equ $CE
nFs6		equ $CF
nG6		equ $D0
nAb6		equ $D1
nA6		equ $D2
nBb6		equ $D3
nB6		equ $D4
nC7		equ $D5
nCs7		equ $D6
nD7		equ $D7
nEb7		equ $D8
nE7		equ $D9
nF7		equ $DA
nFs7		equ $DB
nG7		equ $DC
nAb7		equ $DD
nA7		equ $DE
nBb7		equ $DF

; ------------------------------------------------------------------------------
; Channel IDs for SFX
; ------------------------------------------------------------------------------

cFM1		equ 0
cFM2		equ 1
cFM3		equ 2
cFM4		equ 4
cFM5		equ 5
cFM6		equ 6

; ------------------------------------------------------------------------------
; Header macros
; ------------------------------------------------------------------------------

smpsHeaderStartSong macro
	endm

smpsHeaderStartSongConvert macro
	endm

smpsHeaderVoiceNull macro
	dw	0
	endm

; Header - Set instrument table address
smpsHeaderVoice macro
	dw	\1
	endm

; Header - Set up tempo
smpsHeaderTempoSFX macro
	db	\1
	endm

; Header - Set up channel usage
smpsHeaderChanSFX macro
	db	\1
	endm

; Header - Set up FM channel
smpsHeaderSFXChannel macro
	db	80h, \1
	dw	\2
	db	\3, \4
	endm

; ------------------------------------------------------------------------------
; Command macros and definitions
; ------------------------------------------------------------------------------

panNone		equ 0
panRight	equ $40
panLeft		equ $80
panCentre	equ $C0
panCenter	equ $C0

; E0xx - Panning, AMS, FMS
smpsPan macro direction,amsfms
	db	$E0, (\1)+(\2)
	endm

; E1xx - Set pitch slide speed to xx
smpsSlideSpeed macro
	db	$E1, \1
	endm

; E2xx - Useless
smpsNop macro
	db	$E2, \1
	endm

; E3xx - Silence track
smpsSilence macro
	db	$E3
	endm

; E5xxyyyy - Loop end
smpsLoopEnd macro
	db	$E5, \1
	dw	\2
	endm

; E6xx - Alter volume
smpsFMAlterVol macro
	db	$E6, \1
	endm

; E7 - Prevent attack of next note
smpsNoAttack	equ $E7

; E8xx - Set note fill to xx
smpsNoteFill macro
	db	$E8, \1
	endm

; E9xxyy - Set LFO
smpsSetLFO macro
	db	$E9, \1, \2
	endm

; EBxxxx - Jump if condition is true	
smpsConditionalJumpCD macro
	db	$EB
	dw	\1
	endm

; EC - Reset ring channel
smpsResetRing macro
	db	$EC
	endm

; EDxxyy - FM command (track)
smpsFMCommand macro
	db	$ED, \1, \2
	endm

; EExxyy - FM command (part 1)
smpsFMICommand macro
	db	$EE, \1, \2
	endm

; EFxx - Set Voice of FM channel to xx
smpsSetvoice macro
	db	$EF, \1
	endm

; F0wwxxyyzz - Modulation - ww: wait time - xx: modulation speed - yy: change per step - zz: number of steps
smpsModSet macro
	db	$F0, \1, \2, \3, \4
	endm

; F1 - Turn off Modulation
smpsModOff macro
	db	$F1
	endm

; F2 - End of channel
smpsStop macro
	db	$F2
	endm

; F3 - Swap ring channels
smpsRingSwap macro
	db	$F3
	endm

; F6xxxx - Jump to xxxx
smpsJump macro
	db	$F6
	dw	\1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro
	db	$F7, \1, \2
	dw	\3
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro
	db	$F8
	dw	\1
	endm

; F9 - Return
smpsReturn macro
	db	$F9
	endm

; FAxx - Set channel tempo divider to xx
smpsChanTempoDiv macro
	db	$FA, \1
	endm

; FBxx - Add xx to channel pitc
smpsAlterPitch macro
	db	$FB, \1
	endm

; FCxx - Enable pitch slide
smpsPitchSlide macro
	db	$FC, \1
	endm

; FDxx - Enable alternate frequency mode
smpsAlternateSMPS macro
	db	$FD, \1
	endm

; FEwwxxyyzz - Enable FM3 special mode
smpsFM3SpecialMode macro
	db	$FE, \1, \2, \3, \4
	endm

; FF01xx - Set song tempo modifier to xx
smpsSetTempoMod macro
	db	$FF, 1, \1
	endm

; FF02xx - Play sound xx
smpsPlaySound macro
	db	$FF, 2, \1
	endm

; FF04xxxxyy - Copy data
smpsCopyData macro
	db	$FF, 4
	dw	\1
	db	\2
	endm

; FF06wwxxyyzz - Enable SSG-EG
smpsSSGEG macro
	db	$FF, 6, \1, \3, \2, \4
	endm

; ------------------------------------------------------------------------------
; Macros for FM instruments
; ------------------------------------------------------------------------------

; Voices - Feedback
smpsVcFeedback macro
vcFeedback set \1
	endm

; Voices - Algorithm
smpsVcAlgorithm macro
vcAlgorithm set \1
	endm

smpsVcUnusedBits macro
vcUnusedBits set \1
	endm

; Voices - Detune
smpsVcDetune macro
vcDT1 set \1
vcDT2 set \2
vcDT3 set \3
vcDT4 set \4
	endm

; Voices - Coarse-Frequency
smpsVcCoarseFreq macro
vcCF1 set \1
vcCF2 set \2
vcCF3 set \3
vcCF4 set \4
	endm

; Voices - Rate Scale
smpsVcRateScale macro
vcRS1 set \1
vcRS2 set \2
vcRS3 set \3
vcRS4 set \4
	endm

; Voices - Attack Rate
smpsVcAttackRate macro
vcAR1 set \1
vcAR2 set \2
vcAR3 set \3
vcAR4 set \4
	endm

; Voices - Amplitude Modulation
smpsVcAmpMod macro
vcAM1 set \1
vcAM2 set \2
vcAM3 set \3
vcAM4 set \4
	endm

; Voices - First Decay Rate
smpsVcDecayRate1 macro
vcD1R1 set \1
vcD1R2 set \2
vcD1R3 set \3
vcD1R4 set \4
	endm

; Voices - Second Decay Rate
smpsVcDecayRate2 macro
vcD2R1 set \1
vcD2R2 set \2
vcD2R3 set \3
vcD2R4 set \4
	endm

; Voices - Decay Level
smpsVcDecayLevel macro
vcDL1 set \1
vcDL2 set \2
vcDL3 set \3
vcDL4 set \4
	endm

; Voices - Release Rate
smpsVcReleaseRate macro
vcRR1 set \1
vcRR2 set \2
vcRR3 set \3
vcRR4 set \4
	endm

; Voices - Total Level
smpsVcTotalLevel macro
vcTL1 set \1
vcTL2 set \2
vcTL3 set \3
vcTL4 set \4
	db	(vcUnusedBits<<6)+(vcFeedback<<3)+vcAlgorithm
	;   0     1     2     3     4     5     6     7
	;%1000,%1000,%1000,%1000,%1010,%1110,%1110,%1111
	db	(vcDT4<<4)+vcCF4,  (vcDT3<<4)+vcCF3,  (vcDT2<<4)+vcCF2,  (vcDT1<<4)+vcCF1
	db	(vcRS4<<6)+vcAR4,  (vcRS3<<6)+vcAR3,  (vcRS2<<6)+vcAR2,  (vcRS1<<6)+vcAR1
	db	(vcAM4<<7)+vcD1R4, (vcAM3<<7)+vcD1R3, (vcAM2<<7)+vcD1R2, (vcAM1<<7)+vcD1R1
	db	vcD2R4,            vcD2R3,            vcD2R2,            vcD2R1
	db	(vcDL4<<4)+vcRR4,  (vcDL3<<4)+vcRR3,  (vcDL2<<4)+vcRR2,  (vcDL1<<4)+vcRR1
	db	vcTL4,             vcTL3,             vcTL2,             vcTL1
	endm

; ------------------------------------------------------------------------------
