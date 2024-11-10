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
	dc.b	"SNCBNK28.S28    "

; ------------------------------------------------------------------------------
; Songs
; ------------------------------------------------------------------------------

	song PCM_SONG_PAST, PastSong, $80

; ------------------------------------------------------------------------------

	section data_songs
PastSong:
	include	"songs/past_r4.asm"
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
	include	"sfx/unknown_r4.asm"
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
	include	"sfx/blank_2.asm"
	even
AmyYelpSfx:
	include	"sfx/blank_2.asm"
	even
StompSfx:
	include	"sfx/blank_2.asm"
	even
BumperSfx:
	include	"sfx/blank_2.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample Marimba,      $18FB, 0,   0, 0
	sample Piano1,       $3850, 0,   0, 0
	sample MarimbaChord, $3C78, $18, 0, 0
	sample Bass,         $25BD, $24, 0, 0
	sample BongoLow,     $1B74, $C,  0, 0
	sample BongoHigh,    $1849, $10, 0, 0
	sample SynthKick,    $0F25, $D,  0, 0
	sample Snare,        $4652, 0,   0, 0
	sample Shaker,       $15C6, $C,  0, 0
	sample Harp,         $2DC5, $1F, 0, 0
	sample Tamborine,    $0C4C, $F,  0, 0
	sample Piano2,       $27CA, $20, 0, 0
	sample Piano3,       $202C, $20, 0, 0
	sample Future,       $0000, 0,   0, 0
	sample Past,         $0000, 0,   0, 0
	sample Alright,      $0000, 0,   0, 0
	sample OuttaHere,    $0000, 0,   0, 0
	sample Yes,          $0000, 0,   0, 0
	sample Yeah,         $0000, 0,   0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data Marimba,      "samples/r4_marimba.pcm"
	sample_data Piano1,       "samples/r4_piano_1.pcm"
	sample_data MarimbaChord, "samples/r4_marimba_chord.pcm"
	sample_data Bass,         "samples/r4_bass.pcm"
	sample_data BongoLow,     "samples/r4_bongo_low.pcm"
	sample_data BongoHigh,    "samples/r4_bongo_high.pcm"
	sample_data SynthKick,    "samples/r4_synth_kick.pcm"
	sample_data Snare,        "samples/r4_snare.pcm"
	sample_data Shaker,       "samples/r4_shaker.pcm"
	sample_data Harp,         "samples/r4_harp.pcm"
	sample_data Tamborine,    "samples/r4_tamborine.pcm"
	sample_data Piano2,       "samples/r4_piano_2.pcm"
	sample_data Piano3,       "samples/r4_piano_3.pcm"
	sample_data Future,       "samples/sfx_future.pcm"
	sample_data Past,         "samples/sfx_past.pcm"
	sample_data Alright,      "samples/sfx_alright.pcm"
	sample_data OuttaHere,    "samples/sfx_outta_here.pcm"
	sample_data Yes,          "samples/sfx_yes.pcm"
	sample_data Yeah,         "samples/sfx_yeah.pcm"
	
; ------------------------------------------------------------------------------
