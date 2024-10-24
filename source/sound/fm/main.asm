; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"z80.inc"
	include	"variables.inc"
	
; ------------------------------------------------------------------------------
; Driver entry point
; ------------------------------------------------------------------------------

	section code_rst_00
DriverStart:
	di							; Disable interrupts
	di
	im	1						; Interrupt mode 1
	
	jr	InitDriver					; Initialize driver

; ------------------------------------------------------------------------------
; Get list from driver info table
; ------------------------------------------------------------------------------
; PARAMETERS:
;	c  - Table index
; RETURNS:
;	hl - Pointer to list
; ------------------------------------------------------------------------------

	section code_rst_08
GetList:
	ld	hl,DriverInfo					; Get pointer to entry
	ld	b,0
	add	hl,bc
	ex	af,af'						; Read pointer
	rst	20h
	ex	af,af'
	ret
	
; ------------------------------------------------------------------------------
; Read pointer from table
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a  - Table index
;	hl - Pointer to table
; ------------------------------------------------------------------------------

	section code_rst_18_20
ReadTablePointer:
	ld	c,a						; Get pointer to entry
	ld	b,0
	add	hl,bc
	add	hl,bc
	nop
	nop
	nop

; ------------------------------------------------------------------------------
; Read pointer from HL register
; ------------------------------------------------------------------------------
; PARAMETERS:
;	hl - Pointer to read
; RETURNS:
;	hl - Read pointer
; ------------------------------------------------------------------------------

ReadHlPointer:
	ld	a,(hl)						; Read from HL into HL
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret
	
; ------------------------------------------------------------------------------
; Initialize driver
; ------------------------------------------------------------------------------

	section code
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
