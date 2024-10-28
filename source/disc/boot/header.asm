; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include "regions.inc"

; ------------------------------------------------------------------------------
; Disc header
; ------------------------------------------------------------------------------

	section data_header
	dc.b	"SEGADISCSYSTEM  "				; Disk type ID
	ifne REGION=JAPAN					; Volume ID
		dc.b	"SEGAIPSAMP ", 0
	endif
	ifne REGION=USA
		dc.b	"SEGASONICCD", 0
	endif
	ifne REGION=EUROPE
		dc.b	"SEGASONICCD", 0
	endif
	dc.w	$0100						; Volume version
	dc.w	$0001						; CD-ROM = $0001
	dc.b	"SONICCD    ", 0				; System name
	dc.w	$0000						; System version
	dc.w	$0000						; Always 0
	dc.l	$00000800					; IP disk address
	dc.l	$00000800					; IP load size
	dc.l	$00000000					; IP entry offset
	dc.l	$00000000					; IP work RAM size
	dc.l	$00001000					; SP disk address
	dc.l	$00007000					; SP load size
	dc.l	$00000000					; SP entry offset
	dc.l	$00000000					; SP work RAM size
	ifne REGION=JAPAN					; Build date
		dc.b	"08061993"
	endif
	ifne REGION=USA
		dc.b	"10061993"
	endif
	ifne REGION=EUROPE
		dc.b	"08271993"
	endif

; ------------------------------------------------------------------------------
; Game header
; ------------------------------------------------------------------------------

	section data_game_header
	ifne REGION=JAPAN
		dc.b	"SEGA MEGA DRIVE "			; Hardware ID
		dc.b	"(C)SEGA 1993.AUG"			; Release date
	endif
	ifne REGION=USA
		dc.b	"SEGA GENESIS    "			; Hardware ID
		dc.b	"(C)SEGA 1993.OCT"			; Release date
	endif
	ifne REGION=EUROPE
		dc.b	"SEGA MEGA DRIVE "			; Hardware ID
		dc.b	"(C)SEGA 1993.AUG"			; Release date
	endif
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	ifne REGION=JAPAN					; Game version
		dc.b	"GM G-6021  -00  "
	endif
	ifne REGION=USA
		dc.b	"GM MK-4407 -00  "
	endif
	ifne REGION=EUROPE
		dc.b	"GM MK-4407-00   "
	endif
	dc.b	"J               "				; I/O support
	dc.b	"                "				; Space
	dc.b	"                "
	dc.b	"                "
	dc.b	"                "
	dc.b	"                "
	ifne REGION=JAPAN					; Region
		dc.b	"J               "
	endif
	ifne REGION=USA
		dc.b	"U               "
	endif
	ifne REGION=EUROPE
		dc.b	"E               "
	endif

; ------------------------------------------------------------------------------
; Version number	
; ------------------------------------------------------------------------------

	section data_version
	ifne REGION=JAPAN
		dc.w	$0106
	endif
	ifne REGION=USA
		dc.w	$0109
	endif
	ifne REGION=EUROPE
		dc.w	$0109
	endif

; ------------------------------------------------------------------------------