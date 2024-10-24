; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"

	section code

; ------------------------------------------------------------------------------

	mmd 0, WORK_RAM, $1000, Start, 0, 0

; ------------------------------------------------------------------------------
; Program start
; ------------------------------------------------------------------------------

Start:
	move.l	#VBlankIrq,_LEVEL6+2				; Set V-BLANK interrupt address
	bsr.w	GiveWordRamAccess				; Give Sub CPU Word RAM Access
	
	lea	game_variables,a0				; Clear game variables
	move.w	#GAME_VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables
	ifne GAME_VARIABLES_SIZE&2
		clr.w	(a0)+
	endif
	ifne GAME_VARIABLES_SIZE&1
		clr.b	(a0)+
	endif

	moveq	#SYS_MD_INIT,d0					; Run Mega Drive initialization
	bsr.w	RunMmd
	
	move.w	#SYS_BURAM_INIT,d0				; Run Backup RAM initialization
	bsr.w	RunMmd
	
	tst.b	d0						; Was it a succes?
	beq.s	.GetSaveData					; If so, branch
	bset	#0,save_disabled				; If not, disable saving to Backup RAM

.GetSaveData:
	bsr.w	ReadSaveData					; Read save data

; ------------------------------------------------------------------------------

.GameLoop:
	move.w	#SYS_SPECIAL_INIT,d0				; Initialize special stage flags
	bsr.w	SubCpuCommand

	moveq	#0,d0
	move.l	d0,score					; Reset score
	move.b	d0,time_attack_mode				; Reset time attack mode flag
	move.b	d0,special_stage				; Reset special stage flag
	move.b	d0,checkpoint					; Reset checkpoint
	move.w	d0,rings					; Reset ring count
	move.l	d0,time						; Reset time
	move.b	d0,good_future					; Reset good future flag
	move.b	d0,projector_destroyed				; Reset projector destroyed flag
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present

	moveq	#SYS_TITLE,d0					; Run title screen
	bsr.w	RunMmd

	ext.w	d1						; Run next scene
	add.w	d1,d1
	move.w	.Scenes(pc,d1.w),d1
	jsr	.Scenes(pc,d1.w)

	bra.s	.GameLoop					; Loop

; ------------------------------------------------------------------------------

.Scenes:
	dc.w	Demo-.Scenes					; Demo mode
	dc.w	NewGame-.Scenes					; New game
	dc.w	LoadGame-.Scenes				; Load game
	dc.w	TimeAttack-.Scenes				; Time attack
	dc.w	BuramManager-.Scenes				; Backup RAM manager
	dc.w	DaGarden-.Scenes				; D.A. Garden
	dc.w	VisualMode-.Scenes				; Visual mode
	dc.w	SoundTest-.Scenes				; Sound test
	dc.w	StageSelect-.Scenes				; Stage select
	dc.w	BestStaffTimes-.Scenes				; Best staff times

; ------------------------------------------------------------------------------
; Best staff times
; ------------------------------------------------------------------------------

BestStaffTimes:
	move.w	#SYS_STAFF_TIMES,d0				; Run staff best times screen
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Backup RAM manager
; ------------------------------------------------------------------------------

BuramManager:
	move.w	#SYS_BURAM_MANAGER,d0				; Run Backup RAM manager
	bsr.w	RunMmd
	bsr.w	ReadSaveData					; Read save data
	rts
	
; ------------------------------------------------------------------------------
; Run Special Stage 1 demo
; ------------------------------------------------------------------------------

SpecialStage1Demo:
	move.b	#1-1,special_stage_id_cmd			; Stage 1
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#0,special_stage_flags				; Temporary mode
	
	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	rts

; ------------------------------------------------------------------------------
; Run Special Stage 6 demo
; ------------------------------------------------------------------------------

SpecialStage6Demo:
	move.b	#6-1,special_stage_id_cmd			; Stage 6
	move.b	#0,time_stones_cmd				; Reset time stones retrieved for this stage
	bset	#0,special_stage_flags				; Temporary mode
	
	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	rts

; ------------------------------------------------------------------------------
; Load game

