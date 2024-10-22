; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"
	
	section code
	
; ------------------------------------------------------------------------------
; Initialize driver
; ------------------------------------------------------------------------------

	xdef InitDriver
InitDriver:
	ld	sp,stack_base					; Set stack pointer
	
	ld	c,0						; Delay with a 65536 times loop

.Delay:
	ld	b,0
	
.DelayLoop:
	djnz	.DelayLoop
	dec	c
	jr	nz,.Delay
	
	call	StopSound					; Stop all sound

.Loop:
	call	ProcessSoundQueue				; Process sound queue
	
	ld	a,(YM_ADDR_0)					; Has timer B run out?
	bit	1,a
	jr	z,.Loop						; If not, wait
	call	ResetTimerB					; Reset timer B
	
	call	UpdateTracks					; Update tracks
	jr	.Loop						; Loop

; ------------------------------------------------------------------------------
; Reset timer B
; ------------------------------------------------------------------------------

	xdef ResetTimerB
ResetTimerB:
	ld	c,0C8h						; Set timer B frequency
	ld	a,26h
	call	WriteYm1
	
	ld	a,2Fh						; Start timer B up again
	ld	hl,ym_reg_27
	or	(hl)
	ld	c,a
	ld	a,27h
	call	WriteYm1
	ret
	
; ------------------------------------------------------------------------------
