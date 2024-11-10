; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"regions.inc"
	include	"variables.inc"
	include	"macros.inc"
	include	"smps2asm.inc"
	include	"data_labels.inc"

; ------------------------------------------------------------------------------
; Signature
; ------------------------------------------------------------------------------

	section signature
	dc.b	"SNCBNK36.S28    "

; ------------------------------------------------------------------------------
; Songs
; ------------------------------------------------------------------------------

	song PCM_SONG_PAST, LoopSong, $80

; ------------------------------------------------------------------------------

	section data_songs
LoopSong:
	include	"songs/loop_final.asm"
	even
	
; ------------------------------------------------------------------------------
; Sound effects
; ------------------------------------------------------------------------------

	sfx PCM_SFX_UNKOWN,     UnknownSfx,   $70
	sfx PCM_SFX_FUTURE,     FutureSfx,    $70
	sfx PCM_SFX_PAST,       PastSfx,      $70
	sfx PCM_SFX_ALRIGHT,    AlrightSfx,   $70
	sfx PCM_SFX_OUTTA_HERE, OuttaHereSfx, $70
	sfx PCM_SFX_YES,        YesSfx,       $70
	sfx PCM_SFX_YEAH,       YeahSfx,      $70
	sfx PCM_SFX_AMY_GIGGLE, AmyGiggleSfx, $70
	sfx PCM_SFX_AMY_YELP,   AmyYelpSfx,   $70
	sfx PCM_SFX_STOMP,      StompSfx,     $70
	sfx PCM_SFX_BUMPER,     BumperSfx,    $70

; ------------------------------------------------------------------------------

	section data_sfx
UnknownSfx:
	include	"sfx/unknown_final.asm"
	even
FutureSfx:
	include	"sfx/future.asm"
	even
PastSfx:
	include	"sfx/past.asm"
	even
AlrightSfx:
	include	"sfx/alright.asm"
	even
OuttaHereSfx:
	include	"sfx/outta_here.asm"
	even
YesSfx:
	include	"sfx/yes.asm"
	even
YeahSfx:
	include	"sfx/yeah.asm"
	even
AmyGiggleSfx:
	include	"sfx/blank_1.asm"
	even
AmyYelpSfx:
	include	"sfx/blank_2.asm"
	even
StompSfx:
	include	"sfx/stomp_boss.asm"
	even
BumperSfx:
	include	"sfx/blank_1.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample LoopRight, $0000, 0, 0, 0
	sample LoopLeft,  $0000, 0, 0, 0
	sample Future,    $0000, 0, 0, 0
	sample Past,      $0000, 0, 0, 0
	sample Alright,   $0000, 0, 0, 0
	sample OuttaHere, $0000, 0, 0, 0
	sample Yes,       $0000, 0, 0, 0
	sample Yeah,      $0000, 0, 0, 0
	sample Stomp,     $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data LoopRight, "samples/final_loop_right.pcm"
	sample_data LoopLeft,  "samples/final_loop_left.pcm"
	sample_data Future,    "samples/sfx_future.pcm"
	sample_data Past,      "samples/sfx_past.pcm"
	sample_data Alright,   "samples/sfx_alright.pcm"
	sample_data OuttaHere, "samples/sfx_outta_here.pcm"
	sample_data Yes,       "samples/sfx_yes.pcm"
	sample_data Yeah,      "samples/sfx_yeah.pcm"
	sample_data Stomp,     "samples/sfx_stomp.pcm"
	
; ------------------------------------------------------------------------------
