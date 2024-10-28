; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	section data

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------
	
	xdef WaterTilemap
WaterTilemap:
	incbin	"../data/water_tilemap.map"
	even

	xdef MountainsTilemap
MountainsTilemap:
	incbin	"../data/mountains_tilemap.map"
	even

	xdef EmblemTilemap
EmblemTilemap:
	incbin	"../data/emblem_tilemap.map"
	even

	xdef WaterArt
WaterArt:
	incbin	"../data/water_art.nem"
	even

	xdef MountainsArt
MountainsArt:
	incbin	"../data/mountain_art.nem"
	even

	xdef EmblemArt
EmblemArt:
	incbin	"../data/emblem_art.nem"
	even

	xdef BannerArt
BannerArt:
	incbin	"../data/banner_art.nem"
	even

	xdef PlanetArt
PlanetArt:
	incbin	"../data/planet_art.nem"
	even

	xdef SonicArt
SonicArt:
	incbin	"../data/sonic_art.nem"
	even

	xdef SolidColorArt
SolidColorArt:
	incbin	"../data/solid_color_art.nem"
	even

	xdef NewGameTextArt
NewGameTextArt:
	incbin	"../data/menu_new_game_art.nem"
	even

	xdef ContinueTextArt
ContinueTextArt:
	incbin	"../data/menu_continue_art.nem"
	even

	xdef TimeAttackTextArt
TimeAttackTextArt:
	incbin	"../data/menu_time_attack_art.nem"
	even

	xdef RamDataTextArt
RamDataTextArt:
	incbin	"../data/menu_ram_data_art.nem"
	even

	xdef DaGardenTextArt
DaGardenTextArt:
	incbin	"../data/menu_da_garden_art.nem"
	even

	xdef VisualModeTextArt
VisualModeTextArt:
	incbin	"../data/menu_visual_mode_art.nem"
	even

	xdef PressStartTextArt
PressStartTextArt:
	incbin	"../data/menu_press_start_art.nem"
	even

	xdef MenuArrowArt
MenuArrowArt:
	incbin	"../data/menu_arrow_art.nem"
	even

	xdef CopyrightArt
CopyrightArt:
	incbin	"../data/copyright_art_je.nem"
	even

	ifne REGION=USA
	xdef TmArt
TmArt:
		incbin	"../data/copyright_tm_art_u.nem"
		even

	xdef CopyrightTmArt
CopyrightTmArt:
		incbin	"../data/copyright_art_u.nem"
		even
	else
	xdef TmArt
TmArt:
		incbin	"copyright_tm_art_je.nem"
		even
	endif

; ------------------------------------------------------------------------------
