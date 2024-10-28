; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"variables.inc"
	include	"macros.inc"
	include	"smps2asm.inc"
	include	"data_labels.inc"

; ------------------------------------------------------------------------------
; Signature
; ------------------------------------------------------------------------------

	section signature
	dc.b	"SNCBNK25.S28    "

; ------------------------------------------------------------------------------
; Songs
; ------------------------------------------------------------------------------

	song PCM_SONG_PAST, PastSong, $80
	
	; Unknown
	section data_song_priorities
	dc.b	$80
	dc.b	$80

; ------------------------------------------------------------------------------

	section data_songs
PastSong:
	include	"songs/past_r1.asm"
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
	include	"sfx/unknown_r1.asm"
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
	include	"sfx/amy_giggle.asm"
	even
AmyYelpSfx:
	include	"sfx/amy_yelp.asm"
	even
StompSfx:
	include	"sfx/stomp.asm"
	even
BumperSfx:
	include	"sfx/blank_1.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample DrumLoop,      $0000, 0, 0, 0
	sample Bass,          $0000, 0, 0, 0
	sample Flute,         $0FA3, 0, 0, 0
	sample Piano,         $22CD, 0, 0, 0
	sample TomDrum,       $0000, 0, 0, 0
	sample ElecPianoLow,  $2EE9, 0, 0, 0
	sample ElecPianoHigh, $3240, 0, 0, 0
	sample Strings,       $06CC, 0, 0, 0
	sample Future,        $0000, 0, 0, 0
	sample Past,          $0000, 0, 0, 0
	sample Stomp,         $0000, 0, 0, 0
	sample AmyGiggle,     $0000, 0, 0, 0
	sample AmyYelp,       $0000, 0, 0, 0
	sample Alright,       $0000, 0, 0, 0
	sample OuttaHere,     $0000, 0, 0, 0
	sample Yes,           $0000, 0, 0, 0
	sample Yeah,          $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data DrumLoop,      "samples/r1_drum_loop.pcm"
	even
	sample_data Bass,          "samples/r1_bass.pcm"
	even
	sample_data Flute,         "samples/r1_flute.pcm"
	even
	sample_data Piano,         "samples/r1_piano.pcm"
	even
	sample_data TomDrum,       "samples/r1_tom_drum.pcm"
	even
	sample_data ElecPianoLow,  "samples/r1_elec_piano_low.pcm"
	even
	sample_data ElecPianoHigh, "samples/r1_elec_piano_high.pcm"
	even
	sample_data Strings,       "samples/r1_strings.pcm"
	even
	sample_data Future,        "samples/sfx_future.pcm"
	sample_data Past,          "samples/sfx_past.pcm"
	sample_data Stomp,         "samples/sfx_stomp.pcm"
	sample_data AmyGiggle,     "samples/sfx_amy_giggle.pcm"
	sample_data AmyYelp,       "samples/sfx_amy_yelp.pcm"
	sample_data Alright,       "samples/sfx_alright.pcm"
	sample_data OuttaHere,     "samples/sfx_outta_here.pcm"
	sample_data Yes,           "samples/sfx_yes.pcm"
	sample_data Yeah,          "samples/sfx_yeah.pcm"

; ------------------------------------------------------------------------------
