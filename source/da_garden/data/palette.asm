; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section data

; ------------------------------------------------------------------------------

PaletteCycleIndex:
	dc.l	PaletteCycleA, PaletteCycleBgAC
	dc.l	PaletteCycleC, PaletteCycleBgAC
	dc.l	PaletteCycleD, PaletteCycleBgD

; ------------------------------------------------------------------------------

SpritePaletteCycleIndex:
	dc.w	SpritePaletteCycle0-SpritePaletteCycleIndex
	dc.w	SpritePaletteCycle1-SpritePaletteCycleIndex

; ------------------------------------------------------------------------------

SpritePaletteCycle0:
	incbin	"DA Garden/Data/Palette.bin", $40, $20
	even

SpritePaletteCycle1:
	incbin	"DA Garden/Data/Palette.bin", $40, $18
	dc.w	$EEE, $EE
	incbin	"DA Garden/Data/Palette.bin", $5C, 4
	even

; ------------------------------------------------------------------------------

MenuPalette:
	incbin	"DA Garden/Data/Palette.bin", $60, $20
	even

; ------------------------------------------------------------------------------

DaGardenPalette:
	incbin	"DA Garden/Data/Palette.bin"
DaGardenPaletteEnd:
	even

; ------------------------------------------------------------------------------
	
PaletteCycleA:
	dc.w	.Cycle0-PaletteCycleA
	dc.w	.Cycle1-PaletteCycleA
	dc.w	.Cycle2-PaletteCycleA
	dc.w	.Cycle3-PaletteCycleA
	dc.w	.Cycle4-PaletteCycleA
	dc.w	.Cycle5-PaletteCycleA
	dc.w	.Cycle6-PaletteCycleA
	dc.w	.Cycle7-PaletteCycleA
	dc.w	.Cycle8-PaletteCycleA
	dc.w	.Cycle9-PaletteCycleA
	dc.w	.Cycle10-PaletteCycleA
	dc.w	.Cycle11-PaletteCycleA
	dc.w	.Cycle12-PaletteCycleA
	dc.w	.Cycle13-PaletteCycleA
	dc.w	.Cycle14-PaletteCycleA
	dc.w	.Cycle15-PaletteCycleA
	dc.w	.Cycle16-PaletteCycleA
	dc.w	.Cycle15-PaletteCycleA
	dc.w	.Cycle14-PaletteCycleA
	dc.w	.Cycle13-PaletteCycleA
	dc.w	.Cycle12-PaletteCycleA
	dc.w	.Cycle11-PaletteCycleA
	dc.w	.Cycle10-PaletteCycleA
	dc.w	.Cycle9-PaletteCycleA
	dc.w	.Cycle8-PaletteCycleA
	dc.w	.Cycle7-PaletteCycleA
	dc.w	.Cycle6-PaletteCycleA
	dc.w	.Cycle5-PaletteCycleA
	dc.w	.Cycle4-PaletteCycleA
	dc.w	.Cycle3-PaletteCycleA
	dc.w	.Cycle2-PaletteCycleA
	dc.w	.Cycle1-PaletteCycleA
	
.Cycle0:
	dc.w	0, $EE0, $EE, $E02, $68, $AC, $E0, $80, $2E, $28, $EEE, $EAC, $A48, $626, $A2E, $22

.Cycle1:
	dc.w	0, $CE0, $EE, $C02, $68, $AC, $E0, $80, $2E, $28, $CEE, $CAC, $848, $426, $82E, $22

.Cycle2:
	dc.w	0, $CC0, $CE, $C02, $48, $8C, $C0, $60, $E, 8, $CCE, $C8C, $828, $406, $80E, 2

.Cycle3:
	dc.w	0, $CA0, $AE, $C02, $28, $6C, $A0, $40, $E, 8, $CAE, $C6C, $808, $406, $80E, 2

.Cycle4:
	dc.w	0, $AA0, $AE, $A02, $28, $6C, $A0, $40, $E, 8, $AAE, $A6C, $608, $206, $60E, 2

.Cycle5:
	dc.w	0, $A80, $8C, $A00, 6, $4A, $80, $20, $C, 6, $A8C, $A4A, $606, $204, $60C, 0

