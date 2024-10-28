; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; Objects
	ifne REGION<>JAPAN					; Object count
OBJECT_COUNT		equ 10
	else
OBJECT_COUNT		equ 8
	endif

; Cloud image VRAM
CLOUD_IMAGE_VRAM	equ $0020				; VRAM address
CLOUD_IMAGE_SIZE_1	equ CLOUD_IMAGE_SIZE/2			; Part 1 length
CLOUD_IMAGE_SIZE_2	equ CLOUD_IMAGE_SIZE/2			; Part 2 length

; ------------------------------------------------------------------------------
; Object variables structure
; ------------------------------------------------------------------------------

	rsreset
obj.addr		rs.w 1					; Address
obj.active		rs.b 1					; Active flag
obj.flags		rs.b 1					; Flags
obj.sprite_tile		rs.w 1					; Base sprite tile
obj.sprites		rs.l 1					; Mappings
obj.sprite_frame	rs.b 1					; Mappings frame
			rs.b 1
obj.x			rs.l 1					; X position
obj.y			rs.l 1					; Y position
obj.vars		rs.b $40-__RS				; Object specific variables
obj.struct_size		rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	rsset	WORK_RAM+$FF00A000
VARIABLES		rs.b 0					; Start of variables
cloud_image		rs.b CLOUD_IMAGE_SIZE			; Clouds image buffer
hscroll			rs.b $380				; Horizontal scroll buffer
			rs.b $80
sprites			rs.b 80*8				; Sprite buffer
water_scroll		rs.b $100				; Scroll buffer
			rs.b $B80

objects			rs.b OBJECT_COUNT*obj.struct_size	; Object pool
objects_end		rs.b 0					; End of object pool

			rs.b $FFFFF700-__RS

nem_code_table		rs.b $200				; Nemesis decompression code table
palette			rs.w $40				; Palette buffer
fade_palette		rs.w $40				; Fade palette buffer
			rs.b 1
unk_palette_fade_flag	rs.b 1					; Unknown palette fade flag
palette_fade_params	rs.b 0					; Palette fade parameters
palette_fade_start	rs.b 1					; Palette fade start
palette_fade_length	rs.b 1					; Palette fade length
title_mode		rs.b 1					; Title screen mode
			rs.b 5
global_object_y_speed	rs.w 1					; Global object Y speed
palette_cycle_frame	rs.b 1					; Palette cycle frame
palette_cycle_delay	rs.b 1					; Palette cycle delay
exit_flag		rs.b 1					; Exit flag
menu_selection		rs.b 1					; Menu selection
menu_options		rs.b 8					; Available menu options
p2_ctrl_data		rs.b 0					; Player 2 controller data
p2_ctrl_hold		rs.b 1					; Player 2 controller held buttons data
p2_ctrl_tap		rs.b 1					; Player 2 controller tapped buttons data
p1_ctrl_data		rs.b 0					; Player 1 controller data
p1_ctrl_hold		rs.b 1					; Player 1 controller held buttons data
p1_ctrl_tap		rs.b 1					; Player 1 controller tapped buttons data
control_clouds		rs.b 1					; Control clouds flag
			rs.b 1
fm_sound_queue		rs.b 1					; FM sound queue
			rs.b 1
sub_wait_time		rs.l 1					; Sub CPU wait time
sub_fail_count		rs.b 1					; Sub CPU fail count
			rs.b 1
enable_display		rs.b 1					; Enable display flag
			rs.b $19
vblank_routine		rs.w 1					; V-BLANK routine ID
timer			rs.w 1					; Timer
frame_count		rs.w 1					; V-BLANK interrupt counter
saved_sr		rs.w 1					; Saved status register
sprite_count		rs.b 1					; Sprite count
			rs.b 1
cur_sprite_slot		rs.l 1					; Current sprite slot
			rs.b $B2
VARIABLES_SIZE		equ __RS-VARIABLES			; Size of variables area

lag_counter		rs.l 1					; Lag counter

sub_p2_ctrl_data	equ MCD_MAIN_COMM_14			; Sub CPU player 2 controller data
sub_p2_ctrl_hold	equ sub_p2_ctrl_data			; Sub CPU player 2 controller held buttons data
sub_p2_ctrl_tap		equ sub_p2_ctrl_data+1			; Sub CPU player 2 controller tapped buttons data

; ------------------------------------------------------------------------------
; Copy cloud image to VRAM
; -------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Buffer ID
;	\2 - Buffer part
; ------------------------------------------------------------------------------

copyClouds macro
	ifeq (\2)
		__src: set cloud_image
		__len: set CLOUD_IMAGE_SIZE_1
	else
		__src: set cloud_image+CLOUD_IMAGE_SIZE_1
		__len: set CLOUD_IMAGE_SIZE_2
	endif
	__vram: set CLOUD_IMAGE_VRAM+((\1)*CLOUD_IMAGE_SIZE)
	ifne (\2)
		__vram: set __vram+CLOUD_IMAGE_SIZE_1
	endif
	dma68k __src,__vram,__len,VRAM
	endm

; ------------------------------------------------------------------------------
