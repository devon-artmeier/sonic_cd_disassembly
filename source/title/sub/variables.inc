; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Cloud rendering variable structure
; ------------------------------------------------------------------------------

	rsreset
clouds.camera_x		rs.w 1					; Camera X
clouds.camera_y		rs.w 1					; Camera Y
clouds.camera_z		rs.w 1					; Camera Z
clouds.pitch		rs.w 1					; Pitch
clouds.pitch_sin	rs.w 1					; Sine of pitch
clouds.pitch_cos	rs.w 1					; Cosine of pitch
clouds.yaw		rs.w 1					; Yaw
clouds.yaw_sin		rs.w 1					; Sine of yaw
clouds.yaw_cos		rs.w 1					; Cosine of yaw
clouds.yaw_sin_neg	rs.w 1					; Negative sine of yaw
clouds.yaw_cos_neg	rs.w 1					; Negative cosine of yaw
clouds.fov		rs.w 1					; FOV
clouds.center		rs.w 1					; Center point
			rs.b $16
clouds.ps_ys_fov	rs.l 1					; sin(pitch) * sin(yaw) * FOV
clouds.ps_yc_fov	rs.l 1					; sin(pitch) * cos(yaw) * FOV
			rs.b 8
clouds.pc_fov		rs.l 1					; cos(pitch) * FOV
			rs.b 4
clouds.ys_fov		rs.w 1					; sin(yaw) * FOV
			rs.b 2
clouds.yc_fov		rs.w 1					; cos(yaw) * FOV
			rs.b 6
clouds.center_x		rs.w 1					; Center point X offset
			rs.b 2
clouds.center_y		rs.w 1					; Center point Y offset
			rs.b 2
clouds.pc_ys		rs.w 1					; cos(pitch) * sin(yaw)
			rs.b 2
clouds.pc_yc		rs.w 1					; cos(pitch) * cos(yaw)
clouds.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset	PRG_RAM+$1E000
VARIABLES		rs.b 0					; Start of variables
			rs.b $300
clouds_rendering	rs.b 1					; Cloud rendering flag
			rs.b $AFF
cloud_render_vars	rs.b clouds.struct_size			; Cloud rendering variables
			rs.b $119E

VARIABLES_SIZE		equ __RS-VARIABLES			; Size of variables area

p2_ctrl_data		equ MCD_MAIN_COMM_14			; Player 2 controller data
p2_ctrl_hold		equ p2_ctrl_data			; Player 2 controller held buttons data
p2_ctrl_tap		equ p2_ctrl_data+1			; Player 2 controller tapped buttons data

; ------------------------------------------------------------------------------
