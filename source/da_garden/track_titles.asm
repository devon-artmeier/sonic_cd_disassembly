; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"regions.inc"
	
	section data

; -------------------------------------------------------------------------
; Track titles art
; -------------------------------------------------------------------------

	xdef DaGardenTrackTitles
DaGardenTrackTitles:

	xdef BossTrackArt
BossTrackArt:
	incbin	"data/track_boss_art.nem"
	even

	xdef Round3ATrackArt
Round3ATrackArt:
	incbin	"data/track_r3a_art.nem"
	even

	xdef Round3DTrackArt
Round3DTrackArt:
	incbin	"data/track_r3d_art.nem"
	even

	xdef Round3CTrackArt
Round3CTrackArt:
	incbin	"data/track_r3c_art.nem"
	even

	xdef FinalTrackArt
FinalTrackArt:
	incbin	"data/track_final_art.nem"
	even

	xdef GameOverTrackArt
GameOverTrackArt:
	incbin	"data/track_game_over_art.nem"
	even

	xdef InvincibleTrackArt
InvincibleTrackArt:
	incbin	"data/track_invincible_art.nem"
	even

	xdef DaGardenTrackArt
DaGardenTrackArt:
	incbin	"data/track_da_garden_art.nem"
	even

	xdef Round8ATrackArt
Round8ATrackArt:
	incbin	"data/track_r8a_art.nem"
	even

	xdef Round8DTrackArt
Round8DTrackArt:
	incbin	"data/track_r8d_art.nem"
	even

	xdef Round8CTrackArt
Round8CTrackArt:
	incbin	"data/track_r8c_art.nem"
	even

	xdef Round1ATrackArt
Round1ATrackArt:
	incbin	"data/track_r1a_art.nem"
	even

	xdef Round1DTrackArt
Round1DTrackArt:
	incbin	"data/track_r1d_art.nem"
	even

	xdef Round1CTrackArt
Round1CTrackArt:
	incbin	"data/track_r1c_art.nem"
	even

	xdef Round5ATrackArt
Round5ATrackArt:
	incbin	"data/track_r5a_art.nem"
	even

	xdef Round5DTrackArt
Round5DTrackArt:
	incbin	"data/track_r5d_art.nem"
	even

	xdef Round5CTrackArt
Round5CTrackArt:
	incbin	"data/track_r5c_art.nem"
	even

	xdef SpecialStageTrackArt
SpecialStageTrackArt:
	incbin	"data/track_special_stage_art.nem"
	even

	xdef SpeedShoesTrackArt
SpeedShoesTrackArt:
	incbin	"data/track_speed_shoes_art.nem"
	even

	xdef Round7ATrackArt
Round7ATrackArt:
	incbin	"data/track_r7a_art.nem"
	even

	xdef Round7DTrackArt
Round7DTrackArt:
	incbin	"data/track_r7d_art.nem"
	even

	xdef Round7CTrackArt
Round7CTrackArt:
	incbin	"data/track_r7c_art.nem"
	even

	xdef TitleTrackArt
TitleTrackArt:
	incbin	"data/track_title_art.nem"
	even
	
	; Unknown amalgamation of track names
	incbin	"data/track_unknown_art.nem"
	even
	
	xdef Round4ATrackArt
Round4ATrackArt:
	incbin	"data/track_r4a_art.nem"
	even

	xdef Round4DTrackArt
Round4DTrackArt:
	incbin	"data/track_r4d_art.nem"
	even

	xdef Round4CTrackArt
Round4CTrackArt:
	incbin	"data/track_r4c_art.nem"
	even

	xdef Round6ATrackArt
Round6ATrackArt:
	incbin	"data/track_r6a_art.nem"
	even

	xdef Round6DTrackArt
Round6DTrackArt:
	incbin	"data/track_r6d_art.nem"
	even

	xdef Round6CTrackArt
Round6CTrackArt:
	incbin	"data/track_r6c_art.nem"
	even

	xdef ResultsTrackArt
ResultsTrackArt:
	incbin	"data/track_results_art.nem"
	even

	xdef OpeningTrackArt, EndingTrackArt
	ifne REGION=USA
OpeningTrackArt:
		incbin	"data/track_opening_art_u.nem"
		even

EndingTrackArt:
		incbin	"data/track_ending_art_u.nem"
		even
	else
OpeningTrackArt:
		incbin	"data/track_opening_art_je.nem"
		even

EndingTrackArt:
		incbin	"data/track_ending_art_je.nem"
		even
	endif

; ------------------------------------------------------------------------------
