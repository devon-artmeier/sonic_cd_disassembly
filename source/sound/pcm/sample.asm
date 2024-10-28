; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"regions.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Start streaming sample data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

	xdef StartStream
StartStream:
	tst.b	track.sample_mode(a3)				; Is this track streaming sample data?
	bne.s	.End						; If not, branch
	btst	#TRACK_REST,track.flags(a3)			; Is this track rested?
	bne.s	.End						; If so, branch
	bra.w	StreamSample					; Stream sample data

.End:
	rts

; ------------------------------------------------------------------------------
; Update sample
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

	xdef UpdateSample
UpdateSample:
	tst.b	track.sample_stac_timer(a3)			; Does this sample have staccato?
	beq.s	.CheckStream					; If not, branch
	subq.b	#1,track.sample_stac_timer(a3)			; Decrement staccato counter
	beq.w	RestTrack					; If it has run out, branch

.CheckStream:
	tst.b	track.sample_mode(a3)				; Is this track streaming sample data?
	bne.w	.End						; If not, branch
	btst	#TRACK_REST,track.flags(a3)			; Is this track rested?
	bne.w	.End						; If so, branch

	lea	PCM_ADDR-1,a0					; Get current sample playback position
	moveq	#0,d0
	moveq	#0,d1
	move.b	track.channel(a3),d1
	lsl.w	#2,d1
	move.l	(a0,d1.w),d0
	move.l	d0,d1
	lsl.w	#8,d0
	swap	d1
	move.b	d1,d0

	move.w	track.prev_sample_pos(a3),d1			; Has it looped back to the start of sample RAM?
	move.w	d0,track.prev_sample_pos(a3)
	cmp.w	d1,d0
	bcc.s	.CheckNewBlock					; If not, branch
	
	subi.w	#$1E00,track.sample_ram_offset(a3)		; If so, wrap back to start

.CheckNewBlock:
	andi.w	#$1FFF,d0					; Is it time to stream a new block of sample data?
	addi.w	#$1000,d0
	move.w	track.sample_ram_offset(a3),d1
	cmp.w	d1,d0
	bhi.s	StreamSample					; If so, branch

.End:
	rts

; ------------------------------------------------------------------------------
; Stream sample data
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a3.l - Pointer to track variables
;	a4.l - Pointer to PCM registers
; ------------------------------------------------------------------------------

StreamSample:
	addi.w	#$200,track.sample_ram_offset(a3)		; Advance sample RAM offset

	move.l	track.samples_remain(a3),d6			; Get number of bytes remaining in sample
	movea.l	track.sample_addr(a3),a2			; Get pointer to sample data
	movea.l	track.sample_ram_addr(a3),a0			; Get pointer to sample RAM

	move.b	track.channel(a3),d1				; Get up sample RAM bank to access
	lsl.b	#1,d1
	add.b	track.sample_bank(a3),d1
	ori.b	#$80,d1
	move.b	d1,PCM_CTRL-PCM_REGS(a4)

	move.l	#$200,d0					; $200 bytes per block
	move.l	d0,d1

.StreamLoop:
	cmp.l	d0,d6						; Is the remaining sample data less than the block size?
	bcc.s	.PrepareStream					; If not, branch
	move.l	d6,d0						; If so, only stream what's remaining

.PrepareStream:
	sub.l	d0,d6						; Subtract bytes to be streamed from remaining sample size
	sub.l	d0,d1						; Subtract bytes to be streamed from block size
	subq.l	#1,d0						; Subtract 1 for loop

.CopySampleData:
	move.b	(a2)+,(a0)+					; Copy sample data
	addq.w	#1,a0						; Skip over even addresses
	dbf	d0,.CopySampleData				; Loop until sample data is copied

	tst.l	d1						; Have we reached the end of the sample before the block was filled up?
	beq.s	.BlockDone					; If not, branch

	moveq	#0,d0						; Loop sample
	move.l	track.sample_size(a3),d0
	sub.l	track.sample_loop(a3),d0
	suba.l	d0,a2
	add.l	d0,d6
	move.l	d1,d0
	
	bra.s	.StreamLoop					; Start streaming more data

