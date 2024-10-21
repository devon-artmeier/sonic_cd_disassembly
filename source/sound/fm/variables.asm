; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	section bss

; ------------------------------------------------------------------------------
; Define variable
; ------------------------------------------------------------------------------
; PARAMETERS
;	\1 - Variable name
;	\2 - Variable size
; ------------------------------------------------------------------------------

var macro
	xdef \1
\1	ds \2
	endm

; ------------------------------------------------------------------------------
; Vibrato variables structure
; ------------------------------------------------------------------------------

	phase 0
	var vibrato.wait,        1				; Vibrato wait
	var vibrato.speed,       1				; Vibrato speed
	var vibrato.delta,       1				; Vibrato delta
	var vibrato.steps,       1				; Vibrato steps
	var vibrato.struct_size, 0				; Size of structure
	dephase

; ------------------------------------------------------------------------------
; Track variables structure
; ------------------------------------------------------------------------------

	phase 0
	var track.flags,           1				; Flags
	var track.channel,         1				; Channel ID
	var track.tick_multiply,   1				; Tick multiplier
	var track.data,            2				; Data address
	var track.transpose,       1				; Transposition
	var track.volume,          1				; Volume
	var track.vibrato_mode,    1				; Vibrato mode
	var track.instrument,      1				; Instrument ID
	var track.call_stack_addr, 1				; Call stack address
	var track.pan_ams_fms,     1				; Panning/AMS/FMS
	var track.duration_timer,  1				; Note duration timer
	var track.duration,        1				; Note duration
	var track.frequency,       2				; Frequency
	                           ds 1
	var track.porta_speed,     1				; Portamento speed
	                           ds 6
	var track.env_counter,     1				; Envelope counter
	var track.ssg_eg_mode,     1				; SSG-EG mode
	var track.ssg_eg_params,   2				; SSG-EG parameter address
	var track.algo_feedback,   1				; FM feedsack/algorithm
	var track.tl_values,       2				; FM TL data address
	var track.staccato_timer,  1				; Staccato timer
	var track.staccato,        1				; Staccato
	var track.vibrato_params,  2				; Vibrato parameters address
	var track.vibrato_offset,  2				; Vibrato offset
	var track.vibrato,         vibrato.struct_size		; Vibrato variables
	var track.loop_counters,   2				; Loop counters
	var track.instruments,     2				; Instruments address
	                           ds 4
	var track.call_stack_base, 0				; Call stack base
	var track.struct_size,     0				; Size of structure
	dephase
	
	xdef track.vibrato_wait, track.vibrato_speed, track.vibrato_delta, track.vibrato_steps
	xdef TRACK_CLEAR_SIZE
	
track.vibrato_wait	equ track.vibrato+vibrato.wait		; Track vibrato wait
track.vibrato_speed	equ track.vibrato+vibrato.speed		; Track vibrato speed
track.vibrato_delta	equ track.vibrato+vibrato.delta		; Track vibrato delta
track.vibrato_steps	equ track.vibrato+vibrato.steps		; Track vibrato steps

TRACK_CLEAR_SIZE	equ track.struct_size-track.duration	; Track clear size

; ------------------------------------------------------------------------------
; Driver variables
; ------------------------------------------------------------------------------

	phase 1C00h
	var variables,          0				; Variables
	                        ds 9
	var z_sound_play,       1				; Sound play queue
	var z_sound_queue,      3				; Sound queue slots
	var fade_flag,          1				; Fade flag
	                        ds 4
	var ym_reg_27,          1				; YM register 27
	var tempo_timer,        1				; Tempo timer
	var tempo,              1				; Tempo
	var end_flag,           1				; End flag
	var communication_flag, 1				; Commincation flag
	var r_value,            1				; R register value
	var cur_priority,       1				; Current sound priority
	                        ds 1
	var fm3_detune_op1,     2				; FM3 OP1 detune value
	var fm3_detune_op2,     2				; FM3 OP2 detune value
	var fm3_detune_op3,     2				; FM3 OP3 detune value
	var fm3_detune_op4,     2				; FM3 OP4 detune value
	                        ds 10h
	var channel_id,         1				; Channel ID
	                        ds 6
	var instrument_table,   2				; Instrument table
	var tick_multiply,      1				; Tick multiplier
	                        ds 1
	var ring_channel,       1				; Ring channel
	var jump_condition,     1				; Jump condition
	                        ds 1
	var fm1_track,          track.struct_size		; FM1 track
	var fm2_track,          track.struct_size		; FM2 track
	var fm3_track,          track.struct_size		; FM3 track
	var fm4_track,          track.struct_size		; FM4 track
	var fm5_track,          track.struct_size		; FM5 track
	var fm6_track,          track.struct_size		; FM6 track
	var variables_end,      0				; End of variables
	                        ds 1FFDh-variables_end
	var stack_base,         0				; Stack base
	dephase
	
	xdef VARIABLES_CLEAR_SIZE
VARIABLES_CLEAR_SIZE	equ variables_end-z_sound_play		; Variables clear size

; ------------------------------------------------------------------------------
; Driver into structure
; ------------------------------------------------------------------------------

	phase 0
	var info.sfx_priorities, 2				; SFX priorities address
	                         ds 2
	var info.song_index,     2				; Song index address (unused)
	var info.sfx_index,      2				; SFX index address
	                         ds 2
	                         ds 2
	var info.first_sfx_id,   2				; First SFX ID
	                         ds 2
	var info.variables,      2				; Variables address
	                         ds 2
	var info.struct_size,    0				; Size of structure
	dephase
	
; ------------------------------------------------------------------------------