LoadGame:
	bsr.w	ReadSaveData					; Read save data
	
	move.w	saved_stage,zone_act				; Get level from save data
	move.b	#3,lives					; Reset life count to 3
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags

	cmpi.b	#0,zone						; Are we in Palmtree Panic?
	beq.w	RunRound1					; If so, branch
	cmpi.b	#1,zone						; Are we in Collision Chaos?
	bls.w	RunRound3					; If so, branch
	cmpi.b	#2,zone						; Are we in Tidal Tempest?
	bls.w	RunRound4					; If so, branch
	cmpi.b	#3,zone						; Are we in Quartz Quadrant?
	bls.w	RunRound5					; If so, branch
	cmpi.b	#4,zone						; Are we in Wacky Workbench?
	bls.w	RunRound6					; If so, branch
	cmpi.b	#5,zone						; Are we in Stardust Speedway?
	bls.w	RunRound7					; If so, branch
	cmpi.b	#6,zone						; Are we in Metallic Madness?
	bls.w	RunRound8					; If so, branch

; ------------------------------------------------------------------------------
; New game
; ------------------------------------------------------------------------------

NewGame:
RunRound1:
	moveq	#0,d0
	move.b	d0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	d0,zone						; Set stage to Palmtree Panic Act 1
	move.w	d0,saved_stage
	move.b	d0,good_future_zones				; Reset good futures achieved
	move.b	d0,current_special_stage			; Reset special stage ID
	move.b	d0,time_stones					; Reset time stones retrieved

	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound11					; Run act 1
	bsr.w	RunRound12					; Run act 2
	bsr.w	RunRound13					; Run act 3

	moveq	#3*1,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	bset	#6,title_flags
	bset	#5,title_flags
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound3					; If not, branch
	bset	#0,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound3:
	bsr.w	WriteSaveData					; Write save data
	
	move.b	#0,amy_captured					; Reset Amy captured flag
	bsr.w	RunRound31					; Run act 1
	move.b	#0,amy_captured					; Reset Amy captured flag
	bsr.w	RunRound32					; Run act 2
	bsr.w	RunRound33					; Run act 3

	moveq	#3*2,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound4					; If not, branch
	bset	#1,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound4:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound41					; Run act 1
	bsr.w	RunRound42					; Run act 2
	bsr.w	RunRound43					; Run act 3

	moveq	#3*3,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound5					; If not, branch
	bset	#2,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound5:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound51					; Run act 1
	bsr.w	RunRound52					; Run act 2
	bsr.w	RunRound53					; Run act 3

	moveq	#3*4,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound6					; If not, branch
	bset	#3,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound6:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound61					; Run act 1
	bsr.w	RunRound62					; Run act 2
	bsr.w	RunRound63					; Run act 3

	moveq	#3*5,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound7					; If not, branch
	bset	#4,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound7:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound71					; Run act 1
	bsr.w	RunRound72					; Run act 2
	bsr.w	RunRound73					; Run act 3

	moveq	#3*6,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	RunRound8					; If not, branch
	bset	#5,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

RunRound8:
	bsr.w	WriteSaveData					; Write save data
	
	bsr.w	RunRound81					; Run act 1
	bsr.w	RunRound82					; Run act 2
	bsr.w	RunRound83					; Run act 3

	moveq	#3*7,d0						; Unlock zone in time attack
	bsr.w	UnlockTimeAttackStage
	
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	
	bclr	#0,good_future					; Was act 3 in the good future?
	beq.s	GameDone					; If not, branch
	bset	#6,good_future_zones				; Mark good future as achieved

; ------------------------------------------------------------------------------

GameDone:
	move.b	good_future_zones,good_future_zones_result	; Save good futures achieved
	move.b	time_stones,time_stones_result			; Save time stones retrieved

	bsr.w	WriteSaveData					; Write save data
	
	cmpi.b	#%01111111,good_future_zones_result		; Were all of the good futures achievd?
	beq.s	GoodEnding					; If so, branch
	cmpi.b	#%01111111,time_stones_result			; Were all of the time stones retrieved?
	beq.s	GoodEnding					; If so, branch

BadEnding:
	move.b	#0,ending_id					; Set ending ID to bad ending
	
	move.w	#SYS_BAD_END,d0					; Run bad ending file
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	BadEnding					; If so, loop
	rts

GoodEnding:
	move.b	#$7F,ending_id					; Set ending ID to good ending
	
	move.w	#SYS_GOOD_END,d0				; Run good ending file
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	GoodEnding					; If so, loop
	rts

; ------------------------------------------------------------------------------
; Game over
; ------------------------------------------------------------------------------

