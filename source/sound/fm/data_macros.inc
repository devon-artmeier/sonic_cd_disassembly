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
; Define sample pointer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Sample metadata label
; ------------------------------------------------------------------------------

	xdef __sample_id
__sample_id	set 0
sample_ptr macro
	xdef \1
	section data_sample_index
	dc.l	\2
	\1:		equ __sample_id
	__sample_id:	set __sample_id+1
	endm

; ------------------------------------------------------------------------------
; End of sample table
; ------------------------------------------------------------------------------

sample_ptr_end macro
	SAMPLE_COUNT:	equ __sample_id
	endm

; ------------------------------------------------------------------------------
; Define sample info
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Sample label
;	\2 - Loop point
;	\3 - Staccato time
;	\4 - Sample mode (0 = stream, else static)
;	\5 - Destination address (only if static)
; ------------------------------------------------------------------------------

sample macro
	dc.l	\1, (\1End)-(\1), \2
	dc.b	\3, \4
	dc.w	\5
	endm
	
; ------------------------------------------------------------------------------
; Define sample data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Sample label
;	\2 - File path
; ------------------------------------------------------------------------------

sample_data macro
\1:
	incbin	\2
\1End:
	endm

; ------------------------------------------------------------------------------
; Labels
; ------------------------------------------------------------------------------

	xdef SfxIndex, SongPriorities, SfxPriorities, SongIndex
	xdef SampleIndex
	section data_sfx_index
SfxIndex:

	section data_song_priorities
SongPriorities:
	section data_song_priorities_end
	even

	section data_sfx_priorities
SfxPriorities:
	section data_sfx_priorities_end
	even

	section data_song_index
SongIndex:

	section data_sample_index
SampleIndex:
	dc.l	SAMPLE_COUNT
	section data_sample_index_end
SampleIndexEnd:

; ------------------------------------------------------------------------------
