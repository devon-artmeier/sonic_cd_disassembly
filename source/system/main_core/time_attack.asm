; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------
; Time Attack
; ------------------------------------------------------------------------------

	xdef TimeAttack
TimeAttack:
	moveq	#SYS_TIME_ATTACK,d0				; Run time attack menu file
	bsr.w	RunMmd
	
	move.w	d0,time_attack_stage				; Set stage
	beq.w	.End						; If we are exiting, branch

	move.b	.Selections(pc,d0.w),d0				; Get stage selection ID
	bmi.s	TimeAttackSpecialStage				; If we are entering a special stage, branch

	mulu.w	#6,d0						; Get selected stage data
	lea	StageSelections(pc),a6
	move.w	2(a6,d0.w),zone_act				; Set stage
	move.b	4(a6,d0.w),time_zone				; Time zone
	move.b	5(a6,d0.w),good_future				; Good future flag
	move.w	(a6,d0.w),d0					; File load command
	
	move.b	#1,time_attack_mode				; Set time attack mode flag
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bsr.w	RunMmd						; Run stage file
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.l	time,time_attack_time				; Save time attack time
	
	bra.s	TimeAttack					; Loop back to menu

.End:
	rts

; ------------------------------------------------------------------------------

.Selections:
	dc.b	SELECT_ROUND_11A

	dc.b	SELECT_ROUND_11A
	dc.b	SELECT_ROUND_12A
	dc.b	SELECT_ROUND_13D
	
	dc.b	SELECT_ROUND_31A
	dc.b	SELECT_ROUND_32A
	dc.b	SELECT_ROUND_33D
	
	dc.b	SELECT_ROUND_41A
	dc.b	SELECT_ROUND_42A
	dc.b	SELECT_ROUND_43D
	
	dc.b	SELECT_ROUND_51A
	dc.b	SELECT_ROUND_52A
	dc.b	SELECT_ROUND_53D
	
	dc.b	SELECT_ROUND_61A
	dc.b	SELECT_ROUND_62A
	dc.b	SELECT_ROUND_63D
	
	dc.b	SELECT_ROUND_71A
	dc.b	SELECT_ROUND_72A
	dc.b	SELECT_ROUND_73D
	
	dc.b	SELECT_ROUND_81A
	dc.b	SELECT_ROUND_82A
	dc.b	SELECT_ROUND_83D

	dc.b	-1
	dc.b	-2
	dc.b	-3
	dc.b	-4
	dc.b	-5
	dc.b	-6
	dc.b	-7
	even

; ------------------------------------------------------------------------------

TimeAttackSpecialStage:
	neg.b	d0						; Set special stage ID
	ext.w	d0
	subq.w	#1,d0
	move.b	d0,special_stage_id_cmd
	
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#1,special_stage_flags				; Time attack mode

	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	
	bra.w	TimeAttack					; Loop back to menu

; ------------------------------------------------------------------------------
