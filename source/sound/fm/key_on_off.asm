; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"constants.inc"

	section code

; ------------------------------------------------------------------------------
; Set key on
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef SetKeyOn
SetKeyOn:
	ld	a,(ix+track.frequency)				; Is a frequency set?
	or	(ix+track.frequency+1)
	ret	z						; If not, exit
	
	ld	a,(ix+track.flags)				; Is either legato set or sound disabled?
	and	(1<<TRACK_LEGATO)|(1<<TRACK_MUTE)
	ret	nz						; If so, exit

	ld	a,(ix+track.channel)				; Set key on
	or	0F0h
	ld	c,a
	ld	a,28h
	call	WriteYm1
	ret

; ------------------------------------------------------------------------------
; Set key off
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef SetKeyOff, ForceKeyOff
SetKeyOff:
	ld	a,(ix+track.flags)				; Is either legato set or sound disabled?
	and	(1<<TRACK_LEGATO)|(1<<TRACK_MUTE)
	ret	nz						; If so, exit

ForceKeyOff:
	res	TRACK_VIBRATO_END,(ix+track.flags)		; Clear vibrato envelope end flag
	
	ld	c,(ix+track.channel)				; Set key off
	ld	a,28h
	call	WriteYm1
	ret
	
; ------------------------------------------------------------------------------
