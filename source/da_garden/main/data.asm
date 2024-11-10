; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section data

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------

	include	"palette_data.asm"

	xdef FlickySprites, FlickySlowSprites, FlickyCatchUpSprites, FlickyGlideSprites
	include	"../data/flicky_sprites.asm"
	even

	xdef StarSprites	
StarSprites:
	include	"../data/star_sprites.asm"
	even

	xdef UfoSprites, UfoDownSprites, UfoUpSprites
	include	"../data/ufo_sprites.asm"
	even

	xdef EggmanSprites	
EggmanSprites:
	include	"../data/eggman_sprites.asm"
	even

	xdef EggmanTurnSprites	
EggmanTurnSprites:
	include	"../data/eggman_turn_sprites.asm"
	even

	xdef MetalSonicSprites, MetalSonicBackUpSprites
	include	"../data/metal_sonic_sprites.asm"
	even

	xdef TailsSprites	
TailsSprites:
	include	"../data/tails_sprites.asm"
	even

	xdef TailsDownSprites	
TailsDownSprites:
	include	"../data/tails_down_sprites.asm"
	even
	
	xdef TailsUpSprites
TailsUpSprites:
	include	"../data/tails_up_sprites.asm"
	even

	include	"track_info.asm"

	xdef TrackTitleSprites
TrackTitleSprites:
	include	"../data/track_sprites.asm"
	
	include	"volcano_data.asm"
	
	xdef BackgroundArt
BackgroundArt:
	incbin	"../data/background_art.nem"
	even
	
	xdef BackgroundTilemap
BackgroundTilemap:
	incbin	"../data/background_tilemap.kos"
	even

	xdef FlickyArt	
FlickyArt:
	incbin	"../data/flicky_art.nem"
	even
	
	xdef StarArt
StarArt:
	incbin	"../data/star_art.nem"
	even

	xdef EggmanArt	
EggmanArt:
	incbin	"../data/eggman_art.nem"
	even

	xdef UfoArt	
UfoArt:
	incbin	"../data/ufo_art.nem"
	even

	xdef MetalSonicArt	
MetalSonicArt:
	incbin	"../data/metal_sonic_art.nem"
	even

	xdef TailsArt	
TailsArt:
	incbin	"../data/tails_art.nem"
	even

; ------------------------------------------------------------------------------
