; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"regions.inc"
	include	"variables.inc"

	section code
	
; ------------------------------------------------------------------------------
; Play a sound from the queue
; ------------------------------------------------------------------------------

	xdef PlaySoundId
PlaySoundId:
	ld	a,(z_sound_play)				; Get sound pulled from the queue
	bit	7,a						; Is it a sound ID?
	jp	z,StopSound					; If not, stop all sound
	
	cp	FM_END+1					; Is it a sound effect?
	jp	c,PlaySfx					; If so, branch
	
	jp	StopSound					; Stop all sound

; --------------------------------------------------------------------------------
; Initial track data
; --------------------------------------------------------------------------------

TrackInitData:
	db	80h, 0						; FM1
	db	80h, 1						; FM2
	db	80h, 2						; FM3
	db	80h, 4						; FM4
	db	80h, 5						; FM5
	db	80h, 6						; FM6

; ------------------------------------------------------------------------------
; Play a sound effect
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a - Sound ID
; ------------------------------------------------------------------------------

PlaySfx:
	sub	FM_START					; Make ID zero based
	ret	m						; If it's not a valid sound effect ID, exit

	ld	c,info.sfx_index				; Get sound effect pointer
	rst	8
	rst	18h

	push	hl						; Get instrument table pointer
	rst	20h
	ld	(instrument_table),hl
	xor	a						; Clear end flag
	ld	(end_flag),a
	pop	hl

	push	hl						; Get tick multiplier
	pop	iy
	ld	a,(iy+2)
	ld	(tick_multiply),a
	ld	de,4						; Skip past header
	add	hl,de
	ld	b,(iy+3)					; Get number of tracks

.InitTracks:
	push	bc						; Save track counter
	
	push	hl						; Get track variables pointer
	inc	hl
	ld	c,(hl)
	call	GetSfxTrack
	push	ix
	pop	de
	pop	hl

	ldi							; Copy flags
	ld	a,(de)						; Get channel ID
	cp	2						; Is it FM3?
	call	z,DisableSpecialFm3				; If so, disable special FM3 mode
	ldi							; Copy channel ID
	ld	a,(tick_multiply)				; Set tick multiplier
	ld	(de),a
	inc	de
	ldi							; Copy track data pointer
	ldi
	ldi							; Copy transposition value
	ldi							; Copy volume value

	call	FinishTrackInit					; Finish track initialization

	push	hl						; Set instrument table pointer
	ld	hl,(instrument_table)
	ld	(ix+track.instruments),l
	ld	(ix+track.instruments+1),h
	call	SetKeyOff					; Set key off
	call	DisableSsgEg					; Disable SSG-EG
	pop	hl
	
	pop	bc						; Loop until all tracks are initialized
	djnz	.InitTracks

ResetSoundQueue:
	ld	a,80h						; Clear sound play queue
	ld	(z_sound_play),a
	ret

; ------------------------------------------------------------------------------
; Get sound effect track variables pointer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Channel ID
; RETURNS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

GetSfxTrack:
	ld	a,c						; Get channel ID
	bit	2,a						; Is it a YM part 2 channel?
	jr	z,.GetPtr					; If not, branch
	dec	a						; Make ID linear

.GetPtr:
	ld	(channel_id),a					; Get track variables pointer
	push	af
	ld	hl,SfxTracks
	rst	18h
	push	hl
	pop	ix
	pop	af
	ret

; ------------------------------------------------------------------------------
; Finish track initialization
; ------------------------------------------------------------------------------
; PARAMETERS:
;	de - Pointer to track variables after volume
; RETURNS:
;	de - Advanced track variables pointer
; ------------------------------------------------------------------------------

FinishTrackInit:
	ex	af,af'
	xor	a						; Reset vibrato mode
	ld	(de),a
	inc	de
	ld	(de),a						; Reset instrument ID
	inc	de
	ex	af,af'

	ex	de,hl						; Set call stack pointer
	ld	(hl),track.call_stack_base
	inc	hl
	ld	(hl),0C0h					; Set panning/AMS/FMS
	inc	hl
	ld	(hl),1						; Set duration counter to 1

	ld	b,TRACK_CLEAR_SIZE				; Clear rest of the track

.ClearTrack:
	inc	hl
	ld	(hl),0
	djnz	.ClearTrack

	inc	hl
	ex	de,hl
	ret

; --------------------------------------------------------------------------------
; Sound effect track variables pointers
; --------------------------------------------------------------------------------