GameOver:
	move.b	#0,act						; Reset act
	move.w	zone_act,saved_stage				; Save zone and act ID
	move.b	#0,checkpoint					; Reset checkpoint
	move.b	#0,projector_destroyed				; Reset projector destroyed flag
	bclr	#0,good_future					; Reset good future flag
	rts

; ------------------------------------------------------------------------------
; Final game results data
; ------------------------------------------------------------------------------

good_future_zones_result:	
	dc.b	0						; Good futures achieved
time_stones_result:
	dc.b	0						; Time stones retrieved

; ------------------------------------------------------------------------------
; Run Palmtree Panic Act 1
; ------------------------------------------------------------------------------

RunRound11:
	lea	Round11Commands(pc),a0				; Run stage
	move.w	#$000,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Palmtree Panic Act 2
; ------------------------------------------------------------------------------

RunRound12:
	lea	Round12Commands(pc),a0				; Run stage
	move.w	#$001,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Palmtree Panic Act 3
; ------------------------------------------------------------------------------

RunRound13:
	lea	Round13Commands(pc),a0				; Run stage
	move.w	#$002,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Collision Chaos Act 1
; ------------------------------------------------------------------------------

RunRound31:
	lea	Round31Commands(pc),a0				; Run stage
	move.w	#$100,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Collision Chaos Act 2
; ------------------------------------------------------------------------------

RunRound32:
	lea	Round32Commands(pc),a0				; Run stage
	move.w	#$101,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Collision Chaos Act 3
; ------------------------------------------------------------------------------

RunRound33:
	lea	Round33Commands(pc),a0				; Run stage
	move.w	#$102,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Tidal Tempest Act 1
; ------------------------------------------------------------------------------

RunRound41:
	lea	Round41Commands(pc),a0				; Run stage
	move.w	#$200,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Tidal Tempest Act 2
; ------------------------------------------------------------------------------

RunRound42:
	lea	Round42Commands(pc),a0				; Run stage
	move.w	#$201,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Tidal Tempest Act 3
; ------------------------------------------------------------------------------

RunRound43:
	lea	Round43Commands(pc),a0				; Run stage
	move.w	#$202,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Quartz Quadrant Act 1
; ------------------------------------------------------------------------------

RunRound51:
	lea	Round51Commands(pc),a0				; Run stage
	move.w	#$300,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Quartz Quadrant Act 2
; ------------------------------------------------------------------------------

RunRound52:
	lea	Round52Commands(pc),a0				; Run stage
	move.w	#$301,zone_act
	bra.w	RunStage

; ------------------------------------------------------------------------------
; Run Quartz Quadrant Act 3
; ------------------------------------------------------------------------------

RunRound53:
	lea	Round53Commands(pc),a0				; Run stage
	move.w	#$302,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Wacky Workbench Act 1
; ------------------------------------------------------------------------------

RunRound61:
	lea	Round61Commands(pc),a0				; Run stage
	move.w	#$400,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Wacky Workbench Act 2
; ------------------------------------------------------------------------------

RunRound62:
	lea	Round62Commands(pc),a0				; Run stage
	move.w	#$401,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Wacky Workbench Act 3
; ------------------------------------------------------------------------------

RunRound63:
	lea	Round63Commands(pc),a0				; Run stage
	move.w	#$402,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Stardust Speedway Act 1
; ------------------------------------------------------------------------------

RunRound71:
	lea	Round71Commands(pc),a0				; Run stage
	move.w	#$500,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Stardust Speedway Act 2
; ------------------------------------------------------------------------------

RunRound72:
	lea	Round72Commands(pc),a0				; Run stage
	move.w	#$501,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Stardust Speedway Act 3
; ------------------------------------------------------------------------------

RunRound73:
	lea	Round73Commands(pc),a0				; Run stage
	move.w	#$502,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run Metallic Madness Act 1
; ------------------------------------------------------------------------------

RunRound81:
	lea	Round81Commands(pc),a0				; Run stage
	move.w	#$600,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Metallic Madness Act 2
; ------------------------------------------------------------------------------

RunRound82:
	lea	Round82Commands(pc),a0				; Run stage
	move.w	#$601,zone_act
	bra.s	RunStage

; ------------------------------------------------------------------------------
; Run Metallic Madness Act 3
; ------------------------------------------------------------------------------

RunRound83:
	lea	Round83Commands(pc),a0				; Run stage
	move.w	#$602,zone_act
	bra.w	RunBossStage

; ------------------------------------------------------------------------------
; Run stage
; ------------------------------------------------------------------------------

