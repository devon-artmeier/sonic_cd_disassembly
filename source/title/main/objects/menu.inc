; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Menu object variables
; ------------------------------------------------------------------------------

	rsset obj.vars
menu.delay		rs.b 1					; Delay counter
			rs.b 3
menu.option		rs.b 1					; Option ID
menu.allow_selection	rs.b 1					; Allow selection flag
			rs.b $16
menu.cloud_cheat	rs.b 1					; Clouds cheat index
			rs.b 3
menu.sound_test_cheat	rs.b 1					; Sound test cheat index
			rs.b 3
menu.stage_select_cheat	rs.b 1					; Stage select cheat index
			rs.b 3
menu.best_times_cheat	rs.b 1					; Best times cheat index

; ------------------------------------------------------------------------------
; Menu arrow object variables
; ------------------------------------------------------------------------------

	rsset	obj.vars
arrow.delay	rs.b	1					; Animation delay counter
arrow.frame	rs.b	1					; Animation frame
		rs.b	2
arrow.id	rs.b	1					; Text ID
		rs.b	3
arrow.parent	rs.w	1					; Parent object

; ------------------------------------------------------------------------------
