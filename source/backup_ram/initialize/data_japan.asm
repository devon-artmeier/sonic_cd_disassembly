; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"variables.inc"

	section data

; ------------------------------------------------------------------------------

	xdef EggmanArt
EggmanArt:
	incbin	"data/eggman_art.nem"
	even

	xdef EggmanTilemap
EggmanTilemap:
	incbin	"data/eggman_tilemap.eni"
	even
	
	xdef MessageArt
MessageArt:
	incbin	"data/message_japan_art.nem"
	even

	xdef DataCorruptTilemap
DataCorruptTilemap:
	incbin	"data/data_corrupt_japan_tilemap.eni"
	even
	
	xdef Unformatted
Unformatted:
	incbin	"data/unformatted_japan_tilemap.eni"
	even

	xdef CartUnformattedTilemap
CartUnformattedTilemap:
	incbin	"data/cart_unformatted_japan_tilemap.eni"
	even

	xdef BuramFullTilemap
BuramFullTilemap:
	incbin	"data/ram_full_japan_tilemap.eni"
	even

; ------------------------------------------------------------------------------
