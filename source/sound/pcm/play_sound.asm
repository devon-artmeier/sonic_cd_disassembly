; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"regions.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Process sound queue
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef ProcessSoundQueue
ProcessSoundQueue:
	tst.l	pcm.sound_queue(a5)				; Are any of the queue slots filled up?
	beq.s	.End						; If not, branch

	lea	pcm.sound_queue(a5),a1				; Get queue
	move.b	pcm.sfx_priority(a5),d3				; Get saved SFX priority level
	moveq	#4-1,d4						; Number of queue slots

.QueueLoop:
	moveq	#0,d0						; Get queue slot data
	move.b	(a1),d0
	move.b	d0,d1
	clr.b	(a1)+						; Clear slot

	cmpi.b	#PCM_SONG_START,d0				; Is a song queued?
	bcs.s	.NextSlot					; If not, branch
	cmpi.b	#PCM_SONG_END,d0
	bls.w	.SongId						; If so, branch

	cmpi.b	#PCM_SFX_START,d0				; Is a sound effect queued?
	bcs.s	.NextSlot					; If not, branch
	ifne BOSS
		cmpi.b	#$BA,d0
	else
		cmpi.b	#PCM_SFX_END,d0
	endif
	bls.w	.SfxId						; If so, branch

	cmpi.b	#PCM_CMD_START,d0				; Is a song queued?
	bcs.s	.NextSlot					; If not, branch
	cmpi.b	#PCM_CMD_END,d0
	bls.w	.CommandId					; If so, branch

	bra.s	.NextSlot					; Go to next slot

.CheckPriority:
	move.b	(a0,d0.w),d2					; Get priority level
	cmp.b	d3,d2						; Does this sound have a higher priority?
	bcs.s	.NextSlot					; If not, branch
	move.b	d2,d3						; Move up to the new priority level
	move.b	d1,pcm.sound_play(a5)				; Set sound to play

.NextSlot:
	dbf	d4,.QueueLoop					; Loop until all slots are checked
	tst.b	d3						; Is this a SFX priority level?
	bmi.s	.End						; If not, branch
	move.b	d3,pcm.sfx_priority(a5)				; If so, save it

.End:
	rts

.SongId:
	subi.b	#PCM_SONG_START,d0				; Get priority level
	lea	SongPriorities(pc),a0
	bra.s	.CheckPriority					; Check it

.SfxId:
	subi.b	#PCM_SFX_START,d0				; Get priority level
	lea	SfxPriorities(pc),a0
	bra.s	.CheckPriority					; Check it

.CommandId:
	subi.b	#PCM_CMD_START,d0				; Get priority level
	lea	CmdPriorities(pc),a0
	bra.s	.CheckPriority					; Check it

; ------------------------------------------------------------------------------
; Play a sound from the queue
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef PlaySoundId
PlaySoundId:
	moveq	#0,d7						; Get sound pulled from the queue
	move.b	pcm.sound_play(a5),d7
	beq.w	InitDriver					; If a sound hasn't been queued yet, initialize the driver
	bpl.w	StopSound					; If we are stopping all sound, branch
	move.b	#$80,pcm.sound_play(a5)				; Mark sound queue as processed

	cmpi.b	#PCM_SONG_START,d7				; Is it a song?
	bcs.s	.End						; If not, branch
	cmpi.b	#PCM_SONG_END,d7
	bls.w	PlaySong					; If so, branch

	cmpi.b	#PCM_SFX_START,d7				; Is it a sound effect?
	bcs.s	.End						; If not, branch
	ifne BOSS
		cmpi.b	#$BA,d7
	else
		cmpi.b	#PCM_SFX_END,d7
	endif
	bls.w	PlaySfx						; If so, branch

	cmpi.b	#PCM_CMD_START,d7				; Is it a command?
	bcs.s	.End						; If not, branch
	cmpi.b	#PCM_CMD_END,d7
	bls.w	RunCommand					; If so, branch

.End:
	rts

; ------------------------------------------------------------------------------
; Play a song
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d7.b - Song ID
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

PlaySong:
	jsr	ResetDriver(pc)					; Reset driver

	lea	SongIndex(pc),a2				; Get pointer to song
	subi.b	#PCM_SONG_START,d7
	andi.w	#$7F,d7
	lsl.w	#2,d7
	movea.l	(a2,d7.w),a2
	adda.l	pcm.ptr_offset(a5),a2
	movea.l	a2,a0

	moveq	#0,d7						; Get number of tracks
	move.b	2(a2),d7
	move.b	4(a2),d1					; Get tick multiplier
	move.b	5(a2),pcm.tempo(a5)				; Get tempo
	move.b	5(a2),pcm.tempo_timer(a5)
	addq.w	#6,a2

	lea	pcm.rhythm(a5),a3				; Start with the rhythm track
	lea	ChannelIds(pc),a1				; Channel ID array
	move.b	#track.call_stack_base,d2			; Call stack base
	subq.w	#1,d7						; Subtract 1 from track count for dbf

