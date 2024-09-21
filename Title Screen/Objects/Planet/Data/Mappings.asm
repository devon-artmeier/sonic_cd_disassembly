; -------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; -------------------------------------------------------------------------
; Title screen planet sprite mappings
; -------------------------------------------------------------------------

.Map:
	dc.w	.Frame0-.Map

.Frame0:
	dc.b	$C
	dc.b	$CC, $E, 0, 0, $D8
	dc.b	$CC, $E, 0, $C, $F8
	dc.b	$D4, 5, 0, $18, $18
	dc.b	$E4, $F, 0, $1C, $D0
	dc.b	$E4, $F, 0, $2C, $F0
	dc.b	$E4, $F, 0, $3C, $10
	dc.b	4, $F, 0, $4C, $D0
	dc.b	4, $F, 0, $5C, $F0
	dc.b	4, $F, 0, $6C, $10
	dc.b	$24, $D, 0, $7C, $D8
	dc.b	$24, $D, 0, $84, $F8
	dc.b	$24, 4, 0, $8C, $18
	even

; -------------------------------------------------------------------------
