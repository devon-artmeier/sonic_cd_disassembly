; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"constants.inc"

	section code
	
; --------------------------------------------------------------------------------
; Instrument registers
; --------------------------------------------------------------------------------

	xdef InstrumentRegs, InstrumentRegsTl, InstrumentRegsSsgEg
InstrumentRegs:
	db	0B0h						; Feedback/Algorithm
	db	30h, 38h, 34h, 3Ch				; Detune/Multiply
	db	50h, 58h, 54h, 5Ch				; Rate scale/Attack rate
	db	60h, 68h, 64h, 6Ch				; AMS enable/Decay rate
	db	70h, 78h, 74h, 7Ch				; Sustain rate
	db	80h, 88h, 84h, 8Ch				; Sustain level/Release rate
InstrumentRegsTl:
	db	40h, 48h, 44h, 4Ch				; Total level
InstrumentRegsSsgEg:
	db	90h, 98h, 94h, 9Ch				; SSG-EG

; --------------------------------------------------------------------------------
; Special FM3 frequency registers
; --------------------------------------------------------------------------------

	xdef SpecialFm3Regs
SpecialFm3Regs:
	db	0ADh, 0AEh, 0ACh, 0A6h				; FM3 frequency
	
; ------------------------------------------------------------------------------
