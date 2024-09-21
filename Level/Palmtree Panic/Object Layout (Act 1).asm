; -------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; -------------------------------------------------------------------------
; Palmtree Panic Act 1 object layout
; -------------------------------------------------------------------------

ObjectLayouts:
	dc.w	.Layout-ObjectLayouts
	dc.w	.Null-ObjectLayouts

; -------------------------------------------------------------------------

	dc.w	$FFFF, 0, 0, 0
	
.Layout:
	incbin	"Level/Palmtree Panic/Data/Objects (Act 1).bin"

.Null:
	dc.w	$FFFF, 0, 0

; -------------------------------------------------------------------------
