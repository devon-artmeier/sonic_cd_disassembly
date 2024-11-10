; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Track info (time zone, title track X offset)
; ------------------------------------------------------------------------------

	xdef TrackInfo
TrackInfo:
	dc.w	0, 79
	dc.w	1, 60
	dc.w	2, 60
	dc.w	0, 75
	dc.w	1, 56
	dc.w	2, 56
	dc.w	0, 82
	dc.w	1, 64
	dc.w	2, 64
	dc.w	0, 75
	dc.w	1, 56
	dc.w	2, 56
	dc.w	0, 74
	dc.w	1, 55
	dc.w	2, 55
	dc.w	0, 68
	dc.w	1, 49
	dc.w	2, 49
	dc.w	0, 73
	dc.w	1, 51
	dc.w	2, 51
	dc.w	0, 90
	dc.w	0, 82
	dc.w	0, 96
	dc.w	0, 92
	dc.w	0, 116
	dc.w	0, 91
	dc.w	0, 98
	dc.w	0, 111
	dc.w	0, 87
	ifne REGION=USA
		dc.w	0, 104
		dc.w	0, 107
	else
		dc.w	0, 43
		dc.w	0, 12
	endif
TrackInfoEnd:

	xdef TRACK_COUNT
TRACK_COUNT	equ (TrackInfoEnd-TrackInfo)/4

; ------------------------------------------------------------------------------
