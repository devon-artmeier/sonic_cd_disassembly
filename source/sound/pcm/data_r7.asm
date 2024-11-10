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
	dc.b	"SNCBNK31.S28    "

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
	include	"songs/past_r7.asm"
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
	include	"sfx/unknown_r7.asm"
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
	include	"sfx/blank_2.asm"
	even
BumperSfx:
	include	"sfx/blank_2.asm"
	even

; ------------------------------------------------------------------------------
; Samples
; ------------------------------------------------------------------------------

	sample Kick,        $0CA9, 0, 0, 0
	sample Snare,       $08D8, 0, 0, 0
	sample HatOpen,     $0ED0, 0, 0, 0
	sample HatClosed,   $05F3, 0, 0, 0
	sample Bass,        $1815, 0, 0, 0
	sample PianoChord1, $0000, 0, 0, 0
	sample PianoChord2, $0000, 0, 0, 0
	sample Tom,         $0FDC, 0, 0, 0
	sample HueHueHue,   $0000, 0, 0, 0
	sample Saxophone,   $0000, 0, 0, 0
	sample VoxClav,     $0000, 0, 0, 0
	sample Scratch1,    $09BB, 0, 0, 0
	sample Scratch2,    $0000, 0, 0, 0
	sample Piano,       $33E0, 0, 0, 0
	sample PadChord1,   $0000, 0, 0, 0
	sample PadChord2,   $3F80, 0, 0, 0
	sample Organ1,      $0950, 0, 0, 0
	sample Organ2,      $09D0, 0, 0, 0
	sample Future,      $0000, 0, 0, 0
	sample Past,        $0000, 0, 0, 0
	sample Alright,     $0000, 0, 0, 0
	sample OuttaHere,   $0000, 0, 0, 0
	sample Yes,         $0000, 0, 0, 0
	sample Yeah,        $0000, 0, 0, 0
	sample AmyGiggle,   $0000, 0, 0, 0
	sample AmyYelp,     $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data Kick,        "samples/r7_kick.pcm"
	sample_data Snare,       "samples/r7_snare.pcm"
	sample_data HatOpen,     "samples/r7_hi_hat_open.pcm"
	sample_data HatClosed,   "samples/r7_hi_hat_closed.pcm"
	sample_data Bass,        "samples/r7_bass.pcm"
	sample_data PianoChord1, "samples/r7_piano_chord_1.pcm"
	sample_data PianoChord2, "samples/r7_piano_chord_2.pcm"
	sample_data Tom,         "samples/r7_tom.pcm"
	sample_data HueHueHue,   "samples/r7_hue.pcm"
	sample_data Saxophone,   "samples/r7_saxophone.pcm"
	sample_data VoxClav,     "samples/r7_vox_clav.pcm"
	sample_data Scratch1,    "samples/r7_scratch_1.pcm"
	sample_data Scratch2,    "samples/r7_scratch_2.pcm"
	sample_data Piano,       "samples/r7_piano.pcm"
	sample_data PadChord1,   "samples/r7_pad_chord_1.pcm"
	sample_data PadChord2,   "samples/r7_pad_chord_2.pcm"
	sample_data Organ1,      "samples/r7_organ_1.pcm"
	sample_data Organ2,      "samples/r7_organ_2.pcm"
	sample_data Future,      "samples/sfx_future.pcm"
	sample_data Past,        "samples/sfx_past.pcm"
	sample_data Alright,     "samples/sfx_alright.pcm"
	sample_data OuttaHere,   "samples/sfx_outta_here.pcm"
	sample_data Yes,         "samples/sfx_yes.pcm"
	sample_data Yeah,        "samples/sfx_yeah.pcm"
	sample_data AmyGiggle,   "samples/sfx_amy_giggle.pcm"
	sample_data AmyYelp,     "samples/sfx_amy_yelp.pcm"
	
; ------------------------------------------------------------------------------
