; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Object structure
; ------------------------------------------------------------------------------

	rsreset
			rs.b 3
obj.routine		rs.b 1					; Routine ID
			rs.b $C
obj.angle		rs.w 1					; Angle
			rs.b 2
obj.x			rs.l 1					; X position
obj.y			rs.l 1					; Y position
obj.z			rs.l 1					; Z position
obj.unknown		rs.w 1					; Unknown
obj.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset PRG_RAM+$1C000FF009000
VARIABLES		rs.b 0					; Start of variables
			rs.b $800
VARIABLES_SIZE		equ __RS-VARIABLES			; Size of variables area

; ------------------------------------------------------------------------------
