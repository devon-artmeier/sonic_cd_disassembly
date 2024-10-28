; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"variables.inc"
	include	"macros.inc"
	include	"smps2asm.inc"
	include	"data_labels.inc"

; ------------------------------------------------------------------------------
; Sound effects
; ------------------------------------------------------------------------------

	sfx FM_SKID,        Sfx90, $7A
	sfx FM_91,          Sfx91, $7A
	sfx FM_JUMP,        Sfx92, $7A
	sfx FM_HURT,        Sfx93, $7D
	sfx FM_RING_LOSS,   Sfx94, $7D
	sfx FM_RING,        Sfx95, $70
	sfx FM_DESTROY,     Sfx96, $70
	sfx FM_SHIELD,      Sfx97, $7A
	sfx FM_SPRING,      Sfx98, $70
	sfx FM_99,          Sfx99, $6D
	sfx FM_KACHING,     Sfx9A, $7D
	sfx FM_9B,          Sfx9B, $7A
	sfx FM_9C,          Sfx9C, $7A
	sfx FM_SIGNPOST,    Sfx9D, $70
	sfx FM_EXPLODE,     Sfx9E, $7A
	sfx FM_9F,          Sfx9F, $6D
	sfx FM_A0,          SfxA0, $70
	sfx FM_A1,          SfxA1, $6D
	sfx FM_A2,          SfxA2, $70
	sfx FM_A3,          SfxA3, $70
	sfx FM_A4,          SfxA4, $6D
	sfx FM_A5,          SfxA5, $6D
	sfx FM_A6,          SfxA6, $6D
	sfx FM_A7,          SfxA7, $70
	sfx FM_RING_LEFT,   SfxA8, $70
	sfx FM_A9,          SfxA9, $7D
	sfx FM_AA,          SfxAA, $70
	sfx FM_CHARGE_STOP, SfxAB, $7D
	sfx FM_AC,          SfxAC, $70
	sfx FM_AD,          SfxAD, $7D
	sfx FM_CHECKPOINT,  SfxAE, $7A
	sfx FM_BIG_RING,    SfxAF, $7A
	sfx FM_B0,          SfxB0, $70
	sfx FM_B1,          SfxB1, $70
	sfx FM_B2,          SfxB2, $70
	sfx FM_B3,          SfxB3, $6D
	sfx FM_B4,          SfxB4, $70
	sfx FM_B5,          SfxB5, $70
	sfx FM_B6,          SfxB6, $7A
	sfx FM_B7,          SfxB7, $70
	sfx FM_B8,          SfxB8, $7D
	sfx FM_B9,          SfxB9, $7D
	sfx FM_BA,          SfxBA, $6A
	sfx FM_BB,          SfxBB, $6D
	sfx FM_BC,          SfxBC, $7D
	sfx FM_TALLY,       SfxBD, $6D
	sfx FM_BE,          SfxBE, $6D
	sfx FM_BF,          SfxBF, $6D
	sfx FM_C0,          SfxC0, $70
	sfx FM_C1,          SfxC1, $70
	sfx FM_C2,          SfxC2, $70
	sfx FM_C3,          SfxC3, $7A
	sfx FM_C4,          SfxC4, $70
	sfx FM_C5,          SfxC5, $70
	sfx FM_C6,          SfxC6, $70
	sfx FM_C7,          SfxC7, $70
	sfx FM_WARP,        SfxC8, $7D
	sfx FM_C9,          SfxC9, $70
	sfx FM_CA,          SfxCA, $70
	sfx FM_CB,          SfxCB, $6D
	sfx FM_CC,          SfxCC, $6D
	sfx FM_CD,          SfxCD, $70
	sfx FM_CE,          SfxCE, $7A
	sfx FM_CF,          SfxCF, $70
	sfx FM_D0,          SfxD0, $6D
	sfx FM_D1,          SfxD1, $6D
	sfx FM_D2,          SfxD2, $7A
	sfx FM_D3,          SfxD3, $70
	sfx FM_D4,          SfxD4, $70
	sfx FM_D5,          SfxD5, $6D
	sfx FM_D6,          SfxD6, $6A
	sfx FM_D7,          SfxD7, $6D
	sfx FM_D8,          SfxD8, $70
	sfx FM_D9,          SfxD9, $70
	sfx FM_DA,          SfxDA, $70
	sfx FM_DB,          SfxDB, $70
	sfx FM_DC,          SfxDC, $70
	sfx FM_DD,          SfxDD, $70
	sfx FM_DE,          SfxDE, $70
	sfx FM_DF,          SfxDF, -1