RunStage:
	moveq	#0,d0						; Get present file load command
	move.b	0(a0),d0

.StageLoop:
	bsr.w	RunMmd						; Run stage file

	tst.b	lives						; Have we run out of lives?
	beq.s	.StageOver					; If so, branch
	btst	#7,time_zone					; Are we time warping?
	beq.s	.StageOver					; If not, branch

	moveq	#SYS_WARP,d0					; Run warp sequence file
	bsr.w	RunMmd

	move.b	time_zone,d1					; Get new time zone

	moveq	#0,d0						; Get past file load command
	move.b	1(a0),d0
	andi.b	#$7F,d1						; Are we in the past?
	beq.s	.StageLoop					; If so, branch

	move.b	0(a0),d0					; Get present file load command
	subq.b	#1,d1						; Are we in the present?
	beq.s	.StageLoop					; If so, branch

	move.b	3(a0),d0					; Get bad future file load command
	tst.b	good_future					; Are we in the good future?
	beq.s	.StageLoop					; If not, branch
	
	move.b	2(a0),d0					; Get good future file load command
	bra.s	.StageLoop					; Loop

.StageOver:
	tst.b	lives						; Do we still have lives left?
	bne.s	.CheckSpecialStage				; If so, branch
	move.l	(sp)+,d0					; If not, exit
	bra.w	GameOver

.CheckSpecialStage:
	tst.b	special_stage					; Are we going into a special stage?
	bne.s	.SpecialStage					; If so, branch
	rts

.SpecialStage:
	move.b	current_special_stage,special_stage_id_cmd	; Set stage ID
	move.b	time_stones,time_stones_cmd			; Copy time stones retrieved flags
	bclr	#0,special_stage_flags				; Normal mode

	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd

	move.b	#1,palette_clear_flags				; Fade from white in next stage
	cmpi.b	#%01111111,time_stones				; Do we have all of the time stones now?
	bne.s	.End						; If not, branch
	move.b	#1,good_future					; If so, set good future flag

.End:
	rts

; ------------------------------------------------------------------------------
; Run boss stage
; ------------------------------------------------------------------------------

RunBossStage:
	moveq	#0,d0						; Get good future file load command
	move.b	0(a0),d0
	tst.b	good_future					; Are we in the good future?
	bne.s	.RunStage					; If so, branch
	move.b	1(a0),d0					; Get bad future file load command
	
.RunStage:
	bsr.w	RunMmd						; Run stage file

	tst.b	lives						; Do we still have lives left?
	bne.s	.NextStage					; If so, branch
	move.l	(sp)+,d0					; If not, exit
	bra.w	GameOver

.NextStage:
	addq.b	#1,saved_stage					; Next stage
	cmpi.b	#7,saved_stage					; Are we at the end of the game?
	bcs.s	.End						; If not, branch
	subq.b	#1,saved_stage					; Cap stage ID

.End:
	move.b	#0,checkpoint					; Reset checkpoint
	rts

; ------------------------------------------------------------------------------
; Unlock time attack zone
; ------------------------------------------------------------------------------
; PARAMETERS
;	d0.b - Stage ID
; ------------------------------------------------------------------------------

UnlockTimeAttackStage:
	cmp.b	time_attack_unlock,d0				; Is this stage already unlocked?
	bls.s	.End						; If so, branch
	move.b	d0,time_attack_unlock				; If not, unlock it

.End:
	rts

; ------------------------------------------------------------------------------
; Stage loading Sub CPU commands
; ------------------------------------------------------------------------------

; Palmtree Panic
Round11Commands:
	dc.b	SYS_ROUND_11A, SYS_ROUND_11B, SYS_ROUND_11C, SYS_ROUND_11D
Round12Commands:
	dc.b	SYS_ROUND_12A, SYS_ROUND_12B, SYS_ROUND_12C, SYS_ROUND_12D
Round13Commands:
	dc.b	SYS_ROUND_13C, SYS_ROUND_13D

; Collision Chaos
Round31Commands:
	dc.b	SYS_ROUND_31A, SYS_ROUND_31B, SYS_ROUND_31C, SYS_ROUND_31D
Round32Commands:
	dc.b	SYS_ROUND_32A, SYS_ROUND_32B, SYS_ROUND_32C, SYS_ROUND_32D
Round33Commands:
	dc.b	SYS_ROUND_33C, SYS_ROUND_33D

