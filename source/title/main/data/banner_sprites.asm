; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

.Map:
	dc.w	.Frame0-.Map

.Frame0:
	dc.b	$10
	dc.b	0, 3, 0, 0, $BC
	dc.b	0, 3, 8, 0, $3C
	dc.b	$20, $D, 0, 4, $A4
	dc.b	$20, $D, 8, 4, $3C
	dc.b	$30, $D, 0, $C, $AC
	dc.b	$30, $D, 8, $C, $34
	dc.b	$40, $D, 0, $14, $A4
	dc.b	$40, $D, 8, $14, $3C
	dc.b	0, $F, 0, $1C, $C4
	dc.b	0, $F, 0, $2C, $E4
	dc.b	0, $F, 0, $3C, 4
	dc.b	0, $B, 0, $4C, $24
	dc.b	$20, $D, 0, $58, $C4
	dc.b	$20, $D, 0, $60, $E4
	dc.b	$20, $D, 0, $68, 4
	dc.b	$20, 9, 0, $70, $24
	even

; ------------------------------------------------------------------------------