.Cycle6:
	dc.w	0, $860, $6C, $800, 6, $2A, $60, 0, $C, 6, $86C, $82A, $406, 4, $40C, 0

.Cycle7:
	dc.w	0, $640, $4C, $600, 6, $A, $40, 0, $C, 6, $64C, $60A, $206, 4, $20C, 0

.Cycle8:
	dc.w	0, $640, $4A, $600, 4, 8, $40, 0, $A, 4, $64A, $608, $204, 2, $20A, 0

.Cycle9:
	dc.w	0, $640, $48, $600, 2, 6, $40, 0, 8, 2, $648, $606, $202, 0, $208, 0

.Cycle10:
	dc.w	0, $640, $46, $600, 0, 4, $40, 0, 6, 0, $646, $604, $200, 0, $206, 0

.Cycle11:
	dc.w	0, $660, $66, $600, 0, $224, $440, $200, $206, 0, $826, $604, $200, 0, $406, 0

.Cycle12:
	dc.w	0, $680, $84, $400, $220, $244, $640, $420, $406, 0, $A26, $804, $200, 0, $606, 0

.Cycle13:
	dc.w	0, $6A0, $84, $400, $40, $264, $860, $620, $406, $200, $C06, $804, $200, 0, $806, 0

.Cycle14:
	dc.w	0, $6C0, $A4, $400, $40, $284, $A60, $820, $606, $200, $E06, $A04, $200, 0, $A06, 0

.Cycle15:
	dc.w	0, $6C0, $A4, $400, $40, $284, $C60, $820, $606, $200, $E08, $A04, $400, $200, $C06, 0

.Cycle16:
	dc.w	0, $6E0, $A4, $400, $40, $2A4, $E60, $840, $606, $200, $E08, $A04, $400, $200, $C06, 0

; ------------------------------------------------------------------------------

PaletteCycleC:
	dc.w	.Cycle0-PaletteCycleC
	dc.w	.Cycle1-PaletteCycleC
	dc.w	.Cycle2-PaletteCycleC
	dc.w	.Cycle3-PaletteCycleC
	dc.w	.Cycle4-PaletteCycleC
	dc.w	.Cycle5-PaletteCycleC
	dc.w	.Cycle6-PaletteCycleC
	dc.w	.Cycle7-PaletteCycleC
	dc.w	.Cycle8-PaletteCycleC
	dc.w	.Cycle9-PaletteCycleC
	dc.w	.Cycle10-PaletteCycleC
	dc.w	.Cycle11-PaletteCycleC
	dc.w	.Cycle12-PaletteCycleC
	dc.w	.Cycle13-PaletteCycleC
	dc.w	.Cycle14-PaletteCycleC
	dc.w	.Cycle15-PaletteCycleC
	dc.w	.Cycle16-PaletteCycleC
	dc.w	.Cycle15-PaletteCycleC
	dc.w	.Cycle14-PaletteCycleC
	dc.w	.Cycle13-PaletteCycleC
	dc.w	.Cycle12-PaletteCycleC
	dc.w	.Cycle11-PaletteCycleC
	dc.w	.Cycle10-PaletteCycleC
	dc.w	.Cycle9-PaletteCycleC
	dc.w	.Cycle8-PaletteCycleC
	dc.w	.Cycle7-PaletteCycleC
	dc.w	.Cycle6-PaletteCycleC
	dc.w	.Cycle5-PaletteCycleC
	dc.w	.Cycle4-PaletteCycleC
	dc.w	.Cycle3-PaletteCycleC
	dc.w	.Cycle2-PaletteCycleC
	dc.w	.Cycle1-PaletteCycleC
	
.Cycle0:
	dc.w	0, $EE0, $EE, $C00, $684, $4CA, $EA, $C0, $6AE, $46C, $EEE, $EEA, $EA6, $E44, $E28, $422

.Cycle1:
	dc.w	0, $CE0, $EE, $C00, $664, $4AA, $CA, $A0, $68E, $44C, $ECE, $ECA, $E86, $E24, $E08, $402

.Cycle2:
	dc.w	0, $CC0, $EE, $C00, $644, $48A, $AA, $80, $66E, $42C, $EAE, $EAA, $E66, $E04, $E08, $402