; Tidal Tempest
Round41Commands:
	dc.b	SYS_ROUND_41A, SYS_ROUND_41B, SYS_ROUND_41C, SYS_ROUND_41D
Round42Commands:
	dc.b	SYS_ROUND_42A, SYS_ROUND_42B, SYS_ROUND_42C, SYS_ROUND_42D
Round43Commands:
	dc.b	SYS_ROUND_43C, SYS_ROUND_43D

; Quartz Quadrant
Round51Commands:
	dc.b	SYS_ROUND_51A, SYS_ROUND_51B, SYS_ROUND_51C, SYS_ROUND_51D
Round52Commands:
	dc.b	SYS_ROUND_52A, SYS_ROUND_52B, SYS_ROUND_52C, SYS_ROUND_52D
Round53Commands:
	dc.b	SYS_ROUND_53C, SYS_ROUND_53D

; Wacky Workbench
Round61Commands:
	dc.b	SYS_ROUND_61A, SYS_ROUND_61B, SYS_ROUND_61C, SYS_ROUND_61D
Round62Commands:
	dc.b	SYS_ROUND_62A, SYS_ROUND_62B, SYS_ROUND_62C, SYS_ROUND_62D
Round63Commands:
	dc.b	SYS_ROUND_63C, SYS_ROUND_63D

; Stardust Speedway
Round71Commands:
	dc.b	SYS_ROUND_71A, SYS_ROUND_71B, SYS_ROUND_71C, SYS_ROUND_71D
Round72Commands:
	dc.b	SYS_ROUND_72A, SYS_ROUND_72B, SYS_ROUND_72C, SYS_ROUND_72D
Round73Commands:
	dc.b	SYS_ROUND_73C, SYS_ROUND_73D

; Metallic Madness
Round81Commands:
	dc.b	SYS_ROUND_81A, SYS_ROUND_81B, SYS_ROUND_81C, SYS_ROUND_81D
Round82Commands:
	dc.b	SYS_ROUND_82A, SYS_ROUND_82B, SYS_ROUND_82C, SYS_ROUND_82D
Round83Commands:
	dc.b	SYS_ROUND_83C, SYS_ROUND_83D

; ------------------------------------------------------------------------------
; Stage selection entry
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command ID
;	\3 - Stage ID
;	\4 - Time zone
;	\5 - Good Future flag
; ------------------------------------------------------------------------------

__stage_select_id set 0
selectEntry macro
	dc.w	\2, \3
	dc.b	\4, \5
	\1:			equ __stage_select_id
	__stage_select_id:	set __stage_select_id+1
	endm

; ------------------------------------------------------------------------------
; Stage select
; ------------------------------------------------------------------------------

StageSelect:
	moveq	#SYS_STAGE_SELECT,d0				; Run stage select file
	bsr.w	RunMmd

	mulu.w	#6,d0						; Get selected stage data
	move.w	StageSelections+2(pc,d0.w),zone_act		; Set stage
	move.b	StageSelections+4(pc,d0.w),time_zone		; Time zone
	move.b	StageSelections+5(pc,d0.w),good_future		; Good future flag
	move.w	StageSelections(pc,d0.w),d0			; File load command
	
	move.b	#0,projector_destroyed				; Reset projector destroyed flag

	cmpi.w	#SYS_SPECIAL_STAGE,d0				; Have we selected the special stage?
	beq.w	SpecialStage1Demo				; If so, branch
	
	bsr.w	RunMmd						; Run stage file
	rts

; ------------------------------------------------------------------------------

