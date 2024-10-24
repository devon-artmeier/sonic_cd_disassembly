; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Read envelope data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Envelope data index
;	hl - Pointer to envelope data
; RETURNS:
;	a  - Read data
; ------------------------------------------------------------------------------

	xdef ReadEnvelopeData
ReadEnvelopeData:
	ld	b,0						; Read envelope data
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	a,(bc)
	ret
	
; ------------------------------------------------------------------------------
; Get pointer to instrument data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	b  - Instrument ID
;	ix - Pointer to track variables
; RETURNS:
;	hl - Pointer to instrument data
; ------------------------------------------------------------------------------

	xdef GetInstrument
GetInstrument:
	ld	l,(ix+track.instruments)			; Get instrument data
	ld	h,(ix+track.instruments+1)
	
	xor	a						; Is the instrument ID 0?
	or	b
	jr	z,.End						; If so, branch

	ld	de,19h						; Jump to correct instrument data

.Iterate:
	add	hl,de
	djnz	.Iterate

.End:
	ret

; ------------------------------------------------------------------------------
