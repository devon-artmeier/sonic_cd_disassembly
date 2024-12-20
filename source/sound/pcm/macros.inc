; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Define song
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Song label
;	\3 - Priority
; ------------------------------------------------------------------------------

__song_id	set PCM_SONG_START
song macro
	xdef \1
	section data_song_index
	dc.l	\2
	section data_song_priorities
	dc.b	\3
	\1:		equ __song_id
	__song_id:	set __song_id+1
	endm
	
; ------------------------------------------------------------------------------
; Define sound effect
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Sound effect label
;	\3 - Priority
; ------------------------------------------------------------------------------

__sfx_id	set PCM_SFX_START
sfx macro
	xdef \1
	section data_sfx_index
	dc.l	\2
	section data_sfx_priorities
	dc.b	\3
	\1:		equ __sfx_id
	__sfx_id:	set __sfx_id+1
	endm
	
; ------------------------------------------------------------------------------
; Define command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command label
;	\3 - Priority
; ------------------------------------------------------------------------------

__cmd_id	set PCM_CMD_START
command macro
	xdef \1
	section data_cmd_priorities
	dc.b	\3
	section code
	jmp	\2(pc)
	\1:		equ __cmd_id
	__cmd_id:	set __cmd_id+1
	endm
	
; ------------------------------------------------------------------------------
; Define sample
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Sample name
;	\2 - Loop point
;	\3 - Staccato time
;	\4 - Sample mode (0 = stream, else static)
;	\5 - Destination address (only if static)
; ------------------------------------------------------------------------------

__sample_id	set 0
sample macro
	xdef s\1
	section data_sample_index
	dc.l	\1Info
	section data_samples
\1Info:
	dc.l	\1Sample, (\1SampleEnd)-(\1Sample), \2
	dc.b	\3, \4
	dc.w	\5
	s\1:		equ __sample_id
	__sample_id:	set __sample_id+1
	endm

; ------------------------------------------------------------------------------
; End of sample index
; ------------------------------------------------------------------------------

samples_end macro
	SAMPLE_COUNT:	equ __sample_id
	endm
	
; ------------------------------------------------------------------------------
; Define sample data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Sample label
;	\2 - File path
; ------------------------------------------------------------------------------

sample_data macro
\1Sample:
	incbin	\2
\1SampleEnd:
	endm

; ------------------------------------------------------------------------------
