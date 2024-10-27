; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Process track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d5.w - Track command ID
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef TrackCommand
TrackCommand:
	subi.w	#$E0,d5						; Run track command
	lsl.w	#2,d5
	jmp	.Commands(pc,d5.w)
	
; ------------------------------------------------------------------------------

.Commands:
	jmp	PanCommand(pc)					; Set panning
	jmp	DetuneCommand(pc)				; Set detune
	jmp	CommunicationCommand(pc)			; Set communication flag
	jmp	CddaLoopCommand(pc)				; Set CDDA loop flag
	jmp	NullCommand(pc)					; Null
	jmp	NullCommand(pc)					; Null
	jmp	VolumeCommand(pc)				; Add volume
	jmp	LegatoCommand(pc)				; Set legato
	jmp	StaccatoCommand(pc)				; Set staccato
	jmp	NullCommand(pc)					; Null
	jmp	TempoCommand(pc)				; Set tempo
	jmp	PlaySoundCommand(pc)				; Play sound
	jmp	NullCommand(pc)					; Null
	jmp	NullCommand(pc)					; Null
	jmp	NullCommand(pc)					; Null
	jmp	InstrumentCommand(pc)				; Set instrument
	jmp	StopCommand(pc)					; Stop
	jmp	StopCommand(pc)					; Stop
	jmp	StopCommand(pc)					; Stop
	jmp	NullCommand(pc)					; Null
	jmp	JumpCommand(pc)					; Jump
	jmp	NullCommand(pc)					; Null
	jmp	JumpCommand(pc)					; Jump
	jmp	LoopCommand(pc)					; Loop
	jmp	CallCommand(pc)					; Call
	jmp	ReturnCommand(pc)				; Return
	jmp	TickMultiplyCommand(pc)				; Set track tick multiplier
	jmp	TransposeCommand(pc)				; Transpose
	jmp	GlobalTickMultCommand(pc)			; Set global tick multiplier
	jmp	NullCommand(pc)					; Null
	jmp	InvalidCommand(pc)				; Invalid

; ------------------------------------------------------------------------------
; Null track command
; ------------------------------------------------------------------------------

NullCommand:
	rts

; ------------------------------------------------------------------------------
; Panning track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

PanCommand:
	move.b	track.channel(a3),d0				; Set channel
	ori.b	#$C0,d0
	move.b	d0,PCM_CTRL-PCM_REGS(a4)

	move.b	(a2),track.panning(a3)				; Set panning
	move.b	(a2)+,PCM_PAN-PCM_REGS(a4)
	rts

; ------------------------------------------------------------------------------
; Detune track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

DetuneCommand:
	move.b	(a2)+,track.detune(a3)				; Set detune
	rts

; ------------------------------------------------------------------------------
; Communication flag track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

CommunicationCommand:
	move.b	(a2)+,pcm.communication(a5)			; Set communication flag
	rts

; ------------------------------------------------------------------------------
; CDDA loop flag track command
; ------------------------------------------------------------------------------
; This was called in the prototype PCM music loop segments, but still
; didn't function.
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

CddaLoopCommand:
	move.b	#1,pcm.cdda_loop(a5)				; Set CDDA loop flag
	rts

; ------------------------------------------------------------------------------
; Volume track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

VolumeCommand:
	move.b	track.channel(a3),d0				; Set channel
	ori.b	#$C0,d0
	move.b	d0,PCM_CTRL-PCM_REGS(a4)

	move.b	(a2)+,d0					; Get volume modifier
	bmi.s	.VolumeDown					; If we are turning the volume down, branch

.VolumeUp:
	add.b	d0,track.volume(a3)				; Add volume
	bcs.s	.CapVolumeAt0					; If it has overflowed, branch
	bra.w	.UpdateVolume					; Update volume

.VolumeDown:
	add.b	d0,track.volume(a3)				; Subtract volume
	bcc.s	.CapVolumeAt0					; If it has underflowed, branch

.UpdateVolume:
	move.b	track.volume(a3),PCM_VOLUME-PCM_REGS(a4)	; Set volume

.End:
	rts

.CapVolumeAt0:
	tst.b	pcm.fade_steps(a5)				; Is the music fading out?
	beq.s	.End						; If not, branch
	bclr	#TRACK_PLAY,(a3)				; Stop track
	move.b	#0,PCM_VOLUME-PCM_REGS(a4)			; Set volume to 0
	rts

; ------------------------------------------------------------------------------
; Legato track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

LegatoCommand:
	bset	#TRACK_LEGATO,(a3)				; Set legato flag
	rts

; ------------------------------------------------------------------------------
; Staccato track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

StaccatoCommand:
	move.b	(a2),track.staccato_timer(a3)			; Set staccato
	move.b	(a2)+,track.staccato(a3)
	rts

; ------------------------------------------------------------------------------
; Tempo track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

TempoCommand:
	move.b	(a2),pcm.tempo_timer(a5)			; Set tempo
	move.b	(a2)+,pcm.tempo(a5)
	rts

; ------------------------------------------------------------------------------
; Sound play track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

PlaySoundCommand:
	move.b	(a2)+,pcm.sound_queue(a5)			; Play sound
	rts

; ------------------------------------------------------------------------------
; Instrument track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

