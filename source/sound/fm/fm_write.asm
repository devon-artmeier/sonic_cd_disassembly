; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"regions.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Write YM register data for track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef WriteYmTrack
WriteYmTrack:
	bit	2,(ix+track.channel)				; Is this track FM part 2?
	jr	nz,WriteYm2Track

	bit	TRACK_MUTE,(ix+track.flags)			; Is this track muted?
	ret	nz						; If so, exit
	add	a,(ix+track.channel)				; Add channel ID to register ID

; ------------------------------------------------------------------------------
; Write YM register data (part 1)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
; ------------------------------------------------------------------------------

	xdef WriteYm1
WriteYm1:
	ld	(YM_ADDR_0),a					; Write register data
	nop
	ld	a,c
	ld	(YM_DATA_0),a
	ret
	
; ------------------------------------------------------------------------------
; Write YM register data for track (part 2)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYm2Track:
	bit	TRACK_MUTE,(ix+track.flags)			; Is sound disabled?
	ret	nz						; If so, exit
	add	a,(ix+track.channel)				; Add channel ID to register ID
	sub	4

; ------------------------------------------------------------------------------
; Write YM register data (part 2)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Register ID
;	c  - Register data
; ------------------------------------------------------------------------------

	xdef WriteYm2
WriteYm2:
	ld	(YM_ADDR_1),a					; Write register data
	nop
	ld	a,c
	ld	(YM_DATA_1),a
	ret

; ------------------------------------------------------------------------------
; Update instrument
; ------------------------------------------------------------------------------
; PARAMETERS:
;	hl - Pointer to instrument data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef UpdateInstrument
UpdateInstrument:
	ld	de,InstrumentRegs				; Instrument registers
	
	ld	c,(ix+track.pan_ams_fms)			; Set panning/AMS/FMS
	ld	a,0B4h
	call	WriteYmTrack

	call	WriteInstrumentReg				; Set feedback/algorithm
	ld	(ix+track.algo_feedback),a
	
	ld	b,14h						; Set rest of the registers

.SetRegisters:
	call	WriteInstrumentReg
	djnz	.SetRegisters

	ld	(ix+track.tl_values),l				; Update volume with new TL data
	ld	(ix+track.tl_values+1),h
	jp	UpdateVolume

; ------------------------------------------------------------------------------
; Write instrument register
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to instrument register ID
;	hl - Pointer to instrument register data
; RETURNS:
;	a  - Written register data
; ------------------------------------------------------------------------------

WriteInstrumentReg:
	ld	a,(de)						; Set instrument register data
	inc	de
	ld	c,(hl)
	inc	hl
	call	WriteYmTrack
	ret

; ------------------------------------------------------------------------------
