; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; VDP register data
; ------------------------------------------------------------------------------

	xdef VdpRegisters
VdpRegisters:
	dc.b	%00000100					; No H-BLANK interrupt
	dc.b	%00110100					; V-BLANK interrupt, DMA, mode 5
	dc.b	$C000/$400					; Plane A location
	dc.b	0						; Window location
	dc.b	$C000/$2000					; Plane B location
	dc.b	$E000/$200					; Sprite table location
	dc.b	0						; Reserved
	dc.b	0						; Background color line 0 color 0
	dc.b	0						; Reserved
	dc.b	0						; Reserved
	dc.b	0						; H-BLANK interrupt counter 0
	dc.b	%00000000					; Scroll by screen
	dc.b	%10000001					; H40
	dc.b	$E400/$400					; Horizontal scroll table lcation
	dc.b	0						; Reserved
	dc.b	2						; Auto increment by 2
	dc.b	%00000001					; 64x32 tile plane size
	dc.b	0						; Window horizontal position 0
	dc.b	0						; Window vertical position 0
	even

; ------------------------------------------------------------------------------
; FM SFX Sound driver
; ------------------------------------------------------------------------------

	xdef FmDriver
FmDriver:
	incbin	"../../../build/z80.bin"
FmDriverEnd:
	even

	xdef FM_DRIVER_SIZE
FM_DRIVER_SIZE		equ FmDriverEnd-FmDriver

; ------------------------------------------------------------------------------
; Saved status register
; ------------------------------------------------------------------------------

	xdef saved_sr
saved_sr:
	dc.w	0

; ------------------------------------------------------------------------------