.Cycle3:
	dc.w	0, $CA0, $EE, $C00, $624, $46A, $8A, $60, $64E, $40C, $E8E, $E8A, $E46, $E04, $E08, $402

.Cycle4:
	dc.w	0, $AA0, $EE, $A00, $606, $44A, $6A, $40, $62E, $40A, $E6E, $E6A, $E26, $E04, $E08, $402

.Cycle5:
	dc.w	0, $A80, $EE, $600, $406, $22A, $6A, $40, $42E, $20A, $C4E, $C4A, $C06, $C04, $C08, $202

.Cycle6:
	dc.w	0, $860, $EE, $400, $206, $2A, $4A, $40, $22C, 8, $A2E, $A2A, $A06, $A04, $A08, 2

.Cycle7:
	dc.w	0, $640, $EE, $200, 6, $28, $2A, $40, $2C, 6, $80E, $80A, $806, $804, $A08, 2

.Cycle8:
	dc.w	0, $640, $EE, $200, 6, $28, $48, $40, $2A, 6, $60E, $60A, $606, $604, $808, 2

.Cycle9:
	dc.w	0, $640, $EE, $200, $22, $26, $46, $40, $28, 4, $60C, $608, $604, $602, $608, 0

.Cycle10:
	dc.w	0, $640, $EE, $200, $22, $24, $64, $40, $26, 2, $828, $824, $622, $402, $606, 0

.Cycle11:
	dc.w	0, $660, $EE, $200, $22, $24, $64, $40, $26, 2, $846, $842, $620, $402, $404, 0

.Cycle12:
	dc.w	0, $680, $EE, $200, $20, $24, $62, $20, $26, 2, $864, $840, $620, $400, $404, 0

.Cycle13:
	dc.w	0, $6A0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $402, 0

.Cycle14:
	dc.w	0, $6C0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $202, 0

.Cycle15:
	dc.w	0, $6C0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $202, 0

.Cycle16:
	dc.w	0, $6E0, $EE, $200, $20, $22, $62, $20, $26, 2, $864, $840, $620, $400, $202, 0

; ------------------------------------------------------------------------------

PaletteCycleD:
	dc.w	.Cycle0-PaletteCycleD
	dc.w	.Cycle1-PaletteCycleD
	dc.w	.Cycle2-PaletteCycleD
	dc.w	.Cycle3-PaletteCycleD
	dc.w	.Cycle4-PaletteCycleD
	dc.w	.Cycle5-PaletteCycleD
	dc.w	.Cycle6-PaletteCycleD
	dc.w	.Cycle7-PaletteCycleD
	dc.w	.Cycle8-PaletteCycleD
	dc.w	.Cycle9-PaletteCycleD
	dc.w	.Cycle10-PaletteCycleD
	dc.w	.Cycle11-PaletteCycleD
	dc.w	.Cycle12-PaletteCycleD
	dc.w	.Cycle13-PaletteCycleD
	dc.w	.Cycle14-PaletteCycleD
	dc.w	.Cycle15-PaletteCycleD
	dc.w	.Cycle16-PaletteCycleD
	dc.w	.Cycle15-PaletteCycleD
	dc.w	.Cycle14-PaletteCycleD
	dc.w	.Cycle13-PaletteCycleD
	dc.w	.Cycle12-PaletteCycleD
	dc.w	.Cycle11-PaletteCycleD
	dc.w	.Cycle10-PaletteCycleD
	dc.w	.Cycle9-PaletteCycleD
	dc.w	.Cycle8-PaletteCycleD
	dc.w	.Cycle7-PaletteCycleD
	dc.w	.Cycle6-PaletteCycleD
	dc.w	.Cycle5-PaletteCycleD
	dc.w	.Cycle4-PaletteCycleD
	dc.w	.Cycle3-PaletteCycleD
	dc.w	.Cycle2-PaletteCycleD
	dc.w	.Cycle1-PaletteCycleD
	
.Cycle0:
	dc.w	0, $4AA, $288, $244, $426, $44A, $62C, $606, $A86, $662, $8AA, $686, $446, $424, $46A, $220

.Cycle1:
	dc.w	0, $2AA, $88, $44, $226, $24A, $42C, $406, $886, $462, $6AA, $486, $246, $224, $26A, $20

