; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

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