StageSelections:
	selectEntry SELECT_ROUND_11A,     SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_11B,     SYS_ROUND_11B,      $000, TIME_PAST,    0
	selectEntry SELECT_ROUND_11C,     SYS_ROUND_11C,      $000, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_11D,     SYS_ROUND_11D,      $000, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_12A,     SYS_ROUND_12A,      $001, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_12B,     SYS_ROUND_12B,      $001, TIME_PAST,    0
	selectEntry SELECT_ROUND_12C,     SYS_ROUND_12C,      $001, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_12D,     SYS_ROUND_12D,      $001, TIME_FUTURE,  0
	selectEntry SELECT_WARP,          SYS_WARP,           $000, TIME_PAST,    0
	selectEntry SELECT_OPENING,       SYS_OPENING,        $000, TIME_PAST,    0
	selectEntry SELECT_COMIN_SOON,    SYS_COMIN_SOON,     $000, TIME_PAST,    0
	selectEntry SELECT_ROUND_31A,     SYS_ROUND_31A,      $100, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_31B,     SYS_ROUND_31B,      $100, TIME_PAST,    0
	selectEntry SELECT_ROUND_31C,     SYS_ROUND_31C,      $100, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_31D,     SYS_ROUND_31D,      $100, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_32A,     SYS_ROUND_32A,      $101, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_32B,     SYS_ROUND_32B,      $101, TIME_PAST,    0
	selectEntry SELECT_ROUND_32C,     SYS_ROUND_32C,      $101, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_32D,     SYS_ROUND_32D,      $101, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_33C,     SYS_ROUND_33C,      $102, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_33D,     SYS_ROUND_33D,      $102, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_13C,     SYS_ROUND_13C,      $002, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_13D,     SYS_ROUND_13D,      $002, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_41A,     SYS_ROUND_41A,      $200, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_41B,     SYS_ROUND_41B,      $200, TIME_PAST,    0
	selectEntry SELECT_ROUND_41C,     SYS_ROUND_41C,      $200, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_41D,     SYS_ROUND_41D,      $200, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_42A,     SYS_ROUND_42A,      $201, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_42B,     SYS_ROUND_42B,      $201, TIME_PAST,    0
	selectEntry SELECT_ROUND_42C,     SYS_ROUND_42C,      $201, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_42D,     SYS_ROUND_42D,      $201, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_43C,     SYS_ROUND_43C,      $202, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_43D,     SYS_ROUND_43D,      $202, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_51A,     SYS_ROUND_51A,      $300, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_51B,     SYS_ROUND_51B,      $300, TIME_PAST,    0
	selectEntry SELECT_ROUND_51C,     SYS_ROUND_51C,      $300, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_51D,     SYS_ROUND_51D,      $300, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_52A,     SYS_ROUND_52A,      $301, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_52B,     SYS_ROUND_52B,      $301, TIME_PAST,    0
	selectEntry SELECT_ROUND_52C,     SYS_ROUND_52C,      $301, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_52D,     SYS_ROUND_52D,      $301, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_53C,     SYS_ROUND_53C,      $302, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_53D,     SYS_ROUND_53D,      $302, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_61A,     SYS_ROUND_61A,      $400, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_61B,     SYS_ROUND_61B,      $400, TIME_PAST,    0
	selectEntry SELECT_ROUND_61C,     SYS_ROUND_61C,      $400, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_61D,     SYS_ROUND_61D,      $400, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_62A,     SYS_ROUND_62A,      $401, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_62B,     SYS_ROUND_62B,      $401, TIME_PAST,    0
	selectEntry SELECT_ROUND_62C,     SYS_ROUND_62C,      $401, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_62D,     SYS_ROUND_62D,      $401, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_63C,     SYS_ROUND_63C,      $402, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_63D,     SYS_ROUND_63D,      $402, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_71A,     SYS_ROUND_71A,      $500, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_71B,     SYS_ROUND_71B,      $500, TIME_PAST,    0
	selectEntry SELECT_ROUND_71C,     SYS_ROUND_71C,      $500, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_71D,     SYS_ROUND_71D,      $500, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_72A,     SYS_ROUND_72A,      $501, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_72B,     SYS_ROUND_72B,      $501, TIME_PAST,    0
	selectEntry SELECT_ROUND_72C,     SYS_ROUND_72C,      $501, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_72D,     SYS_ROUND_72D,      $501, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_73C,     SYS_ROUND_73C,      $502, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_73D,     SYS_ROUND_73D,      $502, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_81A,     SYS_ROUND_81A,      $600, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_81B,     SYS_ROUND_81B,      $600, TIME_PAST,    0
	selectEntry SELECT_ROUND_81C,     SYS_ROUND_81C,      $600, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_81D,     SYS_ROUND_81D,      $600, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_82A,     SYS_ROUND_82A,      $601, TIME_PRESENT, 0
	selectEntry SELECT_ROUND_82B,     SYS_ROUND_82B,      $601, TIME_PAST,    0
	selectEntry SELECT_ROUND_82C,     SYS_ROUND_82C,      $601, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_82D,     SYS_ROUND_82D,      $601, TIME_FUTURE,  0
	selectEntry SELECT_ROUND_83C,     SYS_ROUND_83C,      $602, TIME_FUTURE,  1
	selectEntry SELECT_ROUND_83D,     SYS_ROUND_83D,      $602, TIME_FUTURE,  0
	selectEntry SELECT_SPECIAL_STAGE, SYS_SPECIAL_STAGE,  $000, TIME_PAST,    0
	selectEntry SELECT_UNUSED_1,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_2,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_3,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0
	selectEntry SELECT_UNUSED_4,      SYS_ROUND_11A,      $000, TIME_PRESENT, 0