.Cycle2:
	dc.w	0, $28A, $268, $24, $206, $22A, $40C, $406, $866, $442, $68A, $466, $226, $204, $24A, 0

.Cycle3:
	dc.w	0, $8A, $68, $24, 6, $2A, $20C, $206, $666, $242, $48A, $266, $26, 4, $4A, 0

.Cycle4:
	dc.w	0, $8A, $66, $204, 6, $2A, $20C, $206, $646, $222, $46A, $246, 6, 4, $4A, 0

.Cycle5:
	dc.w	0, $88, $64, $204, 6, $26, $C, 6, $626, $22, $44A, $226, 6, 4, $4A, 0

.Cycle6:
	dc.w	0, $88, $64, $202, 4, $24, $A, 6, $426, $22, $448, $206, 4, 2, $4A, 0

.Cycle7:
	dc.w	0, $88, $64, $202, 2, $22, 8, 4, $424, $22, $428, $204, 2, 0, $4A, 0

.Cycle8:
	dc.w	0, $88, $64, $202, $20, $22, 8, 4, $424, $22, $408, $204, 2, 0, $4A, 0

.Cycle9:
	dc.w	0, $88, $64, $202, $20, $22, 8, 4, $404, $22, $406, $204, 2, 0, $4A, 0

.Cycle10:
	dc.w	0, $88, $64, $202, $20, $22, 8, 4, $402, $22, $404, $204, 2, 0, $4A, 0

.Cycle11:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $404, $204, 2, 0, $4A, 0

.Cycle12:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $404, $202, 2, 0, $4A, 0

.Cycle13:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $404, $202, 2, 0, $4A, 0

.Cycle14:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $40, $202, 2, 0, $4A, 0

.Cycle15:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $40, $202, 2, 0, $4A, 0

.Cycle16:
	dc.w	0, $88, $44, $200, $20, $22, 8, 4, $402, $22, $40, $202, 2, 0, $4A, 0

; ------------------------------------------------------------------------------

PaletteCycleBgAC:
	dc.w	.Cycle0-PaletteCycleBgAC
	dc.w	.Cycle1-PaletteCycleBgAC
	dc.w	.Cycle2-PaletteCycleBgAC
	dc.w	.Cycle3-PaletteCycleBgAC
	dc.w	.Cycle4-PaletteCycleBgAC
	dc.w	.Cycle5-PaletteCycleBgAC
	dc.w	.Cycle6-PaletteCycleBgAC
	dc.w	.Cycle7-PaletteCycleBgAC
	dc.w	.Cycle8-PaletteCycleBgAC
	dc.w	.Cycle9-PaletteCycleBgAC
	dc.w	.Cycle10-PaletteCycleBgAC
	dc.w	.Cycle11-PaletteCycleBgAC
	dc.w	.Cycle12-PaletteCycleBgAC
	dc.w	.Cycle13-PaletteCycleBgAC
	dc.w	.Cycle14-PaletteCycleBgAC
	dc.w	.Cycle15-PaletteCycleBgAC
	dc.w	.Cycle16-PaletteCycleBgAC
	dc.w	.Cycle15-PaletteCycleBgAC
	dc.w	.Cycle14-PaletteCycleBgAC
	dc.w	.Cycle13-PaletteCycleBgAC
	dc.w	.Cycle12-PaletteCycleBgAC
	dc.w	.Cycle11-PaletteCycleBgAC
	dc.w	.Cycle10-PaletteCycleBgAC
	dc.w	.Cycle9-PaletteCycleBgAC
	dc.w	.Cycle8-PaletteCycleBgAC
	dc.w	.Cycle7-PaletteCycleBgAC
	dc.w	.Cycle6-PaletteCycleBgAC
	dc.w	.Cycle5-PaletteCycleBgAC
	dc.w	.Cycle4-PaletteCycleBgAC
	dc.w	.Cycle3-PaletteCycleBgAC
	dc.w	.Cycle2-PaletteCycleBgAC
	dc.w	.Cycle1-PaletteCycleBgAC
	
.Cycle0:
	dc.w	0, $E86, $EA8, $ECA, $ECC, $E64, $E64, $E64, $E64, $ECC, $ECC, $ECC, $ECC, $E64, $FFFF, $FFFF

