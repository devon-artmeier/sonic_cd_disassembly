; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

PLANET_TRACE_TABLE	equ $19A00				; Trace table
PLANET_IMAGE_BUFFER	equ $1D000				; Image buffer
PLANET_STAMP_MAP	equ $20000				; Stamp map

PLANET_WIDTH		equ 256					; Image buffer width
PLANET_HEIGHT		equ 96					; Image buffer height
PLANET_TILE_W		equ PLANET_WIDTH/8			; Image buffer width in tiles
PLANET_TILE_H		equ PLANET_HEIGHT/8			; Image buffer height in tiles

PLANET_IMAGE_SIZE	equ PLANET_TILE_W*PLANET_TILE_H*$20	; Image buffer length in bytes

; ------------------------------------------------------------------------------
