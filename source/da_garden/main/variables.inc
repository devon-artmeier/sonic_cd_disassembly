; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Objects
OBJECT_COUNT		equ 16					; Object count

; Planet image VRAM
PLANET_IMAGE_VRAM	equ $0000				; VRAM address
PLANET_IMAGE_SIZE_1	equ PLANET_IMAGE_SIZE/2			; Part 1 length
PLANET_IMAGE_SIZE_2	equ PLANET_IMAGE_SIZE/2			; Part 2 length

; ------------------------------------------------------------------------------
; Object structure
; ------------------------------------------------------------------------------

	rsreset
obj.id			rs.w 1					; Object ID
obj.routine		rs.w 1					; Routine ID
obj.x			rs.l 1					; X position
obj.y			rs.l 1					; Y position
obj.x_speed		rs.l 1					; X speed
obj.y_speed		rs.l 1					; X speed
			rs.b 6					; 
obj.x_offset		rs.w 1					; X offset
obj.y_offset		rs.w 1					; Y offset
obj.float_angle		rs.w 1					; Float angle
			rs.b 2
obj.anim_delay		rs.w 1					; Animation delay
obj.anim_frame		rs.w 1					; Animation frame
obj.sprite_tile		rs.w 1					; Base sprite tile
obj.sprites		rs.l 1					; Sprite data address
obj.flags		rs.b 1					; Flags
obj.spawn_id		rs.b 1					; Spawn ID
obj.target_x		rs.w 1					; Target X position
obj.target_y		rs.w 1					; Target Y position
obj.float_speed		rs.w 1					; Float speed
obj.float_amplitude	rs.w 1					; Float amplitude
obj.mode_counter	rs.b 0					; Mode counter
obj.timer		rs.b 1					; Timer
obj.timer_2		rs.b 1					; Timer 2
obj.vars		rs.b $40-__RS				; Object specific variables
obj.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Track selection structure
; ------------------------------------------------------------------------------

	rsreset
track.routine		rs.w 1					; Routine ID
track.selection_id	rs.w 1					; Selection ID
track.title		rs.w 1					; Track title object slot
track.direction		rs.w 1					; Direction
track.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset WORK_RAM+$FF009000
VARIABLES		rs.b 0					; Start of variables
kos_buffer		rs.b 0					; Kosinski decompression buffer
planet_image		rs.b $5800				; Planet image buffer
sprites			rs.b $280				; Sprtie buffer
			rs.b $80
nem_code_table		rs.b $200				; Nemesis decompression code table
palette			rs.w $40				; Palette buffer
fade_palette		rs.w $40				; Fade palette buffer
water_palette		rs.w $40				; Water palette buffer
water_fade_palette	rs.w $40				; Water fade palette buffer

objects			rs.b OBJECT_COUNT*obj.struct_size	; Object pool
objects_end		rs.b 0					; End of object pool

			rs.b $40
track_data		rs.b track.struct_size			; Track selection data
			rs.b $38
palette_cycle_delay	rs.w 1					; Palette cycle delay
palette_cycle_frame	rs.w 1					; Palette cycle frame
volcano_anim_delay	rs.w 1					; Volcano animation delay
volcano_anim_frame	rs.w 1					; Volcano animation index
planet_render_count	rs.w 1					; Buffer render counter
sprite_pal_cycle_delay	rs.w 1					; Sprite palette cycle timer
sprite_pal_cycle_frame	rs.w 1					; Sprite palette cycle index
track_selection_flags	rs.b 1					; Track selection flags
			rs.b 1
		
object_spawn_timers	rs.b 0					; Object spawn timers
flicky_spawn_timer	rs.w 1					; Flicky object spawn timer
star_spawn_timer	rs.w 1					; Star object spawn timer
ufo_spawn_timer		rs.w 1					; UFO object spawn timer
eggman_spawn_timer	rs.w 1					; Eggman object spawn timer
metal_sonic_spawn_timer	rs.w 1					; Metal Sonic object spawn timer
tails_spawn_timer	rs.w 1					; Tails object spawn timer
OBJECT_TYPE_COUNT	equ (__RS-object_spawn_timers)/2

object_spawn_flags	rs.b 1					; Object spawn flags
object_spawn_id		rs.b 1					; Object spawn ID
button_flags		rs.b 1					; Button flags
vsync_flag		rs.b 1					; VSync flag
			rs.b 4
vblank_routine		rs.w 1					; V-BLANK routine ID
timer			rs.w 1					; Timer
frame_count		rs.w 1					; Frame count
saved_sr		rs.w 1					; Saved status register
rng_seed		rs.l 1					; RNG seed
lag_count		rs.l 1					; Lag count
vsync_flag_2		rs.b 1					; VSync flag 2 (not functional)
			rs.b 1
track_time_zone		rs.w 1					; Track time zone
palette_fade_params	rs.b 0					; Palette fade info
palette_fade_start	rs.b 1					; Palette fade start
palette_fade_length	rs.b 1					; Palette fade length
disable_palette_cycle	rs.b 1					; Disable palette cycle flag
			rs.b $845
VARIABLES_SIZE		equ __RS-VARIABLES			; Size of variables area

ctrl_data		equ MCD_MAIN_COMM_14			; Controller data
ctrl_hold		equ ctrl_data				; Controller held buttons data
ctrl_tap		equ ctrl_data+1				; Controller tapped buttons data

; ------------------------------------------------------------------------------
; Copy planet image to VRAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Buffer ID
;	\2 - Buffer part
; ------------------------------------------------------------------------------

copyPlanet macro
	ifeq \2
		__src: set planet_image
		__len: set PLANET_IMAGE_SIZE_1
	else
		__src: set planet_image+PLANET_IMAGE_SIZE_1
		__len: set PLANET_IMAGE_SIZE_2
	endif
	__vram: set PLANET_IMAGE_VRAM+((\1)*PLANET_IMAGE_SIZE)
	ifne \2
		__vram: set __vram+PLANET_IMAGE_SIZE_1
	endif
	dma68k __src,__vram,__len,VRAM
	endm

; ------------------------------------------------------------------------------
