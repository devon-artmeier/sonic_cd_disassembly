; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Disc header
; ------------------------------------------------------------------------------

	section disc_header

	dc.b	"SEGADISCSYSTEM  "				; Disk type ID
	;if REGION=JAPAN						; Volume ID
	;	dc.b	"SEGAIPSAMP ", 0
	;else
		dc.b	"SEGASONICCD", 0
	;endif
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
	;if REGION=JAPAN					; Build date
	;	dc.b	"08061993"
	;elseif REGION=USA
		dc.b	"10061993"
	;else
	;	dc.b	"08271993"
	;endif

; ------------------------------------------------------------------------------
; Game header
; ------------------------------------------------------------------------------

	section disc_game_header

	;if REGION=JAPAN
	;	dc.b	"SEGA MEGA DRIVE "			; Hardware ID
	;	dc.b	"(C)SEGA 1993.AUG"			; Release date
	;elseif REGION=USA
		dc.b	"SEGA GENESIS    "			; Hardware ID
		dc.b	"(C)SEGA 1993.OCT"			; Release date
	;else
	;	dc.b	"SEGA MEGA DRIVE "			; Hardware ID
	;	dc.b	"(C)SEGA 1993.AUG"			; Release date
	;endif
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	dc.b	"SONIC THE HEDGEHOG-CD                           "
	;if REGION=JAPAN					; Game version
	;	dc.b	"GM G-6021  -00  "
	;elseif REGION=USA
		dc.b	"GM MK-4407 -00  "
	;else
	;	dc.b	"GM MK-4407-00   "
	;endif
	dc.b	"J               "				; I/O support
	dc.b	"                "				; Space
	dc.b	"                "
	dc.b	"                "
	dc.b	"                "
	dc.b	"                "
	;if REGION=JAPAN					; Region
	;	dc.b	"J               "
	;elseif REGION=USA
		dc.b	"U               "
	;else
	;	dc.b	"E               "
	;endif

; ------------------------------------------------------------------------------
; Version number	
; ------------------------------------------------------------------------------

	section disc_version

	;if REGION=JAPAN
	;	dc.w	$0106
	;else
		dc.w	$0109
	;endif

; ------------------------------------------------------------------------------