.InitTracks:
	moveq	#0,d0						; Get track address
	move.w	(a2)+,d0
	add.l	a0,d0
	move.l	d0,track.data_addr(a3)
	move.w	(a2)+,track.transpose(a3)			; Set transposition and volume

	move.b	(a1)+,d0					; Get channel ID
	move.b	d0,track.channel(a3)

	ori.b	#$C0,d0						; Set up PCM registers for channel
	move.b	d0,PCM_CTRL-PCM_REGS(a4)

	lsl.b	#5,d0
	move.b	d0,PCM_START-PCM_REGS(a4)
	move.b	d0,PCM_LOOP_H-PCM_REGS(a4)
	move.b	#0,PCM_LOOP_L-PCM_REGS(a4)
	move.b	#$FF,PCM_PAN-PCM_REGS(a4)
	move.b	track.volume(a3),PCM_VOLUME-PCM_REGS(a4)

	move.b	d1,track.tick_multiply(a3)			; Set tick multiplier
	move.b	d2,track.call_stack_addr(a3)			; Set call stack pointer
	move.b	#1<<TRACK_PLAY,track.flags(a3)			; Mark track as playing
	move.b	#1,track.duration_timer(a3)			; Set initial note duration

	adda.w	#track.struct_size,a3				; Next track
	dbf	d7,.InitTracks					; Loop until finished
	
	clr.b	pcm.rhythm+track.flags(a5)			; Disable rhythm track
	move.b	#$FF,pcm.on(a5)					; Silence all channels
	rts

; ------------------------------------------------------------------------------
; Channel ID array
; ------------------------------------------------------------------------------

ChannelIds:
	dc.b	7						; Rhythm
	dc.b	0						; PCM1
	dc.b	1						; PCM2
	dc.b	2						; PCM3
	dc.b	3						; PCM4
	dc.b	4						; PCM5
	dc.b	5						; PCM6
	dc.b	7						; PCM7
	dc.b	6						; PCM8
	even

; ------------------------------------------------------------------------------
; Play a sound effect
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d7.b - SFX ID
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

PlaySfx:
	lea	SfxIndex(pc),a2					; Get pointer to SFX
	subi.b	#PCM_SFX_START,d7
	andi.w	#$7F,d7
	lsl.w	#2,d7
	movea.l	(a2,d7.w),a2
	adda.l	pcm.ptr_offset(a5),a2
	movea.l	a2,a0

	moveq	#0,d7						; Get number of tracks
	move.b	3(a2),d7
	move.b	2(a2),d1					; Get tick multiplier
	addq.w	#4,a2

	lea	ChannelIds(pc),a1				; Channel ID array (unused here)
	move.b	#track.call_stack_base,d2			; Call stack base
	subq.w	#1,d7						; Subtract 1 from track count for dbf

.InitTracks:
	lea	pcm.sfx_1(a5),a3				; Get PCM track data
	moveq	#0,d0
	move.b	1(a2),d0
	ifne track.struct_size=$80
		lsl.w	#7,d0
	else
		mulu.w	#track.struct_size,d0
	endif
	adda.w	d0,a3

	movea.l	a3,a1						; Clear track data
	move.w	#track.struct_size/4-1,d0

.ClearTrack:
	clr.l	(a1)+
	dbf	d0,.ClearTrack
	ifne track.struct_size&2
		clr.w	(a1)+
	endif
	ifne track.struct_size&1
		clr.b	(a1)+
	endif

	move.w	(a2)+,(a3)					; Set track flags and channel ID
	moveq	#0,d0						; Get track address
	move.w	(a2)+,d0
	add.l	a0,d0
	move.l	d0,track.data_addr(a3)
	move.w	(a2)+,track.transpose(a3)			; Set transposition and volume

	move.b	track.channel(a3),d0				; Set up PCM registers for channel
	ori.b	#$C0,d0
	move.b	d0,PCM_CTRL-PCM_REGS(a4)

	lsl.b	#5,d0
	move.b	d0,PCM_START-PCM_REGS(a4)
	move.b	d0,PCM_LOOP_H-PCM_REGS(a4)
	move.b	#0,PCM_LOOP_L-PCM_REGS(a4)
	move.b	#$FF,PCM_PAN-PCM_REGS(a4)
	move.b	track.volume(a3),PCM_VOLUME-PCM_REGS(a4)

	move.b	d1,track.tick_multiply(a3)			; Set tick multiplier
	move.b	d2,track.call_stack_addr(a3)			; Set call stack pointer
	move.b	#1,track.duration_timer(a3)			; Set initial note duration
	move.b	#0,track.staccato(a3)				; Reset staccato
	move.b	#0,track.detune(a3)				; Reset detune

	dbf	d7,.InitTracks					; Loop until finished
	rts

; ------------------------------------------------------------------------------
