; -------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; -------------------------------------------------------------------------
; Title screen Sonic sprite mappings
; -------------------------------------------------------------------------

.Map:
	dc.w	.Frame0-.Map
	dc.w	.Frame1-.Map
	dc.w	.Frame2-.Map
	dc.w	.Frame3-.Map
	dc.w	.Frame4-.Map
	dc.w	.Frame5-.Map
	dc.w	.Frame6-.Map
	dc.w	.Frame7-.Map
	dc.w	.Frame8-.Map
	dc.w	.Frame9-.Map

.Frame0:
	dc.b	$11
	dc.b	8, $D, 0, 0, 0
	dc.b	8, $D, 0, 8, $20
	dc.b	8, 1, 0, $10, $40
	dc.b	$20, 3, 0, $12, $38
	dc.b	$28, 1, 0, $16, $40
	dc.b	$18, $D, 0, $18, 8
	dc.b	$18, 6, 0, $20, $28
	dc.b	$28, $E, 0, $26, 0
	dc.b	$28, 0, 0, $32, $20
	dc.b	$30, 3, 0, $33, $30
	dc.b	$40, 1, 0, $37, $38
	dc.b	$38, 7, 0, $39, $20
	dc.b	$58, 3, 0, $41, $28
	dc.b	$40, 5, 0, $45, $10
	dc.b	$58, 6, 0, $49, 8
	dc.b	$50, 2, 0, $4F, $30
	dc.b	$60, 5, 0, $52, $38
	even

.Frame1:
	dc.b	$11
	dc.b	$10, 7, 0, $56, 0
	dc.b	8, $D, 0, $5E, $18
	dc.b	8, 5, 0, $66, $38
	dc.b	$18, $E, 0, $6A, $10
	dc.b	$18, 6, 0, $76, $30
	dc.b	$20, 6, 0, $7C, $40
	dc.b	$30, $C, 0, $82, 0
	dc.b	$30, 8, 0, $86, $20
	dc.b	$38, 0, 0, $89, 8
	dc.b	$38, $D, 0, $8A, $10
	dc.b	$38, 7, 0, $92, $30
	dc.b	$48, 2, 0, $9A, $40
	dc.b	$48, 8, 0, $9D, $18
	dc.b	$50, $A, 0, $A0, 8
	dc.b	$68, $D, 0, $A9, $10
	dc.b	$78, 4, 0, $B1, $18
	dc.b	$58, 5, 0, $B3, $20
	even

.Frame2:
	dc.b	$D
	dc.b	0, $C, 0, $B7, $18
	dc.b	8, $F, 0, $BB, 0
	dc.b	8, $F, 0, $CB, $20
	dc.b	$18, 2, 0, $DB, $40
	dc.b	$28, $D, 0, $DE, 0
	dc.b	$28, $F, 0, $E6, $20
	dc.b	$38, 8, 0, $F6, 8
	dc.b	$40, 5, 0, $F9, $10
	dc.b	$48, $D, 0, $FD, $20
	dc.b	$40, 3, 1, 5, $40
	dc.b	$58, $E, 1, 9, $10
	dc.b	$50, 0, 1, $15, $18
	dc.b	$58, 1, 1, $16, $30
	even

.Frame3:
	dc.b	$10
	dc.b	8, $D, 1, $18, 0
	dc.b	0, $A, 1, $20, $20
	dc.b	8, 1, 1, $29, $38
	dc.b	$18, $C, 1, $2B, 8
	dc.b	$18, $C, 1, $2F, $28
	dc.b	$20, $D, 1, $33, 0
	dc.b	$20, $D, 1, $3B, $20
	dc.b	$20, 5, 1, $43, $40
	dc.b	$30, $E, 1, $47, 8
	dc.b	$30, $A, 1, $53, $28
	dc.b	$38, 5, 1, $5C, $40
	dc.b	$48, 8, 1, $60, $10
	dc.b	$48, $E, 1, $63, $28
	dc.b	$58, $A, 1, $6F, $10
	dc.b	$70, 4, 1, $78, $18
	dc.b	$60, 5, 1, $7A, $28
	even

.Frame4:
	dc.b	$11
	dc.b	0, $C, 1, $7E, $20
	dc.b	8, $F, 1, $82, 0
	dc.b	8, $F, 1, $92, $20
	dc.b	8, 1, 1, $A2, $40
	dc.b	$18, 7, 1, $A4, $40
	dc.b	$28, $C, 1, $AC, 0
	dc.b	$28, $F, 1, $B0, $20
	dc.b	$30, $B, 1, $C0, 8
	dc.b	$38, 7, 1, $CC, $40
	dc.b	$58, 0, 1, $D4, $48
	dc.b	$48, $F, 1, $D5, $20
	dc.b	$60, $E, 1, $E5, 0
	dc.b	$50, 4, 1, $F1, $10
	dc.b	$58, 8, 1, $F3, 8
	dc.b	$68, 9, 1, $F6, $20
	dc.b	$68, 0, 1, $FC, $38
	dc.b	$2E, $F, 2, $79, $10
	even

.Frame5:
	dc.b	$15
	dc.b	$18, $E, 2, $52, 0
	dc.b	$18, 6, 2, $5E, $20
	dc.b	$30, $E, 2, $64, 8
	dc.b	$30, 2, 1, $B5, $28
	dc.b	$40, $A, 2, $70, $20
	dc.b	0, $C, 1, $7E, $20
	dc.b	8, $F, 1, $82, 0
	dc.b	8, $F, 1, $92, $20
	dc.b	8, 1, 1, $A2, $40
	dc.b	$18, 7, 1, $A4, $40
	dc.b	$28, $C, 1, $AC, 0
	dc.b	$28, $F, 1, $B0, $20
	dc.b	$30, $B, 1, $C0, 8
	dc.b	$38, 7, 1, $CC, $40
	dc.b	$58, 0, 1, $D4, $48
	dc.b	$48, $F, 1, $D5, $20
	dc.b	$60, $E, 1, $E5, 0
	dc.b	$50, 4, 1, $F1, $10
	dc.b	$58, 8, 1, $F3, 8
	dc.b	$68, 9, 1, $F6, $20
	dc.b	$68, 0, 1, $FC, $38
	even

.Frame6:
	dc.b	4
	dc.b	$D4, 0, 1, $FD, $F8
	dc.b	$DC, 4, 1, $FE, $F8
	dc.b	$E4, $B, 2, 0, $F8
	dc.b	4, 5, 2, $C, 0
	even

.Frame7:
	dc.b	5
	dc.b	$D4, 5, 2, $10, 0
	dc.b	$EC, 0, $11, $E6, $F8
	dc.b	$E4, $B, 2, $14, 0
	dc.b	4, 8, 2, $20, 0
	dc.b	$C, 4, 2, $23, 0
	even

.Frame8:
	dc.b	5
	dc.b	$D4, 5, 2, $25, 8
	dc.b	$E4, 8, 2, $29, 0
	dc.b	$EC, $D, 2, $2C, 0
	dc.b	$FC, 9, 2, $34, 0
	dc.b	$C, 4, 2, $3A, 0
	even

.Frame9:
	dc.b	5
	dc.b	$D4, 5, 2, $3C, $18
	dc.b	$E4, $A, 2, $40, 8
	dc.b	$FC, 6, 2, $49, 0
	dc.b	$FC, 4, 2, $4F, $10
	dc.b	4, 0, 2, $51, $10
	even


; -------------------------------------------------------------------------
