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
	dc.b	"SNCBNK27.S28    "

; ------------------------------------------------------------------------------
; Songs
; ------------------------------------------------------------------------------

	song PCM_SONG_PAST, PastSong, $80

; ------------------------------------------------------------------------------

	section data_songs
UnknownIndex:
	dc.l	.0-UnknownIndex
	dc.l	.1-UnknownIndex
	
.0:
	dc.b	0, 4, 3, $80, $FF, $7F
	
.1:
	dc.b	1, $A, 3, $80, $FF, $7F

PastSong:
	include	"songs/past_r3.asm"
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
	include	"sfx/unknown_r3.asm"
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
	include	"sfx/bumper.asm"
	even
ShatterSfx:
	include	"sfx/shatter.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample Synth1,        $1A63, 0, 0, 0
	sample SynthFlute,    $25C8, 0, 0, 0
	sample Snare1,        $2685, 0, 0, 0
	sample Kick,          $0950, 0, 0, 0
	sample SynthHit,      $3AA8, 0, 0, 0
	sample Snare2,        $08A0, 0, 0, 0
	sample HiHat1,        $0D88, 0, 0, 0
	sample Scratch,       $1528, 0, 0, 0
	sample Rattle,        $4982, 0, 0, 0
	sample Synth2,        $0A97, 0, 0, 0
	sample SynthBass,     $19E8, 0, 0, 0
	sample HiHat2,        $063B, 0, 0, 0
	sample Strings,       $1480, 0, 0, 0
	sample SynthPiano,    $1460, 0, 0, 0
	sample Timpani,       $1D18, 0, 0, 0
	sample Squeak,        $1136, 0, 0, 0
	sample JamesBrownHit, $1880, 0, 0, 0
	sample SynthKick,     $0798, 0, 0, 0
	sample Blip,          $045B, 0, 0, 0
	sample Future,        $0000, 0, 0, 0
	sample Past,          $0000, 0, 0, 0
	sample Bumper,        $0000, 0, 0, 0
	sample Stomp,         $0000, 0, 0, 0
	sample AmyGiggle,     $0000, 0, 0, 0
	sample AmyYelp,       $0000, 0, 0, 0
	sample Alright,       $0000, 0, 0, 0
	sample OuttaHere,     $0000, 0, 0, 0
	sample Yes,           $0000, 0, 0, 0
	sample Yeah,          $0000, 0, 0, 0
	sample Shatter,       $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data Synth1,        "samples/r3_synth_1.pcm"
	even
	sample_data SynthFlute,    "samples/r3_synth_flute.pcm"
	even
	sample_data Snare1,        "samples/r3_snare_1.pcm"
	even
	sample_data Kick,          "samples/r3_kick.pcm"
	even
	sample_data SynthHit,      "samples/r3_synth_hit.pcm"
	even
	sample_data Snare2,        "samples/r3_snare_2.pcm"
	even
	sample_data HiHat1,        "samples/r3_hi_hat_1.pcm"
	even
	sample_data Scratch,       "samples/r3_scratch.pcm"
	even
	sample_data Rattle,        "samples/r3_rattle.pcm"
	even
	sample_data Synth2,        "samples/r3_synth_2.pcm"
	even
	sample_data SynthBass,     "samples/r3_synth_bass.pcm"
	even
	sample_data HiHat2,        "samples/r3_hi_hat_2.pcm"
	even
	sample_data Strings,       "samples/r3_strings.pcm"
	even
	sample_data SynthPiano,    "samples/r3_synth_piano.pcm"
	even
	sample_data Timpani,       "samples/r3_timpani.pcm"
	even
	sample_data Squeak,        "samples/r3_squeak.pcm"
	even
	sample_data JamesBrownHit, "samples/r3_james_brown_hit.pcm"
	even
	sample_data SynthKick,     "samples/r3_synth_kick.pcm"
	even
	sample_data Blip,          "samples/r3_blip.pcm"
	even
	sample_data Future,        "samples/sfx_future.pcm"
	sample_data Past,          "samples/sfx_past.pcm"
	sample_data Bumper,        "samples/sfx_bumper.pcm"
	sample_data Stomp,         "samples/sfx_stomp.pcm"
	sample_data AmyGiggle,     "samples/sfx_amy_giggle.pcm"
	sample_data AmyYelp,       "samples/sfx_amy_yelp.pcm"
	sample_data Alright,       "samples/sfx_alright.pcm"
	sample_data OuttaHere,     "samples/sfx_outta_here.pcm"
	sample_data Yes,           "samples/sfx_yes.pcm"
	sample_data Yeah,          "samples/sfx_yeah.pcm"
	sample_data Shatter,       "samples/sfx_shatter.pcm"
	
; ------------------------------------------------------------------------------
