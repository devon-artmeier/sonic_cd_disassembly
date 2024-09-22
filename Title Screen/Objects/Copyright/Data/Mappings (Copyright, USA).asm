; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Title screen copyright text sprite mappings
; ------------------------------------------------------------------------------

.Map:
	dc.w	.Frame0-.Map
	dc.w	.Frame1-.Map

.Frame0:
	dc.b	3
	dc.b	0, $C, 0, 0, 0
	dc.b	0, 0, 0, 4, $20
	dc.b	0, $C, 0, 5, $28
	even

.Frame1:
	dc.b	3
	dc.b	0, $C, 0, 0, 0
	dc.b	0, $C, 0, 4, $20
	dc.b	0, $C, 0, 8, $40
	even

; ------------------------------------------------------------------------------
