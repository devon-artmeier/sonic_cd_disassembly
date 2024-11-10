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
	dc.b	"SNCBNK29.S28    "

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
	include	"songs/past_r5.asm"
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
	include	"sfx/unknown_r5.asm"
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

	sample Kick,        $0000, 8, 0, 0
	sample Snare,       $0000, 8, 0, 0
	sample Cabasa,      $0000, 6, 0, 0
	sample Cowbell,     $0000, 9, 0, 0
	sample Bass,        $0000, 0, 0, 0
	sample LogDrum,     $22C8, 0, 0, 0
	sample PianoChord1, $0000, 0, 0, 0
	sample PianoChord2, $0000, 0, 0, 0
	sample PianoHigh,   $0000, 0, 0, 0
	sample PianoLow,    $0000, 0, 0, 0
	sample ToyPiano,    $2300, 0, 0, 0
	sample Choir,       $0000, 0, 0, 0
	sample Cymbal,      $2B00, 0, 0, 0
	sample Future,      $0000, 0, 0, 0
	sample Past,        $0000, 0, 0, 0
	sample Alright,     $0000, 0, 0, 0
	sample OuttaHere,   $0000, 0, 0, 0
	sample Yes,         $0000, 0, 0, 0
	sample Yeah,        $0000, 0, 0, 0
	samples_end

; ------------------------------------------------------------------------------

	section data_samples
	sample_data Kick,          "samples/r5_kick.pcm"
	sample_data Snare,         "samples/r5_snare.pcm"
	sample_data Cabasa,        "samples/r5_cabasa.pcm"
	sample_data Cowbell,       "samples/r5_cowbell.pcm"
	sample_data Bass,          "samples/r5_bass.pcm"
	sample_data LogDrum,       "samples/r5_log_drum.pcm"
	sample_data PianoChord1,   "samples/r5_piano_chord_1.pcm"
	sample_data PianoChord2,   "samples/r5_piano_chord_2.pcm"
	sample_data PianoHigh,     "samples/r5_piano_high.pcm"
	sample_data PianoLow,      "samples/r5_piano_low.pcm"
	sample_data ToyPiano,      "samples/r5_toy_piano.pcm"
	sample_data Choir,         "samples/r5_choir.pcm"
	sample_data Cymbal,        "samples/r5_cymbal.pcm"
	sample_data Future,        "samples/sfx_future.pcm"
	sample_data Past,          "samples/sfx_past.pcm"
	sample_data Alright,       "samples/sfx_alright.pcm"
	sample_data OuttaHere,     "samples/sfx_outta_here.pcm"
	sample_data Yes,           "samples/sfx_yes.pcm"
	sample_data Yeah,          "samples/sfx_yeah.pcm"
	
; ------------------------------------------------------------------------------
