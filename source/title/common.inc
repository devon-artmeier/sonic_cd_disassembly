; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

CLOUD_TRACE_TABLE	equ $1C800				; Trace table
CLOUD_IMAGE_BUFFER	equ $1D000				; Image buffer
CLOUD_STAMP_MAP		equ $20000				; Stamp map

CLOUD_WIDTH		equ 256					; Image buffer width
CLOUD_HEIGHT		equ 96					; Image buffer height
CLOUD_TILE_W		equ CLOUD_WIDTH/8			; Image buffer width in tiles
CLOUD_TILE_H		equ CLOUD_HEIGHT/8			; Image buffer height in tiles

CLOUD_IMAGE_SIZE	equ CLOUD_TILE_W*CLOUD_TILE_H*$20	; Image buffer length in bytes

; ------------------------------------------------------------------------------
