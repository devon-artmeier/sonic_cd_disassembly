; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Based on smps2asm by Flamewing, based on S1SMPS2ASM version 1.1
; by Marc Gordon (AKA Cinossu)
; ------------------------------------------------------------------------------

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

cPCM1		equ 0
cPCM2		equ 1
cPCM3		equ 2
cPCM4		equ 3
cPCM5		equ 4
cPCM6		equ 5
cPCM7		equ 6
cPCM8		equ 7

; ------------------------------------------------------------------------------
; Header macros
; ------------------------------------------------------------------------------

smpsHeaderStartSong macro
	songStart:	set *
	dc.w	0
	endm

smpsHeaderStartSongConvert macro
	songStart:	set *
	dc.w	0
	endm

; Header - Set up channel Usage
smpsHeaderChan macro
	dc.b	\1, 0
	endm

; Header - Set up tempo
smpsHeaderTempo macro
	dc.b	\1, \2
	endm

; Header - Set up channel
smpsHeaderPCM macro
	dc.w	(\1)-songStart
	dc.b	\2, \3
	endm

; Header - Set up SFX tempo
smpsHeaderTempoSFX macro
	dc.b	\1
	endm

; Header - Set up SFX channel Usage
smpsHeaderChanSFX macro
	dc.b	\1
	endm

; Header - Set up SFX channel
smpsHeaderSFXChannel macro
	dc.b	$80, \1
	dc.w	(\2)-songStart
	dc.b	\3, \4
	endm

; ------------------------------------------------------------------------------
; Command macros and definitions
; ------------------------------------------------------------------------------

; E0xx - Panning
smpsPan macro
	dc.b	$E0, \1
	endm

; E1xx - Set channel detune to xx
smpsAlterNote macro
	dc.b	$E1, \1
	endm

; E2xx - Useless
smpsNop macro
	dc.b	$E2, \1
	endm

; E3xx - Start CDDA loop
smpsCDDALoop macro
	dc.b	$E3
	endm

; E6xx - Alter Volume
smpsAlterVol macro
	dc.b	$E6, \1
	endm

; E7 - Prevent attack of next note
smpsNoAttack	equ $E7

; E8xx - Set note fill to xx
smpsNoteFill macro
	dc.b	$E8, \1
	endm

; EAxx - Set music tempo modifier to xx
smpsSetTempoMod macro
	dc.b	$EA, \1
	endm

; EBxx - Play sound xx
smpsPlaySound macro
	dc.b	$EB, \1
	endm

; EFxx - Set Voice of channel to xx
smpsSetvoice macro
	dc.b	$EF, \1
	endm

; F2 - End of channel
smpsStop macro
	dc.b	$F2
	endm

; F6xxxx - Jump to xxxx
smpsJump macro
	dc.b	$F6
	dc.w	(\1)-*-1
	endm

; F7xxyyzzzz - Loop back to zzzz yy times, xx being the loop index for loop recursion fixing
smpsLoop macro
	dc.b	$F7, \1, \2
	dc.w	(\3)-*-1
	endm

; F8xxxx - Call pattern at xxxx, saving return point
smpsCall macro
	dc.b	$F8
	dc.w	(\1)-*-1
	endm

; F9 - Return
smpsReturn macro
	dc.b	$F9
	endm

; FAxx - Set channel tempo divider to xx
smpsChanTempoDiv macro
	dc.b	$FA, \1
	endm

; FBxx - Add xx to channel pitch
smpsAlterPitch macro
	dc.b	$FB, \1
	endm

; FCxx - Set music tempo divider to xx
smpsSetTempoDiv macro
	dc.b	$FC, \1
	endm

; FExxyy - Unknown
smpsUnkFE macro
	dc.b	$FE, \1, \2
	endm

; ------------------------------------------------------------------------------