SfxTracks:
	dw	fm1_track					; FM1
	dw	fm2_track					; FM2
	dw	fm3_track					; FM3
	dw	fm4_track					; FM4
	dw	fm5_track					; FM5
	dw	fm6_track					; FM6

; ------------------------------------------------------------------------------
; Stop all sound
; ------------------------------------------------------------------------------

	xdef StopSound
StopSound:
	ld	hl,z_sound_play					; Clear driver variables
	ld	de,z_sound_play+1
	ld	bc,VARIABLES_CLEAR_SIZE-1
	ld	(hl),0
	ldir

	; BUG: SilenceTrack and DisableSsgEg expect ix to be a pointer
	; to a track's variables. TrackInitData also doesn't get properly used.
	; As a result, this function does not work properly.
	ld	ix,TrackInitData				; Initial track data
	ld	b,TRACK_COUNT					; Number of tracks

.StopTracks:
	push	bc						; Save track counter
	call	SilenceTrack					; Silence track
	call	DisableSsgEg					; Disable SSG-EG

	inc	ix						; Next track
	inc	ix
	pop	bc
	djnz	.StopTracks					; Loop until all tracks are stopped
	
	ld	b,7						; Reset fading
	xor	a
	ld	(fade_flag),a

; ------------------------------------------------------------------------------
; Disable special FM3 mode
; ------------------------------------------------------------------------------

DisableSpecialFm3:
	ld	a,0Fh						; Disable special FM3 mode
	ld	(ym_reg_27),a
	ld	c,a
	ld	a,27h
	call	WriteYm1
	
	jp	ResetSoundQueue					; Reset sound queue

; ------------------------------------------------------------------------------
; Disable SSG-EG
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

DisableSsgEg:
	ld	a,90h						; Disable SSG-EG
	ld	c,0
	jp	WriteYm4Op

; ------------------------------------------------------------------------------
; Process sound queue
; ------------------------------------------------------------------------------

	xdef ProcessSoundQueue
ProcessSoundQueue:
	ld	a,r						; Store value of the R register
	ld	(r_value),a

	ld	de,z_sound_queue				; Process sound queue 1
	call	.ProcessSlot
	call	.ProcessSlot					; Process sound queue 2
	; Fall through to process sound queue 3

; ------------------------------------------------------------------------------

.ProcessSlot:
	ld	a,(de)						; Read from queue
	bit	7,a						; Is a sound ID written in it?
	ret	z						; If not, exit
	sub	FM_START					; Is it a valid sound effect ID?
	ret	c						; If not, exit
	
	ld	c,info.sfx_priorities				; Get sound priority
	rst	8
	ld	c,a
	ld	b,0
	add	hl,bc

	ld	a,(cur_priority)				; Get current sound priority
	cp	(hl)						; Is this sound's priority greater?
	jr	z,.SetSound					; If so, branch
	jr	nc,.ClearSlot					; If not, branch

.SetSound:
	ld	a,(de)						; Override sound play queue
	ld	(z_sound_play),a
	ld	a,(hl)						; Set new priority
	and	7Fh
	ld	(cur_priority),a

.ClearSlot:
	xor	a						; Clear queue slot
	ld	(de),a
	inc	de						; Next queue slot
	ret

; ------------------------------------------------------------------------------
; Silence track
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef SilenceTrack
SilenceTrack:
	call	SetMaxReleaseRate				; Maximize release rate
	ld	a,40h						; Silence channel
	ld	c,7Fh
	call	WriteYm4Op

	ld	c,(ix+track.channel)				; Set key off
	jp	ForceKeyOff

; ------------------------------------------------------------------------------
; Maximize release rate
; ------------------------------------------------------------------------------
; PARAMETERS:
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

	xdef SetMaxReleaseRate
SetMaxReleaseRate:
	ld	a,80h						; Set max release rate
	ld	c,0FFh

; ------------------------------------------------------------------------------
; Write a value to all 4 operators for a register
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Base register ID
;	c  - Register data
;	ix - Pointer to track variables
; ------------------------------------------------------------------------------

WriteYm4Op:
	ld	b,4						; Number of operators

.Write:
	push	af						; Write operator register data
	call	WriteYmTrack
	pop	af
	add	a,4						; Next operator
	djnz	.Write						; Loop until operator registers are set
	ret

; ------------------------------------------------------------------------------
