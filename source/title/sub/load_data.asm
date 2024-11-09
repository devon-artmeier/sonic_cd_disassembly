; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_sub.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Decompress Kosinski data into RAM
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Kosinski data pointer
;	a1.l - Destination buffer pointer
; ------------------------------------------------------------------------------

	xdef DecompressKosinski
DecompressKosinski:
	subq.l	#2,sp						; Allocate 2 bytes on the stack
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

GetKosinskiCode:
	lsr.w	#1,d5						; Should we just copy a new byte?
	move	sr,d6
	dbf	d4,.NoNewDesc					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc:
	move	d6,ccr
	bcc.s	CopyKosinskiBack				; If not, branch

	move.b	(a0)+,(a1)+					; Copy new byte
	bra.s	GetKosinskiCode					; Get next code

; ------------------------------------------------------------------------------

CopyKosinskiBack:
	moveq	#0,d3						; Reset copy length
	
	lsr.w	#1,d5						; Should we read a larger copy length value?
	move	sr,d6
	dbf	d4,.NoNewDesc					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc:
	move	d6,ccr			
	bcs.s	LargeKosinskiCopy				; If so, branch

	lsr.w	#1,d5						; Get copy length bit 1
	dbf	d4,.NoNewDesc2					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc2:
	roxl.w	#1,d3						; Get copy length bit 0
	lsr.w	#1,d5
	dbf	d4,.NoNewDesc3					; Loop until we need a new descriptor field
	move.b	(a0)+,1(sp)					; Read descriptor field
	move.b	(a0)+,(sp)
	move.w	(sp),d5
	moveq	#16-1,d4					; Reset bit counter

.NoNewDesc3:
	roxl.w	#1,d3
	addq.w	#1,d3

	moveq	#$FFFFFFFF,d2					; Get copy offset
	move.b	(a0)+,d2

	bra.s	CopyKosinskiBackLoop				; Start copying

; ------------------------------------------------------------------------------

LargeKosinskiCopy:
	move.b	(a0)+,d0					; Read 2 bytes
	move.b	(a0)+,d1
	
	moveq	#$FFFFFFFF,d2					; Get copy offset
	move.b	d1,d2
	lsl.w	#5,d2
	move.b	d0,d2

	andi.w	#7,d1						; Get 3-bit copy length
	beq.s	LargeKosinskiCopy8				; If we need an 8-bit copy length, branch
	
	move.b	d1,d3						;; Start copying
	addq.w	#1,d3

; ------------------------------------------------------------------------------

CopyKosinskiBackLoop:
	move.b	(a1,d2.w),d0					; Copy byte
	move.b	d0,(a1)+
	dbf	d3,CopyKosinskiBackLoop				; Loop until finished
	
	bra.s	GetKosinskiCode					; Get next code

; ------------------------------------------------------------------------------

LargeKosinskiCopy8:
	move.b	(a0)+,d1					; Get copy length
	beq.s	KosinskiDone					; If we are done, branch

	cmpi.b	#1,d1						; Should we get a new code?
	beq.w	GetKosinskiCode					; If so, branch

	move.b	d1,d3						; Start copying
	bra.s	CopyKosinskiBackLoop

; ------------------------------------------------------------------------------

KosinskiDone:
	addq.l	#2,sp						; Deallocate the 2 bytes
	rts

; ------------------------------------------------------------------------------
; Load clouds data
; ------------------------------------------------------------------------------

	xdef LoadCloudData
LoadCloudData:
	lea	CloudStamps(pc),a0				; Load stamp art
	lea	WORD_RAM_2M+$200,a1
	bsr.w	DecompressKosinski
	
	lea	CloudStampMap(pc),a0				; Load stamp map
	lea	WORD_RAM_2M+CLOUD_STAMP_MAP,a1
	bsr.w	DecompressKosinski
	rts

; ------------------------------------------------------------------------------
