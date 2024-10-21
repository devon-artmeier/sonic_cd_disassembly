; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"constants.inc"
	include	"smps2asm.inc"
	
	section data

; ------------------------------------------------------------------------------
; Song index
; ------------------------------------------------------------------------------
	
	xdef SongIndex
SongIndex:

; ------------------------------------------------------------------------------
; Define sound effect
; ------------------------------------------------------------------------------

__sfx_id    set FM_START
sfx macro
	xdef \1
	section data_sfx_index
	dw	\2
	section data_sfx_priorities
	ifge \3
		db	\3
	endif
	section data_sfx
\2:
	include	\4
	\1:		equ __sfx_id
	__sfx_id:	set __sfx_id+1
	endm

; ------------------------------------------------------------------------------
; Sound effect index
; ------------------------------------------------------------------------------

	sfx FM_SKID,        Sfx90, $7A, "sfx/90.asm"
	sfx FM_91,          Sfx91, $7A, "sfx/91.asm"
	sfx FM_JUMP,        Sfx92, $7A, "sfx/92.asm"
	sfx FM_HURT,        Sfx93, $7D, "sfx/93.asm"
	sfx FM_RING_LOSS,   Sfx94, $7D, "sfx/94.asm"
	sfx FM_RING,        Sfx95, $70, "sfx/95.asm"
	sfx FM_DESTROY,     Sfx96, $70, "sfx/96.asm"
	sfx FM_SHIELD,      Sfx97, $7A, "sfx/97.asm"
	sfx FM_SPRING,      Sfx98, $70, "sfx/98.asm"
	sfx FM_99,          Sfx99, $6D, "sfx/99.asm"
	sfx FM_KACHING,     Sfx9A, $7D, "sfx/9A.asm"
	sfx FM_9B,          Sfx9B, $7A, "sfx/9B.asm"
	sfx FM_9C,          Sfx9C, $7A, "sfx/9C.asm"
	sfx FM_SIGNPOST,    Sfx9D, $70, "sfx/9D.asm"
	sfx FM_EXPLODE,     Sfx9E, $7A, "sfx/9E.asm"
	sfx FM_9F,          Sfx9F, $6D, "sfx/9F.asm"
	sfx FM_A0,          SfxA0, $70, "sfx/A0.asm"
	sfx FM_A1,          SfxA1, $6D, "sfx/A1.asm"
	sfx FM_A2,          SfxA2, $70, "sfx/A2.asm"
	sfx FM_A3,          SfxA3, $70, "sfx/A3.asm"
	sfx FM_A4,          SfxA4, $6D, "sfx/A4.asm"
	sfx FM_A5,          SfxA5, $6D, "sfx/A5.asm"
	sfx FM_A6,          SfxA6, $6D, "sfx/A6.asm"
	sfx FM_A7,          SfxA7, $70, "sfx/A7.asm"
	sfx FM_RING_LEFT,   SfxA8, $70, "sfx/A8.asm"
	sfx FM_A9,          SfxA9, $7D, "sfx/A9.asm"
	sfx FM_AA,          SfxAA, $70, "sfx/AA.asm"
	sfx FM_CHARGE_STOP, SfxAB, $7D, "sfx/AB.asm"
	sfx FM_AC,          SfxAC, $70, "sfx/AC.asm"
	sfx FM_AD,          SfxAD, $7D, "sfx/AD.asm"
	sfx FM_CHECKPOINT,  SfxAE, $7A, "sfx/AE.asm"
	sfx FM_BIG_RING,    SfxAF, $7A, "sfx/AF.asm"
	sfx FM_B0,          SfxB0, $70, "sfx/B0.asm"
	sfx FM_B1,          SfxB1, $70, "sfx/B1.asm"
	sfx FM_B2,          SfxB2, $70, "sfx/B2.asm"
	sfx FM_B3,          SfxB3, $6D, "sfx/B3.asm"
	sfx FM_B4,          SfxB4, $70, "sfx/B4.asm"
	sfx FM_B5,          SfxB5, $70, "sfx/B5.asm"
	sfx FM_B6,          SfxB6, $7A, "sfx/B6.asm"
	sfx FM_B7,          SfxB7, $70, "sfx/B7.asm"
	sfx FM_B8,          SfxB8, $7D, "sfx/B8.asm"
	sfx FM_B9,          SfxB9, $7D, "sfx/B9.asm"
	sfx FM_BA,          SfxBA, $6A, "sfx/BA.asm"
	sfx FM_BB,          SfxBB, $6D, "sfx/BB.asm"
	sfx FM_BC,          SfxBC, $7D, "sfx/BC.asm"
	sfx FM_TALLY,       SfxBD, $6D, "sfx/BD.asm"
	sfx FM_BE,          SfxBE, $6D, "sfx/BE.asm"
	sfx FM_BF,          SfxBF, $6D, "sfx/BF.asm"
	sfx FM_C0,          SfxC0, $70, "sfx/C0.asm"
	sfx FM_C1,          SfxC1, $70, "sfx/C1.asm"
	sfx FM_C2,          SfxC2, $70, "sfx/C2.asm"
	sfx FM_C3,          SfxC3, $7A, "sfx/C3.asm"
	sfx FM_C4,          SfxC4, $70, "sfx/C4.asm"
	sfx FM_C5,          SfxC5, $70, "sfx/C5.asm"
	sfx FM_C6,          SfxC6, $70, "sfx/C6.asm"
	sfx FM_C7,          SfxC7, $70, "sfx/C7.asm"
	sfx FM_WARP,        SfxC8, $7D, "sfx/C8.asm"
	sfx FM_C9,          SfxC9, $70, "sfx/C9.asm"
	sfx FM_CA,          SfxCA, $70, "sfx/CA.asm"
	sfx FM_CB,          SfxCB, $6D, "sfx/CB.asm"
	sfx FM_CC,          SfxCC, $6D, "sfx/CC.asm"
	sfx FM_CD,          SfxCD, $70, "sfx/CD.asm"
	sfx FM_CE,          SfxCE, $7A, "sfx/CE.asm"
	sfx FM_CF,          SfxCF, $70, "sfx/CF.asm"
	sfx FM_D0,          SfxD0, $6D, "sfx/D0.asm"
	sfx FM_D1,          SfxD1, $6D, "sfx/D1.asm"
	sfx FM_D2,          SfxD2, $7A, "sfx/D2.asm"
	sfx FM_D3,          SfxD3, $70, "sfx/D3.asm"
	sfx FM_D4,          SfxD4, $70, "sfx/D4.asm"
	sfx FM_D5,          SfxD5, $6D, "sfx/D5.asm"
	sfx FM_D6,          SfxD6, $6A, "sfx/D6.asm"
	sfx FM_D7,          SfxD7, $6D, "sfx/D7.asm"
	sfx FM_D8,          SfxD8, $70, "sfx/D8.asm"
	sfx FM_D9,          SfxD9, $70, "sfx/D9.asm"
	sfx FM_DA,          SfxDA, $70, "sfx/DA.asm"
	sfx FM_DB,          SfxDB, $70, "sfx/DB.asm"
	sfx FM_DC,          SfxDC, $70, "sfx/DC.asm"
	sfx FM_DD,          SfxDD, $70, "sfx/DD.asm"
	sfx FM_DE,          SfxDE, $70, "sfx/DE.asm"
	sfx FM_DF,          SfxDF, -1,  "sfx/DF.asm"

; ------------------------------------------------------------------------------
; SFX index
; ------------------------------------------------------------------------------
	
	section data_sfx_index
	xdef SfxIndex
SfxIndex:

; ------------------------------------------------------------------------------
; SFX priorities
; ------------------------------------------------------------------------------

	section data_sfx_priorities
	xdef SfxPriorities
SfxPriorities:

; ------------------------------------------------------------------------------