InstrumentCommand:
	moveq	#0,d0						; Get sample data
	move.b	(a2)+,d0
	lea	SampleIndex(pc),a0
	addq.w	#4,a0
	lsl.w	#2,d0
	movea.l	(a0,d0.w),a0
	adda.l	pcm.ptr_offset(a5),a0

	move.b	sample.staccato(a0),track.sample_staccato(a3)	; Set up staccato
	move.b	sample.staccato(a0),track.sample_stac_timer(a3)

	move.b	sample.mode(a0),track.sample_mode(a3)		; Set sample mode
	bne.s	.StaticSample					; If it's a static sample, branch

	movea.l	sample.address(a0),a1				; Set up sample streaming
	adda.l	pcm.ptr_offset(a5),a1
	move.l	a1,track.sample_start(a3)
	move.l	a1,track.sample_addr(a3)
	move.l	sample.size(a0),track.sample_size(a3)
	move.l	sample.size(a0),track.samples_remain(a3)
	move.l	sample.loop(a0),track.sample_loop(a3)
	move.l	#PCM_WAVE_RAM,track.sample_ram_addr(a3)
	clr.b	track.sample_bank(a3)
	move.b	#8-1,track.sample_blocks(a3)
	rts

; ------------------------------------------------------------------------------

.StaticSample:
	move.b	track.channel(a3),d0				; Set channel
	ori.b	#$C0,d0
	move.b	d0,PCM_CTRL-PCM_REGS(a4)

	move.w	sample.dest_addr(a0),d0				; Set sample start point
	move.w	d0,d1
	lsr.w	#8,d0
	move.b	d0,PCM_START-PCM_REGS(a4)

	move.l	sample.loop(a0),d0				; Set sample loop point
	add.w	d1,d0
	move.b	d0,PCM_LOOP_L-PCM_REGS(a4)
	lsr.w	#8,d0
	move.b	d0,PCM_LOOP_H-PCM_REGS(a4)
	rts

; ------------------------------------------------------------------------------
; Stop track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

StopCommand:
	bclr	#TRACK_PLAY,(a3)				; Stop track
	bclr	#TRACK_LEGATO,(a3)				; Clear legato flag
	jsr	RestTrack(pc)					; Set track as rested

	tst.b	pcm.sfx_mode(a5)				; Are we in SFX mode?
	beq.w	.End						; If not, branch
	clr.b	pcm.sfx_priority(a5)				; Clear SFX priority level

.End:
	addq.w	#8,sp						; Skip right to the next track
	rts

; ------------------------------------------------------------------------------
; Jump track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
; ------------------------------------------------------------------------------

JumpCommand:
	move.b	(a2)+,d0					; Jump to offset
	lsl.w	#8,d0
	move.b	(a2)+,d0
	adda.w	d0,a2
	subq.w	#1,a2
	rts

; ------------------------------------------------------------------------------
; Loop track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

LoopCommand:
	moveq	#0,d0						; Get loop index
	move.b	(a2)+,d0
	move.b	(a2)+,d1					; Get loop count

	tst.b	track.loop_counters(a3,d0.w)			; Is the loop count already set?
	bne.s	.CheckLoop					; If so, branch
	move.b	d1,track.loop_counters(a3,d0.w)			; Set loop count

.CheckLoop:
	subq.b	#1,track.loop_counters(a3,d0.w)			; Decrement loop count
	bne.s	JumpCommand					; If it hasn't run out, branch
	addq.w	#2,a2						; If it has, skip past loop offset
	rts

; ------------------------------------------------------------------------------
; Call track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

CallCommand:
	moveq	#0,d0						; Get call stack pointer
	move.b	track.call_stack_addr(a3),d0
	subq.b	#4,d0						; Move up call stack
	move.l	a2,(a3,d0.w)					; Save return address
	move.b	d0,track.call_stack_addr(a3)			; Update call stack pointer
	bra.s	JumpCommand					; Jump to offset

; ------------------------------------------------------------------------------
; Return track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

ReturnCommand:
	moveq	#0,d0						; Get call stack pointer
	move.b	track.call_stack_addr(a3),d0
	movea.l	(a3,d0.w),a2					; Go to return address
	addq.w	#2,a2
	addq.b	#4,d0						; Move down stack
	move.b	d0,track.call_stack_addr(a3)			; Update call stack pointer
	rts

; ------------------------------------------------------------------------------
; Track tick multiplier track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

TickMultiplyCommand:
	move.b	(a2)+,track.tick_multiply(a3)			; Set tick multiplier
	rts

; ------------------------------------------------------------------------------
; Transpose track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

TransposeCommand:
	move.b	(a2)+,d0					; Add transposition
	add.b	d0,track.transpose(a3)
	rts

; ------------------------------------------------------------------------------
; Global tick multiplier track command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l - Pointer to track data
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

GlobalTickMultCommand:
	lea	pcm.rhythm(a5),a0				; Update music tracks
	move.b	(a2)+,d0
	move.w	#track.struct_size,d1
	moveq	#TRACK_COUNT-1,d2

.SetTickMultiply:
	move.b	d0,track.tick_multiply(a0)			; Set tick multiplier
	adda.w	d1,a0						; Next track
	dbf	d2,.SetTickMultiply				; Loop until all tracks are updated
	rts

; ------------------------------------------------------------------------------
; Invalid track command
; ------------------------------------------------------------------------------

InvalidCommand:

; ------------------------------------------------------------------------------