; ------------------------------------------------------------------------------
; Demo mode
; ------------------------------------------------------------------------------

Demo:
	moveq	#(.DemosEnd-.Demos)/2-1,d1			; Maximum demo ID
	
	lea	demo_id,a6					; Get current demo ID
	moveq	#0,d0
	move.b	(a6),d0

	addq.b	#1,(a6)						; Advance demo ID
	cmp.b	(a6),d1						; Are we past the max ID?
	bcc.s	.RunDemo					; If not, branch
	move.b	#0,(a6)						; Wrap demo ID

.RunDemo:
	add.w	d0,d0						; Run demo
	move.w	.Demos(pc,d0.w),d0
	jmp	.Demos(pc,d0.w)

; ------------------------------------------------------------------------------

.Demos:
	dc.w	RunOpeningDemo-.Demos
	dc.w	RunDemo11A-.Demos
	dc.w	RunSpecialDemo1-.Demos
	dc.w	RunDemo43C-.Demos
	dc.w	RunSpecialDemo6-.Demos
	dc.w	RunDemo82A-.Demos
.DemosEnd:

; ------------------------------------------------------------------------------
; Palmtree Panic Act 1 Present demo
; ------------------------------------------------------------------------------

RunDemo11A:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$000,zone_act					; Set stage to Palmtree Panic Act 1
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present
	move.b	#0,good_future					; Reset good future flag
	
	move.w	#SYS_DEMO_11A,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Tidal Tempest Act 3 Good Future
; ------------------------------------------------------------------------------

RunDemo43C:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$202,zone_act					; Set stage to Tidal Tempest Act 3
	move.b	#TIME_FUTURE,time_zone				; Set time zone to present
	move.b	#1,good_future					; Set good future flag
	
	move.w	#SYS_DEMO_43C,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Metallic Madness Act 2 Present
; ------------------------------------------------------------------------------

RunDemo82A:
	move.b	#0,nemesis_queue_flags				; Reset Nemesis queue flags
	move.w	#$601,zone_act					; Set stage to Metallic Madness Act 2
	move.b	#TIME_PRESENT,time_zone				; Set time zone to present
	move.b	#0,good_future					; Reset good future flag
	
	move.w	#SYS_DEMO_82A,d0				; Run demo file
	bsr.w	RunMmd
	move.w	#0,demo_mode					; Reset demo mode flag
	rts

; ------------------------------------------------------------------------------
; Special Stage 1 demo
; ------------------------------------------------------------------------------

RunSpecialDemo1:
	move.w	#SYS_SPECIAL_RESET,d0				; Reset special stage flags
	bsr.w	SubCpuCommand
	bra.w	SpecialStage1Demo				; Run demo file

; ------------------------------------------------------------------------------
; Special Stage 6 demo
; ------------------------------------------------------------------------------

RunSpecialDemo6:
	move.w	#SYS_SPECIAL_RESET,d0				; Reset special stage flags
	bsr.w	SubCpuCommand
	bra.w	SpecialStage6Demo				; Run demo file

; ------------------------------------------------------------------------------
; Opening FMV
; ------------------------------------------------------------------------------

RunOpeningDemo:
	move.w	#SYS_OPENING,d0					; Run opening FMV
	bsr.w	RunMmd

	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	RunOpeningDemo					; If so, loop
	rts

; ------------------------------------------------------------------------------
; Sound test
; ------------------------------------------------------------------------------

SoundTest:
	moveq	#SYS_SOUND_TEST,d0				; Run sound test
	bsr.w	RunMmd

	add.w	d0,d0						; Exit sound test
	move.w	.Exits(pc,d0.w),d0
	jmp	.Exits(pc,d0.w)

; ------------------------------------------------------------------------------

.Exits:
	dc.w	ExitSoundTest-.Exits				; Exit sound test
	dc.w	RunSpecialStage8-.Exits				; Special Stage 8
	dc.w	RunFunIsInfinite-.Exits				; Fun is infinite
	dc.w	RunMcSonic-.Exits				; M.C. Sonic
	dc.w	RunTails-.Exits					; Tails
	dc.w	RunBatman-.Exits				; Batman Sonic
	dc.w	RunCuteSonic-.Exits				; Cute Sonic