.Cycle1:
	dc.w	0, $E66, $E88, $EAA, $EAC, $E44, $E44, $E44, $E44, $EAE, $EAC, $EAC, $EAC, $E44, $FFF, $FFF

.Cycle2:
	dc.w	0, $E46, $E68, $E8A, $E8C, $E24, $E24, $E24, $E24, $E8C, $E8C, $E8C, $E8C, $E24, $FFF, $FFF

.Cycle3:
	dc.w	0, $E26, $E48, $E6A, $E6C, $E04, $E04, $E04, $E04, $E6C, $E6C, $E6C, $E6C, $E04, $FFF, $FFF

.Cycle4:
	dc.w	0, $C26, $C48, $C6A, $C6C, $C04, $C04, $C04, $EA0, $C6C, $C6C, $C6C, $EA0, $C04, $FFF, $FFF

.Cycle5:
	dc.w	0, $C06, $C48, $C4A, $C4C, $C04, $C04, $C04, $EA0, $C4C, $C4C, $C4C, $EA0, $C04, $FFF, $FFF

.Cycle6:
	dc.w	0, $A06, $A08, $A0A, $A0C, $A04, $A04, $A04, $EA0, $A2C, $A2C, $A2C, $EA0, $A04, $FFF, $FFF

.Cycle7:
	dc.w	0, $806, $808, $80A, $80C, $804, $804, $E40, $EA0, $80C, $80C, $E60, $EA0, $804, $FFF, $FFF

.Cycle8:
	dc.w	0, $804, $806, $808, $80A, $802, $802, $E40, $EA0, $80A, $80A, $E60, $EA0, $802, $FFF, $FFF

.Cycle9:
	dc.w	0, $802, $804, $806, $808, $800, $800, $E40, $EA0, $808, $808, $E60, $EA0, $800, $FFF, $FFF

.Cycle10:
	dc.w	0, $800, $802, $804, $806, $800, $E40, $EA0, $EEE, $806, $E60, $EA0, $EEE, $800, $FFF, $FFF

.Cycle11:
	dc.w	0, $800, $800, $802, $804, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $800, $FFF, $FFF

.Cycle12:
	dc.w	0, $800, $800, $800, $802, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $800, $FFF, $FFF

.Cycle13:
	dc.w	0, $600, $600, $600, $600, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $600, $FFF, $FFF

.Cycle14:
	dc.w	0, $400, $400, $400, $400, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $400, $FFF, $FFF

.Cycle15:
	dc.w	0, $200, $200, $200, $200, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, $200, $FFF, $FFF

.Cycle16:
	dc.w	0, 0, 0, 0, 0, $800, $E40, $EA0, $EEE, $800, $E40, $EA0, $EEE, 0, $FFF, $FFF

; ------------------------------------------------------------------------------

PaletteCycleBgD:
	dc.w	.Cycle0-PaletteCycleBgD
	dc.w	.Cycle1-PaletteCycleBgD
	dc.w	.Cycle2-PaletteCycleBgD
	dc.w	.Cycle3-PaletteCycleBgD
	dc.w	.Cycle4-PaletteCycleBgD
	dc.w	.Cycle5-PaletteCycleBgD
	dc.w	.Cycle6-PaletteCycleBgD
	dc.w	.Cycle7-PaletteCycleBgD
	dc.w	.Cycle8-PaletteCycleBgD
	dc.w	.Cycle9-PaletteCycleBgD
	dc.w	.Cycle10-PaletteCycleBgD
	dc.w	.Cycle11-PaletteCycleBgD
	dc.w	.Cycle12-PaletteCycleBgD
	dc.w	.Cycle13-PaletteCycleBgD
	dc.w	.Cycle14-PaletteCycleBgD
	dc.w	.Cycle15-PaletteCycleBgD
	dc.w	.Cycle16-PaletteCycleBgD
	dc.w	.Cycle15-PaletteCycleBgD
	dc.w	.Cycle14-PaletteCycleBgD
	dc.w	.Cycle13-PaletteCycleBgD
	dc.w	.Cycle12-PaletteCycleBgD
	dc.w	.Cycle11-PaletteCycleBgD
	dc.w	.Cycle10-PaletteCycleBgD
	dc.w	.Cycle9-PaletteCycleBgD
	dc.w	.Cycle8-PaletteCycleBgD
	dc.w	.Cycle7-PaletteCycleBgD
	dc.w	.Cycle6-PaletteCycleBgD
	dc.w	.Cycle5-PaletteCycleBgD
	dc.w	.Cycle4-PaletteCycleBgD
	dc.w	.Cycle3-PaletteCycleBgD
	dc.w	.Cycle2-PaletteCycleBgD
	dc.w	.Cycle1-PaletteCycleBgD
	
