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
	
	xdef PCM_SFX_BREAK
PCM_SFX_BREAK		equ __sfx_id

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

	sample_ptr sDrumLoop,      DrumLoopSampleInfo
	sample_ptr sBass,          BassSampleInfo
	sample_ptr sFlute,         FluteSampleInfo
	sample_ptr sPiano,         PianoSampleInfo
	sample_ptr sTomDrum,       TomDrumSampleInfo
	sample_ptr sElecPianoLow,  ElecPianoLowSampleInfo
	sample_ptr sElecPianoHigh, ElecPianoHighSampleInfo
	sample_ptr sStrings,       StringsSampleInfo
	sample_ptr sFuture,        FutureSampleInfo
	sample_ptr sPast,          PastSampleInfo
	sample_ptr sStomp,         StompSampleInfo
	sample_ptr sAmyGiggle,     AmyGiggleSampleInfo
	sample_ptr sAmyYelp,       AmyYelpSampleInfo
	sample_ptr sAlright,       AlrightSampleInfo
	sample_ptr sOuttaHere,     OuttaHereSampleInfo
	sample_ptr sYes,           YesSampleInfo
	sample_ptr sYeah,          YeahSampleInfo
	sample_ptr_end

; ------------------------------------------------------------------------------

	section data_samples
DrumLoopSampleInfo:
	sample DrumLoopSample, $0000, 0, 0, 0
	
BassSampleInfo:
	sample BassSample, $0000, 0, 0, 0
	
FluteSampleInfo:
	sample FluteSample, $0FA3, 0, 0, 0

PianoSampleInfo:
	sample PianoSample, $22CD, 0, 0, 0
	
TomDrumSampleInfo:
	sample TomDrumSample, $0000, 0, 0, 0
	
ElecPianoLowSampleInfo:
	sample ElecPianoLowSample, $2EE9, 0, 0, 0
	
ElecPianoHighSampleInfo:
	sample ElecPianoHighSample, $3240, 0, 0, 0
	
StringsSampleInfo:
	sample StringsSample, $06CC, 0, 0, 0
	
FutureSampleInfo:
	sample FutureSample, $0000, 0, 0, 0
	
PastSampleInfo:
	sample PastSample, $0000, 0, 0, 0

StompSampleInfo:
	sample StompSample, $0000, 0, 0, 0
	
AmyGiggleSampleInfo:
	sample AmyGiggleSample, $0000, 0, 0, 0
	
AmyYelpSampleInfo:
	sample AmyYelpSample, $0000, 0, 0, 0
	
AlrightSampleInfo:
	sample AlrightSample, $0000, 0, 0, 0
	
OuttaHereSampleInfo:
	sample OuttaHereSample, $0000, 0, 0, 0
	
YesSampleInfo:
	sample YesSample, $0000, 0, 0, 0
	
YeahSampleInfo:
	sample YeahSample, $0000, 0, 0, 0

; ------------------------------------------------------------------------------

	sample_data DrumLoopSample,      "samples/r1_drum_loop.pcm"
	even
	sample_data BassSample,          "samples/r1_bass.pcm"
	even
	sample_data FluteSample,         "samples/r1_flute.pcm"
	even
	sample_data PianoSample,         "samples/r1_piano.pcm"
	even
	sample_data TomDrumSample,       "samples/r1_tom_drum.pcm"
	even
	sample_data ElecPianoLowSample,  "samples/r1_elec_piano_low.pcm"
	even
	sample_data ElecPianoHighSample, "samples/r1_elec_piano_high.pcm"
	even
	sample_data StringsSample,       "samples/r1_strings.pcm"
	even
	sample_data FutureSample,        "samples/sfx_future.pcm"
	sample_data PastSample,	         "samples/sfx_past.pcm"
	sample_data StompSample,         "samples/sfx_stomp.pcm"
	sample_data AmyGiggleSample,     "samples/sfx_amy_giggle.pcm"
	sample_data AmyYelpSample,       "samples/sfx_amy_yelp.pcm"
	sample_data AlrightSample,       "samples/sfx_alright.pcm"
	sample_data OuttaHereSample,     "samples/sfx_outta_here.pcm"
	sample_data YesSample,	         "samples/sfx_yes.pcm"
	sample_data YeahSample,	         "samples/sfx_yeah.pcm"

; ------------------------------------------------------------------------------
