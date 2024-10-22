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
	incbin	"data/message_english_art.nem"
	even

	xdef DataCorruptTilemap
DataCorruptTilemap:
	incbin	"data/data_corrupt_english_tilemap.eni"
	even

	xdef UnformattedTilemap
UnformattedTilemap:
	incbin	"data/unformatted_english_tilemap.eni"
	even

	xdef CartUnformattedTilemap
CartUnformattedTilemap:
	incbin	"data/cart_unformatted_english_tilemap.eni"
	even

	xdef BuramFullTilemap
BuramFullTilemap:
	incbin	"data/ram_full_english_tilemap.eni"
	even
	
	xdef MessageUsaArt
MessageUsaArt:
	incbin	"data/message_usa_art.nem"
	even

	xdef UnformattedUsaTilemap
UnformattedUsaTilemap:
	incbin	"data/unformatted_usa_tilemap.eni"
	even

; ------------------------------------------------------------------------------
