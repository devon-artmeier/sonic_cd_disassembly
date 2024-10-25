; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Sonic object variables
; ------------------------------------------------------------------------------

	rsset obj.vars
sonic.delay		rs.b 1					; Animation delay

; ------------------------------------------------------------------------------
; Sonic's arm object variables
; ------------------------------------------------------------------------------

	rsset obj.vars
arm.delay		rs.b 1					; Delay counter
			rs.b 3					; Unused
arm.frame		rs.b 1					; Animatiom frame
			rs.b 3					; Unused
arm.parent		rs.w 1					; Parent object

; ------------------------------------------------------------------------------