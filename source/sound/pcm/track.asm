; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Update tracks
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef UpdateTracks
UpdateTracks:
	clr.b	pcm.sfx_mode(a5)				; Song mode

	lea	pcm.rhythm(a5),a3				; Update song tracks
	moveq	#PCM_TRACK_COUNT-1,d7

.SongTracks:
	adda.w	#track.struct_size,a3				; Next track
	tst.b	(a3)						; Is this track playing?
	bpl.s	.NextSongTrack					; If not, branch
	jsr	UpdateTrack(pc)					; Update track

.NextSongTrack:
	dbf	d7,.SongTracks					; Loop until finished

	lea	pcm.sfx_1(a5),a3				; Update SFX tracks
	move.b	#$80,pcm.sfx_mode(a5)				; SFX mode
	moveq	#PCM_TRACK_COUNT-1,d7

.SfxTracks:
	tst.b	(a3)						; Is this track playing?
	bpl.s	.NextSfxTrack					; If not, branch
	jsr	UpdateTrack(pc)					; Update track

.NextSfxTrack:
	adda.w	#track.struct_size,a3				; Next track
	dbf	d7,.SfxTracks					; Loop until finished
	rts

; ------------------------------------------------------------------------------
; Update track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
;	a6.l - Pointer to driver information table
; ------------------------------------------------------------------------------

UpdateTrack:
	subq.b	#1,track.duration_timer(a3)			; Decrement duration counter
	bne.s	.Update						; If it hasn't run out, branch
	
	bclr	#TRACK_LEGATO,(a3)				; Clear legato flag
	jsr	ParseTrackData(pc)				; Parse track data
	jsr	StartStream(pc)					; Start streaming sample data
	jsr	UpdateFrequency(pc)				; Update frequency
	bra.w	SetKeyOn					; Set note on

.Update:
	jsr	UpdateSample(pC)				; Update sample
	; BUG: The developers removed vibrato support and optimized this
	; call, but they accidentally left in the stack pointer adjustment
	; in the routine. See the routine for more information.
	bra.w	HandleStaccato					; Handle staccato

; ------------------------------------------------------------------------------
; Parse track data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
;	a6.l - Pointer to driver information table
; ------------------------------------------------------------------------------

ParseTrackData:
	movea.l	track.data_addr(a3),a2				; Get track data pointer
	bclr	#TRACK_REST,(a3)				; Clear rest flag

.ParseLoop:
	moveq	#0,d5						; Read byte
	move.b	(a2)+,d5
	
	cmpi.b	#$E0,d5						; Is it a command?
	bcs.s	.NotCommand					; If not, branch
	
	jsr	TrackCommand(pc)				; Run track command
	bra.s	.ParseLoop					; Read another byte

.NotCommand:
	tst.b	d5						; Is it a note?
	bpl.s	.Duration					; If not, branch
	
	jsr	GetFrequency(pc)				; Get frequency from note
	
	move.b	(a2)+,d5					; Read another byte
	bpl.s	.Duration					; If it's a duration, branch
	subq.w	#1,a2						; Otherwise, revert read
	bra.w	FinishTrackParse				; Finish up

.Duration:
	jsr	CalcDuration(pc)				; Calculate duration
	bra.w	FinishTrackParse				; Finish up

; ------------------------------------------------------------------------------
; Get frequency
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d5.b - Note ID
;	a3.l - Pointer to track variables
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

GetFrequency:
	subi.b	#$80,d5						; Subtract note value base
	beq.w	RestTrack					; If it's a rest note, branch

	lea	FrequencyTable(pc),a0				; Frequency table
	add.b	track.transpose(a3),d5				; Add transposition
	andi.w	#$7F,d5						; Get frequency
	lsl.w	#1,d5
	move.w	(a0,d5.w),track.frequency(a3)
	rts

; ------------------------------------------------------------------------------
; Finish up track parsing
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

FinishTrackParse:
	move.l	a2,track.data_addr(a3)				; Update track data pointer
	move.b	track.duration(a3),track.duration_timer(a3)	; Reset duration counter

	btst	#TRACK_LEGATO,(a3)				; Is legato enabled?
	bne.s	.End						; If so, branch

	jsr	SetKeyOff(pc)					; Set key off

	move.b	track.staccato(a3),track.staccato_timer(a3)	; Reset sample playback
	move.l	track.sample_start(a3),track.sample_addr(a3)
	move.l	track.sample_size(a3),track.samples_remain(a3)
	move.b	track.sample_staccato(a3),track.sample_stac_timer(a3)
	move.l	#PCM_WAVE_RAM,track.sample_ram_addr(a3)
	clr.w	track.prev_sample_pos(a3)
	clr.w	track.sample_ram_offset(a3)
	clr.b	track.sample_bank(a3)
	move.b	#7,track.sample_blocks(a3)

.End:
	rts

; ------------------------------------------------------------------------------
; Calculate note duration
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d5.b - Base note duration
;	a3.l - Pointer to track variables
; ------------------------------------------------------------------------------

CalcDuration:
	move.b	d5,d0						; Copy duration
	move.b	track.tick_multiply(a3),d1			; Get tick multiploer

.Multiply:
	subq.b	#1,d1						; Multiply duration by tick multiplier
	beq.s	.Done
	add.b	d5,d0
	bra.s	.Multiply

.Done:
	move.b	d0,track.duration(a3)				; Set duration
	move.b	d0,track.duration_timer(a3)			; Set duration counter
	rts

; ------------------------------------------------------------------------------
; Handle staccato
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

HandleStaccato:
	tst.b	track.staccato_timer(a3)			; Is staccato enabled?
	beq.s	.End						; If not, branch
	subq.b	#1,track.staccato_timer(a3)			; Decrement staccato counter
	bne.s	.End						; If it hasn't run out, branch
	
	jsr	RestTrack(pc)					; If it has, set track as rested
	; BUG: In the original SMPS 68k driver, the call path goes driver -> track -> staccato.
	; However, here, they put the staccato handler on the same call level as the track handler,
	; so instead of skipping to the next track, it just outright exits the driver. As a result,
	; the tracks after the current one don't get updated for the current frame, causing them
	; to desync by a frame.
	addq.w	#4,sp						; Supposed to skip right to the next track, but actually exits the driver

.End:
	rts

; ------------------------------------------------------------------------------
; Update frequency
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

UpdateFrequency:
	btst	#TRACK_REST,track.flags(a3)			; Is this track rested?
	bne.s	.End						; If so, branch

	move.w	track.frequency(a3),d5				; Get frequency
	move.b	track.detune(a3),d0				; Add detune
	ext.w	d0
	add.w	d0,d5

	move.w	d5,d1						; Set frequency
	move.b	track.channel(a3),d0
	ori.b	#$C0,d0
	move.b	d0,PCM_CTRL-PCM_REGS(a4)
	move.b	d1,PCM_FREQ_L-PCM_REGS(a4)
	lsr.w	#8,d1
	move.b	d1,PCM_FREQ_H-PCM_REGS(a4)
	rts

.End:
	addq.w	#4,sp						; Skip right to the next track
	rts

; ------------------------------------------------------------------------------
