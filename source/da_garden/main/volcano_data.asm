; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Frames
; ------------------------------------------------------------------------------

	xdef VolcanoAnimFrames
VolcanoAnimFrames:
	dc.w	.Frame0-VolcanoAnimFrames
	dc.w	.Frame1-VolcanoAnimFrames
	dc.w	.Frame2-VolcanoAnimFrames
	dc.w	.Frame3-VolcanoAnimFrames
	dc.w	.Frame4-VolcanoAnimFrames
	dc.w	.Frame5-VolcanoAnimFrames
	dc.w	.Frame0-VolcanoAnimFrames
	dc.w	.Frame7-VolcanoAnimFrames
	dc.w	.Frame8-VolcanoAnimFrames
	dc.w	.Frame9-VolcanoAnimFrames
	dc.w	.Frame10-VolcanoAnimFrames
	dc.w	.Frame11-VolcanoAnimFrames
	
.Frame0:
	dc.w	4, 0
	dc.w	8, $C
.Frame1:
	dc.w	$10, 0
	dc.w	8, $C
.Frame2:
	dc.w	$14, 0
	dc.w	8, $C
.Frame3:
	dc.w	$18, $1C
	dc.w	8, $C
.Frame4:
	dc.w	$20, $24
	dc.w	8, $C
.Frame5:
	dc.w	$28, $2C
	dc.w	8, $C
.Frame7:
	dc.w	4, 0
	dc.w	8, $30
.Frame8:
	dc.w	4, 0
	dc.w	$34, $38
.Frame9:
	dc.w	4, $3C
	dc.w	$40, $44
.Frame10:
	dc.w	$48, $4C
	dc.w	$50, $54
.Frame11:
	dc.w	$58, $5C
	dc.w	$60, $64

; ------------------------------------------------------------------------------
; Times
; ------------------------------------------------------------------------------

	xdef VolcanoAnimTimes
VolcanoAnimTimes:
	dc.w	40
	dc.w	3
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	5
	dc.w	80
	dc.w	4
	dc.w	5
	dc.w	6
	dc.w	7
	dc.w	6

; ------------------------------------------------------------------------------