.BlockDone:
	tst.l	d6						; Are we at the end of the sample?
	bne.s	.NextBlock					; If not, branch

	moveq	#0,d0						; Loop sample
	move.l	track.sample_size(a3),d0
	sub.l	track.sample_loop(a3),d0
	suba.l	d0,a2
	move.l	d0,d6

.NextBlock:
	move.l	d6,track.samples_remain(a3)			; Update remaining sample size
	move.l	a2,track.sample_addr(a3)			; Update sample pointer

	subq.b	#1,track.sample_blocks(a3)			; Decrement blocks left in bank
	bmi.s	.NextBank					; If we have run out, branch
	
	move.l	a0,track.sample_ram_addr(a3)			; Update sample RAM pointer
	rts

.NextBank:
	move.l	#PCM_WAVE_RAM,track.sample_ram_addr(a3)		; Reset sample RAM pointer
	
	tst.b	track.sample_bank(a3)				; Were we in the second bank?
	bne.s	.Bank1						; If so, branch
	
	move.b	#7-1,track.sample_blocks(a3)			; Set number of blocks to stream in second bank
	move.b	#1,track.sample_bank(a3)			; Set to bank 2
	rts

.Bank1:
	move.b	#8-1,track.sample_blocks(a3)			; Set number of blocks to stream in first bank
	clr.b	track.sample_bank(a3)				; Set to bank 1
	rts

; ------------------------------------------------------------------------------
; Load samples
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a5.l - Pointer to driver variables
; ------------------------------------------------------------------------------

	xdef LoadSamples
LoadSamples:
	lea	SampleIndex(pc),a0				; Sample index
	move.l	(a0)+,d0					; Get number of samples
	beq.s	.End						; If there are none, branch
	bmi.s	.End						; If there are none, branch
	subq.w	#1,d0						; Subtract 1 for loop

.LoadSample:
	movea.l	(a0)+,a1					; Get sample data
	adda.l	pcm.ptr_offset(a5),a1
	tst.b	sample.mode(a1)					; Is this sample to be streamed?
	beq.s	.NextSample					; If so, branch

	movea.l	sample.address(a1),a2				; Get sample address
	adda.l	pcm.ptr_offset(a5),a2

	move.w	sample.dest_addr(a1),d1				; Get destination address in sample RAM
	move.w	d1,d5
	rol.w	#4,d1						; Get bank ID
	ori.b	#$80,d1
	andi.w	#$F00,d5					; Get offset within bank

	move.l	sample.size(a1),d2				; Get sample size
	move.w	d2,d3						; Get number of banks the sample takes up
	rol.w	#4,d3
	andi.w	#$F,d3

.LoadBankData:
	move.b	d1,PCM_CTRL-PCM_REGS(a4)			; Set sample RAM bank
	move.w	d2,d4						; Get remaining sample size
	cmpi.w	#$1000,d2					; Is it greater than the size of a bank
	bls.s	.CopyData					; If not, branch
	move.w	#$1000,d4					; If so, cap at the size of a bank

.CopyData:
	add.w	d5,d2						; Add bank offset to sample size (fake having written up to offset)
	sub.w	d5,d4						; Subtract bank offset from copy length
	subq.w	#1,d4						; Subtract 1 for loop

	lea	PCM_WAVE_RAM,a3					; Sample RAM
	adda.w	d5,a3						; Add bank offset
	adda.w	d5,a3

.CopyDataLoop:
	move.b	(a2)+,(a3)+					; Copy sample data
	addq.w	#1,a3						; Skip even addresses
	dbf	d4,.CopyDataLoop				; Loop until sample data is loaded into the bank

	subi.w	#$1000,d2					; Subtract bank size from sample size
	addq.b	#1,d1						; Next bank
	moveq	#0,d5						; Set bank offset to 0
	dbf	d3,.LoadBankData				; Loop until finished

.NextSample:
	dbf	d0,.LoadSample					; Loop until finished

.End:
	rts

; ------------------------------------------------------------------------------