; ------------------------------------------------------------------------------

	section data_sfx
Sfx90:
	include	"sfx/90.asm"
Sfx91:
	include	"sfx/91.asm"
Sfx92:
	include	"sfx/92.asm"
Sfx93:
	include	"sfx/93.asm"
Sfx94:
	include	"sfx/94.asm"
Sfx95:
	include	"sfx/95.asm"
Sfx96:
	include	"sfx/96.asm"
Sfx97:
	include	"sfx/97.asm"
Sfx98:
	include	"sfx/98.asm"
Sfx99:
	include	"sfx/99.asm"
Sfx9A:
	include	"sfx/9A.asm"
Sfx9B:
	include	"sfx/9B.asm"
Sfx9C:
	include	"sfx/9C.asm"
Sfx9D:
	include	"sfx/9D.asm"
Sfx9E:
	include	"sfx/9E.asm"
Sfx9F:
	include	"sfx/9F.asm"
SfxA0:
	include	"sfx/A0.asm"
SfxA1:
	include	"sfx/A1.asm"
SfxA2:
	include	"sfx/A2.asm"
SfxA3:
	include	"sfx/A3.asm"
SfxA4:
	include	"sfx/A4.asm"
SfxA5:
	include	"sfx/A5.asm"
SfxA6:
	include	"sfx/A6.asm"
SfxA7:
	include	"sfx/A7.asm"
SfxA8:
	include	"sfx/A8.asm"
SfxA9:
	include	"sfx/A9.asm"
SfxAA:
	include	"sfx/AA.asm"
SfxAB:
	include	"sfx/AB.asm"
SfxAC:
	include	"sfx/AC.asm"
SfxAD:
	include	"sfx/AD.asm"
SfxAE:
	include	"sfx/AE.asm"
SfxAF:
	include	"sfx/AF.asm"
SfxB0:
	include	"sfx/B0.asm"
SfxB1:
	include	"sfx/B1.asm"
SfxB2:
	include	"sfx/B2.asm"
SfxB3:
	include	"sfx/B3.asm"
SfxB4:
	include	"sfx/B4.asm"
SfxB5:
	include	"sfx/B5.asm"
SfxB6:
	include	"sfx/B6.asm"
SfxB7:
	include	"sfx/B7.asm"
SfxB8:
	include	"sfx/B8.asm"
SfxB9:
	include	"sfx/B9.asm"
SfxBA:
	include	"sfx/BA.asm"
SfxBB:
	include	"sfx/BB.asm"
SfxBC:
	include	"sfx/BC.asm"
SfxBD:
	include	"sfx/BD.asm"
SfxBE:
	include	"sfx/BE.asm"
SfxBF:
	include	"sfx/BF.asm"
SfxC0:
	include	"sfx/C0.asm"
SfxC1:
	include	"sfx/C1.asm"
SfxC2:
	include	"sfx/C2.asm"
SfxC3:
	include	"sfx/C3.asm"
SfxC4:
	include	"sfx/C4.asm"
SfxC5:
	include	"sfx/C5.asm"
SfxC6:
	include	"sfx/C6.asm"
SfxC7:
	include	"sfx/C7.asm"
SfxC8:
	include	"sfx/C8.asm"
SfxC9:
	include	"sfx/C9.asm"
SfxCA:
	include	"sfx/CA.asm"
SfxCB:
	include	"sfx/CB.asm"
SfxCC:
	include	"sfx/CC.asm"
SfxCD:
	include	"sfx/CD.asm"
SfxCE:
	include	"sfx/CE.asm"
SfxCF:
	include	"sfx/CF.asm"
SfxD0:
	include	"sfx/D0.asm"
SfxD1:
	include	"sfx/D1.asm"
SfxD2:
	include	"sfx/D2.asm"
SfxD3:
	include	"sfx/D3.asm"
SfxD4:
	include	"sfx/D4.asm"
SfxD5:
	include	"sfx/D5.asm"
SfxD6:
	include	"sfx/D6.asm"
SfxD7:
	include	"sfx/D7.asm"
SfxD8:
	include	"sfx/D8.asm"
SfxD9:
	include	"sfx/D9.asm"
SfxDA:
	include	"sfx/DA.asm"
SfxDB:
	include	"sfx/DB.asm"
SfxDC:
	include	"sfx/DC.asm"
SfxDD:
	include	"sfx/DD.asm"
SfxDE:
	include	"sfx/DE.asm"
SfxDF:
	include	"sfx/DF.asm"

; ------------------------------------------------------------------------------