.Cycle0:
	dc.w	0, $AC, $8A, $68, $46, $8A, $8A, $8A, $8A, $46, $46, $46, $46, $8A, $FFF, $FFF

.Cycle1:
	dc.w	0, $8C, $6A, $48, $28, $6A, $6A, $6A, $6A, $26, $26, $26, $26, $6A, $FFF, $FFF

.Cycle2:
	dc.w	0, $6C, $4A, $28, 6, $4A, $4A, $4A, $4A, 6, 6, 6, 6, $4A, $FFF, $FFF

.Cycle3:
	dc.w	0, $4C, $2A, 8, 6, $2A, $2A, $2A, $2A, 6, 6, 6, 6, $2A, $FFF, $FFF

.Cycle4:
	dc.w	0, $2C, $A, 8, 6, $A, $A, $A, $A, 6, 6, 6, 6, $A, $FFF, $FFF

.Cycle5:
	dc.w	0, $C, $A, 8, 6, $A, $A, $A, $A, 6, 6, 6, 6, $A, $FFF, $FFF

.Cycle6:
	dc.w	0, $A, 8, 6, 4, 8, 8, 8, 8, 4, 4, 4, 4, 8, $FFF, $FFF

.Cycle7:
	dc.w	0, 8, 6, 4, 2, 6, 6, 6, 6, 2, 2, 2, 2, 6, $FFF, $FFF

.Cycle8:
	dc.w	0, 6, 4, 2, 0, 4, 4, 4, 4, 0, 0, 0, 0, 4, $FFF, $FFF

.Cycle9:
	dc.w	0, 6, 4, 2, 0, 4, 4, 4, $C, 0, 0, 0, 0, 4, $FFF, $FFF

.Cycle10:
	dc.w	0, 6, 4, 2, 0, 4, 4, 8, $E, 0, 0, 0, $C, 4, $FFF, $FFF

.Cycle11:
	dc.w	0, 6, 4, 2, 0, 4, 4, 8, $E, 0, 0, 4, $C, 2, $FFF, $FFF

.Cycle12:
	dc.w	0, 4, 2, 0, 0, 4, 6, $A, $6E, 0, 4, 6, $2E, 0, $FFF, $FFF

.Cycle13:
	dc.w	0, 2, 2, 0, 0, 4, 6, $A, $E, 4, 6, $A, $8E, 0, $FFF, $FFF

.Cycle14:
	dc.w	0, 2, 0, 0, 0, 4, 6, $E, $AE, 4, 6, $E, $AE, 0, $FFF, $FFF

.Cycle15:
	dc.w	0, 2, 0, 0, 0, 4, 6, $E, $EE, 4, 6, $E, $EE, 0, $FFF, $FFF

.Cycle16:
	dc.w	0, 2, 0, 0, 0, 6, 8, $4E, $EE, 6, 8, $4E, $EE, 0, $FFF, $FFF

; ------------------------------------------------------------------------------

PalCycleTimes:
	dc.w	780
	dc.w	4
	dc.w	6
	dc.w	8
	dc.w	120
	dc.w	6
	dc.w	8
	dc.w	130
	dc.w	6
	dc.w	8
	dc.w	140
	dc.w	6
	dc.w	8
	dc.w	150
	dc.w	6
	dc.w	8
	dc.w	780
	dc.w	4
	dc.w	6
	dc.w	8
	dc.w	120
	dc.w	6
	dc.w	8
	dc.w	130
	dc.w	6
	dc.w	8
	dc.w	140
	dc.w	6
	dc.w	8
	dc.w	150
	dc.w	6
	dc.w	8

; ------------------------------------------------------------------------------
