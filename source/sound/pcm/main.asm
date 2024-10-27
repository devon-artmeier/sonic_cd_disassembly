; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Driver origin point
; ------------------------------------------------------------------------------

	xdef PcmDriverOrigin	
PcmDriverOrigin:

; ------------------------------------------------------------------------------
; Driver update entry point
; ------------------------------------------------------------------------------

	xdef RunPcmDriver
RunPcmDriver:
	jmp	UpdateDriver(pc)

; ------------------------------------------------------------------------------
; Driver initialization entry point
; ------------------------------------------------------------------------------

	xdef InitPcmDriver
InitPcmDriver:
	jmp	InitDriver(pc)

; ------------------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------------------

	xdef PcmVariables
PcmVariables:
	dcb.b	pcm.struct_size, 0

; ------------------------------------------------------------------------------
; Update driver
; ------------------------------------------------------------------------------

UpdateDriver:
	jsr	GetPointers(pc)					; Get driver pointers
	;if BOSS<>0
	;	addq.b	#1,pcm.unk_counter(a5)			; Increment unknown counter
	;endif
	jsr	ProcessSoundQueue(pc)				; Process sound queue
	jsr	PlaySoundId(pc)					; Play sound from queue
	jsr	HandlePause(pc)					; Handle pausing
	jsr	HandleTempo(pc)					; Handle tempo
	jsr	HandleFadeOut(pc)				; Handle fading out
	jsr	UpdateTracks(pc)				; Update tracks
	move.b	pcm.on(a5),PCM_ON_OFF-PCM_REGS(a4)		; Update channels on/off array
	rts

; ------------------------------------------------------------------------------