; ------------------------------------------------------------------------------
; Exit sound test
; ------------------------------------------------------------------------------

ExitSoundTest:
	rts

; ------------------------------------------------------------------------------
; Special Stage 8
; ------------------------------------------------------------------------------

RunSpecialStage8:
	move.b	#8-1,special_stage_id_cmd			; Stage 8
	move.b	#0,time_stones_cmd				; Reset time stones retrieved
	bset	#0,special_stage_flags				; Temporary mode
	bset	#2,special_stage_flags				; Secret mode
	
	moveq	#SYS_SPECIAL_STAGE,d0				; Run special stage
	bsr.w	RunMmd
	
	tst.b	special_stage_lost				; Was the stage beaten?
	bne.s	.End						; If not, branch
	
	move.w	#SYS_SPECIAL_8_END,d0				; If so, run credits
	bsr.w	RunMmd

.End:
	rts

; ------------------------------------------------------------------------------
; "Fun is infinite" easter egg
; ------------------------------------------------------------------------------

RunFunIsInfinite:
	move.w	#SYS_FUN_IS_INFINITE,d0			; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; M.C. Sonic easter egg
; ------------------------------------------------------------------------------

RunMcSonic:
	move.w	#SYS_MC_SONIC,d0				; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Tails easter egg
; ------------------------------------------------------------------------------

RunTails:
	move.w	#SYS_TAILS,d0					; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Batman Sonic easter egg
; ------------------------------------------------------------------------------

RunBatman:
	move.w	#SYS_BATMAN,d0					; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Cute Sonic easter egg
; ------------------------------------------------------------------------------

RunCuteSonic:
	move.w	#SYS_CUTE_SONIC,d0				; Run easter egg
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Visual Mode
; ------------------------------------------------------------------------------

VisualMode:
	move.w	#SYS_VISUAL_MODE,d0				; Run Visual Mode
	bsr.w	RunMmd

	add.w	d0,d0						; Play FMV
	move.w	.FMVs(pc,d0.w),d0
	jmp	.FMVs(pc,d0.w)

; ------------------------------------------------------------------------------

.FMVs:
	dc.w	ExitVisualMode-.FMVs				; Exit Visual Mode
	dc.w	VisualModeOpening-.FMVs				; Opening
	dc.w	VisualModeGoodEnding-.FMVs			; Good ending
	dc.w	VisualModeBadEnding-.FMVs			; Bad ending
	dc.w	VisualModePencilTest-.FMVs			; Pencil test

; ------------------------------------------------------------------------------
; Play opening FMV
; ------------------------------------------------------------------------------

VisualModeOpening:
	move.w	#SYS_OPENING,d0					; Run opening
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeOpening				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Exit Visual Mode
; ------------------------------------------------------------------------------

ExitVisualMode:
	rts

; ------------------------------------------------------------------------------
; Play pencil test FMV
; ------------------------------------------------------------------------------

VisualModePencilTest:
	move.w	#SYS_PENCIL_TEST,d0				; Run pencil test
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModePencilTest				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Play good ending FMV
; ------------------------------------------------------------------------------

VisualModeGoodEnding:
	move.b	#$7F,ending_id					; Set ending ID to good ending
	
	move.w	#SYS_GOOD_END,d0				; Run good ending
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeGoodEnding				; If so, loop
	
	move.w	#SYS_THANKS,d0					; Run "Thank You" screen
	bsr.w	RunMmd

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; Play bad ending FMV
; ------------------------------------------------------------------------------

VisualModeBadEnding:
	move.b	#0,ending_id					; Set ending ID to bad ending
	
	move.w	#SYS_BAD_END,d0					; Run bad ending
	bsr.w	RunMmd
	
	tst.b	mmd_return_code					; Should we play it again?
	bmi.s	VisualModeBadEnding				; If so, loop

	bra.s	VisualMode					; Go back to menu

; ------------------------------------------------------------------------------
; D.A. Garden
; ------------------------------------------------------------------------------

DaGarden:
	move.w	#SYS_DA_GARDEN,d0				; Run D.A. Garden
	bra.w	RunMmd

; ------------------------------------------------------------------------------
; Time Attack
; ------------------------------------------------------------------------------

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
