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
	dc.b	"SNCBNK32.S28    "

; ------------------------------------------------------------------------------
; Songs
; ------------------------------------------------------------------------------

	song PCM_SONG_PAST, PastSong, $80

; ------------------------------------------------------------------------------

	section data_songs
PastSong:
	include	"songs/past_r8.asm"
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
	include	"sfx/unknown_r8.asm"
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
	include	"sfx/bumper_r8.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample Fantasia,     $30DE, 0, 0, 0
	sample Kick1,        $0B00, 0, 0, 0
	sample Snare1,       $0000, 0, 0, 0
	sample Bass,         $0000, 0, 0, 0
	sample Snare2,       $0F3E, 0, 0, 0
	sample OrchHit1,     $2081, 0, 0, 0
	sample Synth,        $0EFE, 0, 0, 0
	sample Woosh,        $1AD8, 0, 0, 0
	sample PianoChord1,  $1C26, 0, 0, 0
	sample PianoChord2,  $1AC6, 0, 0, 0
	sample Piano,        $1748, 0, 0, 0
	sample OrchHitCrash, $29B4, 0, 0, 0
	sample Pad,          $1FC5, 0, 0, 0
	sample OrchHit2,     $291E, 0, 0, 0
	sample Snare3,       $08D1, 0, 0, 0
	sample Kick2,        $1E17, 0, 0, 0
	sample Future,       $0000, 0, 0, 0
	sample Past,         $0000, 0, 0, 0
	sample Alright,      $0000, 0, 0, 0
	sample OuttaHere,    $0000, 0, 0, 0
	sample Yes,          $0000, 0, 0, 0
	sample Yeah,         $0000, 0, 0, 0
	sample Stomp,        $0000, 0, 0, 0
	sample Bumper,       $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data Fantasia,     "samples/r8_fantasia.pcm"
	sample_data Kick1,        "samples/r8_kick_1.pcm"
	sample_data Snare1,       "samples/r8_snare_1.pcm"
	sample_data Bass,         "samples/r8_bass.pcm"
	sample_data Snare2,       "samples/r8_snare_2.pcm"
	sample_data OrchHit1,     "samples/r8_orchestra_hit_1.pcm"
	sample_data Synth,        "samples/r8_synth.pcm"
	sample_data Woosh,        "samples/r8_woosh.pcm"
	sample_data PianoChord1,  "samples/r8_piano_chord_1.pcm"
	sample_data PianoChord2,  "samples/r8_piano_chord_2.pcm"
	sample_data Piano,        "samples/r8_piano.pcm"
	sample_data OrchHitCrash, "samples/r8_orchestra_hit_crash.pcm"
	sample_data Pad,          "samples/r8_pad.pcm"
	sample_data OrchHit2,     "samples/r8_orchestra_hit_2.pcm"
	sample_data Snare3,       "samples/r8_snare_3.pcm"
	sample_data Kick2,        "samples/r8_kick_2.pcm"
	sample_data Future,       "samples/sfx_future.pcm"
	sample_data Past,         "samples/sfx_past.pcm"
	sample_data Alright,      "samples/sfx_alright.pcm"
	sample_data OuttaHere,    "samples/sfx_outta_here.pcm"
	sample_data Yes,          "samples/sfx_yes.pcm"
	sample_data Yeah,         "samples/sfx_yeah.pcm"
	sample_data Stomp,        "samples/sfx_stomp.pcm"
	sample_data Bumper,       "samples/sfx_bumper.pcm"
	
; ------------------------------------------------------------------------------
