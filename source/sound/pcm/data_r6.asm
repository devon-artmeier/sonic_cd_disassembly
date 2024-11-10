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
	dc.b	"SNCBNK30.S28    "

; ------------------------------------------------------------------------------
; Songs
; ------------------------------------------------------------------------------

	song PCM_SONG_PAST, PastSong, $80

; ------------------------------------------------------------------------------

	section data_songs
PastSong:
	include	"songs/past_r6.asm"
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
	sfx PCM_SFX_SHATTER,    ShatterSfx,   $70

; ------------------------------------------------------------------------------

	section data_sfx
UnknownSfx:
	include	"sfx/unknown_r6.asm"
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
	include	"sfx/stomp.asm"
	even
BumperSfx:
	include	"sfx/blank_1.asm"
	even
ShatterSfx:
	include	"sfx/shatter.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample Pad,         $420E, 0, 0, 0
	sample Kick,        $0A70, 0, 0, 0
	sample Tamborine,   $0C4C, 0, 0, 0
	sample Beep,        $11F0, 0, 0, 0
	sample Honk,        $33F8, 0, 0, 0
	sample SynthBass,   $1462, 0, 0, 0
	sample HatClosed,   $0878, 0, 0, 0
	sample Snare,       $07B5, 0, 0, 0
	sample Clap,        $096E, 0, 0, 0
	sample HatOpen,     $149E, 0, 0, 0
	sample Flute,       $37CE, 0, 0, 0
	sample Piano,       $1C88, 0, 0, 0
	sample SynthBell,   $2890, 0, 0, 0
	sample Tom,         $106E, 0, 0, 0
	sample CrashCymbal, $3AB0, 0, 0, 0
	sample Synth,       $1D75, 0, 0, 0
	sample Future,      $0000, 0, 0, 0
	sample Past,        $0000, 0, 0, 0
	sample Alright,     $0000, 0, 0, 0
	sample OuttaHere,   $0000, 0, 0, 0
	sample Yes,         $0000, 0, 0, 0
	sample Yeah,        $0000, 0, 0, 0
	sample Stomp,       $0000, 0, 0, 0
	sample Shatter,     $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data Pad,         "samples/r6_pad.pcm"
	sample_data Kick,        "samples/r6_kick.pcm"
	sample_data Tamborine,   "samples/r6_tamborine.pcm"
	sample_data Beep,        "samples/r6_beep.pcm"
	sample_data Honk,        "samples/r6_honk.pcm"
	sample_data SynthBass,   "samples/r6_synth_bass.pcm"
	sample_data HatClosed,   "samples/r6_hi_hat_closed.pcm"
	sample_data Snare,       "samples/r6_snare.pcm"
	sample_data Clap,        "samples/r6_clap.pcm"
	sample_data HatOpen,     "samples/r6_hi_hat_open.pcm"
	sample_data Flute,       "samples/r6_flute.pcm"
	sample_data Piano,       "samples/r6_piano.pcm"
	sample_data SynthBell,   "samples/r6_synth_bell.pcm"
	sample_data Tom,         "samples/r6_tom.pcm"
	sample_data CrashCymbal, "samples/r6_crash_cymbal.pcm"
	sample_data Synth,       "samples/r6_synth.pcm"
	sample_data Future,      "samples/sfx_future.pcm"
	sample_data Past,        "samples/sfx_past.pcm"
	sample_data Alright,     "samples/sfx_alright.pcm"
	sample_data OuttaHere,   "samples/sfx_outta_here.pcm"
	sample_data Yes,         "samples/sfx_yes.pcm"
	sample_data Yeah,        "samples/sfx_yeah.pcm"
	sample_data Stomp,       "samples/sfx_stomp.pcm"
	sample_data Shatter,     "samples/sfx_shatter.pcm"
	
; ------------------------------------------------------------------------------
