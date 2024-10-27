; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	section bss
	
; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; IDs
FM_START		equ 90h					; Starting SFX ID
FM_END			equ 0DFh				; Ending SFX ID
FM_CMD_STOP		equ 0E0h				; Stop command ID

; Track counts
TRACK_COUNT		equ 6					; Number of tracks

; Track flags
TRACK_FM3_DETUNE	equ 0					; FM3 detune mode flag
TRACK_LEGATO		equ 1					; Legato flag
TRACK_MUTE		equ 2					; Mute flag
TRACK_RAW_FREQ		equ 3					; Raw frequency mode
TRACK_REST		equ 4					; Rest flag
TRACK_PORTAMENTO	equ 5					; Portamento flag
TRACK_VIBRATO_END	equ 6					; Vibrato envelope end flag
TRACK_PLAY		equ 7					; Play flag

; ------------------------------------------------------------------------------
; Vibrato variables structure
; ------------------------------------------------------------------------------

	phase 0
vibrato.wait		ds 1					; Vibrato wait
vibrato.speed		ds 1					; Vibrato speed
vibrato.delta		ds 1					; Vibrato delta
vibrato.steps		ds 1					; Vibrato steps
vibrato.struct_size	ds 0					; Size of structure
	dephase

; ------------------------------------------------------------------------------
; Track variables structure
; ------------------------------------------------------------------------------

	phase 0
track.flags		ds 1					; Flags
track.channel		ds 1					; Channel ID
track.tick_multiply	ds 1					; Tick multiplier
track.data		ds 2					; Data address
track.transpose		ds 1					; Transposition
track.volume		ds 1					; Volume
track.vibrato_mode	ds 1					; Vibrato mode
track.instrument	ds 1					; Instrument ID
track.call_stack_addr	ds 1					; Call stack address
track.pan_ams_fms	ds 1					; Panning/AMS/FMS
track.duration_timer	ds 1					; Note duration timer
track.duration		ds 1					; Note duration
track.frequency		ds 2					; Frequency
			ds 1
track.porta_speed	ds 1					; Portamento speed
			ds 6
track.env_counter	ds 1					; Envelope counter
track.ssg_eg_mode	ds 1					; SSG-EG mode
track.ssg_eg_params	ds 2					; SSG-EG parameter address
track.algo_feedback	ds 1					; FM feedsack/algorithm
track.tl_values		ds 2					; FM TL data address
track.staccato_timer	ds 1					; Staccato timer
track.staccato		ds 1					; Staccato
track.vibrato_params	ds 2					; Vibrato parameters address
track.vibrato_offset	ds 2					; Vibrato offset
track.vibrato		ds vibrato.struct_size			; Vibrato variables
track.loop_counters	ds 2					; Loop counters
track.instruments	ds 2					; Instruments address
			ds 4
track.call_stack_base	ds 0					; Call stack base
track.struct_size	ds 0					; Size of structure
	dephase
	
track.vibrato_wait	equ track.vibrato+vibrato.wait		; Track vibrato wait
track.vibrato_speed	equ track.vibrato+vibrato.speed		; Track vibrato speed
track.vibrato_delta	equ track.vibrato+vibrato.delta		; Track vibrato delta
track.vibrato_steps	equ track.vibrato+vibrato.steps		; Track vibrato steps

TRACK_CLEAR_SIZE	equ track.struct_size-track.duration	; Track clear size

; ------------------------------------------------------------------------------
; Driver variables
; ------------------------------------------------------------------------------

	phase 1C00h
variables		ds 0					; Variables
			ds 9
z_sound_play		ds 1					; Sound play queue
z_sound_queue		ds 3					; Sound queue slots
fade_flag		ds 1					; Fade flag
			ds 4
ym_reg_27		ds 1					; YM register 27
tempo_timer		ds 1					; Tempo timer
tempo			ds 1					; Tempo
end_flag		ds 1					; End flag
communication_flag	ds 1					; Commincation flag
r_value			ds 1					; R register value
cur_priority		ds 1					; Current sound priority
			ds 1
fm3_detune_op1		ds 2					; FM3 OP1 detune value
fm3_detune_op2		ds 2					; FM3 OP2 detune value
fm3_detune_op3		ds 2					; FM3 OP3 detune value
fm3_detune_op4		ds 2					; FM3 OP4 detune value
			ds 10h
channel_id		ds 1					; Channel ID
			ds 6
instrument_table	ds 2					; Instrument table
tick_multiply		ds 1					; Tick multiplier
			ds 1
ring_channel		ds 1					; Ring channel
jump_condition		ds 1					; Jump condition
			ds 1
fm1_track		ds track.struct_size			; FM1 track
fm2_track		ds track.struct_size			; FM2 track
fm3_track		ds track.struct_size			; FM3 track
fm4_track		ds track.struct_size			; FM4 track
fm5_track		ds track.struct_size			; FM5 track
fm6_track		ds track.struct_size			; FM6 track
variables_end		ds 0					; End of variables
			ds 1FFDh-variables_end
stack_base		ds 0					; Stack base
	dephase
	
VARIABLES_CLEAR_SIZE	equ variables_end-z_sound_play		; Variables clear size

; ------------------------------------------------------------------------------
; Driver into structure
; ------------------------------------------------------------------------------

	phase 0
info.sfx_priorities	ds 2					; SFX priorities address
			ds 2
info.music_index	ds 2					; Music index address (unused)
info.sfx_index		ds 2					; SFX index address
			ds 2
			ds 2
info.first_sfx_id	ds 2					; First SFX ID
			ds 2
info.variables		ds 2					; Variables address
			ds 2
info.struct_size	ds 0					; Size of structure
	dephase
	
; ------------------------------------------------------------------------------
