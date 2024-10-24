; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"mcd_sub.inc"
	include	"system.inc"
	include	"system_symbols.inc"
	include	"backup_ram.inc"
	include	"cdda_ids.inc"
	include	"pcm_sound_ids.inc"
	include	"pcm_driver.inc"
	include	"../../sound/pcm/variables.inc"
	include	"da_garden.inc"
	include	"special_stage.inc"

	section code

; ------------------------------------------------------------------------------
; Define a command
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - ID constant name
;	\2 - Command name
; ------------------------------------------------------------------------------

__command_id set 1
command macro
	xdef \1
	dc.w	(\2)-Commands
	\1:		equ __command_id
	__command_id:	set __command_id+1
	endm

; ------------------------------------------------------------------------------
; Command handler
; ------------------------------------------------------------------------------

CommandHandler:
	lea	SpVariables,a0					; Clear variables
	move.w	#SP_VARIABLES_SIZE/4-1,d7

.ClearVariables:
	move.l	#0,(a0)+
	dbf	d7,.ClearVariables
	ifne SP_VARIABLES_SIZE&2
		clr.w	(a0)+
	endif
	ifne SP_VARIABLES_SIZE&1
		clr.b	(a0)+
	endif

	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt
	move.l	#TimerIrq,_LEVEL3+2				; Set timer interrupt address
	move.b	#255,MCD_IRQ3_TIME				; Set timer interrupt interval

.WaitCommand:
	move.w	MCD_MAIN_COMM_0,d0				; Get command ID from Main CPU
	beq.s	.WaitCommand
	cmp.w	MCD_MAIN_COMM_0,d0
	bne.s	.WaitCommand
	cmpi.w	#(CommandsEnd-Commands)/2+1,d0			; Note: that "+1" shouldn't be there
	bcc.w	FinishCommand					; If it's an invalid ID, branch

	move.w	d0,d1						; Execute command
	add.w	d0,d0
	move.w	Commands(pc,d0.w),d0
	jsr	Commands(pc,d0.w)

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2 address
	bclr	#MCDR_IEN1_BIT,MCD_IRQ_MASK			; Disable graphics interrupt
	move.l	#NullGraphicsIrq,_LEVEL1+2			; Reset graphics interrupt address

	bra.s	.WaitCommand					; Loop

; ------------------------------------------------------------------------------

Commands:
	dc.w	0
	command SYS_ROUND_11A,        LoadStage
	command SYS_ROUND_11B,        LoadStage
	command SYS_ROUND_11C,        LoadStage
	command SYS_ROUND_11D,        LoadStage
	command SYS_MD_INIT,          LoadMegaDriveInit,      
	command SYS_STAGE_SELECT,     LoadStageSelect
	command SYS_ROUND_12A,        LoadStage
	command SYS_ROUND_12B,        LoadStage
	command SYS_ROUND_12C,        LoadStage
	command SYS_ROUND_12D,        LoadStage
	command SYS_TITLE,            LoadTitleScreen
	command SYS_WARP,             LoadWarp,               
	command SYS_TIME_ATTACK,      LoadTimeAttack
	command SYS_FADE_CDDA,        FadeOutCdda
	command SYS_SONG_1A,          PlayRound1ASong
	command SYS_SONG_1C,          PlayRound1CSong
	command SYS_SONG_1D,          PlayRound1DSong
	command SYS_SONG_3A,          PlayRound3ASong
	command SYS_SONG_3C,          PlayRound3CSong
	command SYS_SONG_3D,          PlayRound3DSong
	command SYS_SONG_4A,          PlayRound4ASong
	command SYS_SONG_4C,          PlayRound4CSong
	command SYS_SONG_4D,          PlayRound4DSong
	command SYS_SONG_5A,          PlayRound5ASong
	command SYS_SONG_5C,          PlayRound5CSong
	command SYS_SONG_5D,          PlayRound5DSong
	command SYS_SONG_6A,          PlayRound6ASong
	command SYS_SONG_6C,          PlayRound6CSong
	command SYS_SONG_6D,          PlayRound6DSong
	command SYS_SONG_7A,          PlayRound7ASong
	command SYS_SONG_7C,          PlayRound7CSong
	command SYS_SONG_7D,          PlayRound7DSong
	command SYS_SONG_8A,          PlayRound8ASong
	command SYS_SONG_8C,          PlayRound8CSong
	command SYS_IPX,              LoadIpx,                
	command SYS_DEMO_43C,         LoadStage
	command SYS_DEMO_82A,         LoadStage
	command SYS_SOUND_TEST,       LoadSoundTest
	command SYS_INVALID,          LoadStage
	command SYS_ROUND_31A,        LoadStage
	command SYS_ROUND_31B,        LoadStage
	command SYS_ROUND_31C,        LoadStage
	command SYS_ROUND_31D,        LoadStage
	command SYS_ROUND_32A,        LoadStage
	command SYS_ROUND_32B,        LoadStage
	command SYS_ROUND_32C,        LoadStage
	command SYS_ROUND_32D,        LoadStage
	command SYS_ROUND_33C,        LoadStage
	command SYS_ROUND_33D,        LoadStage
	command SYS_ROUND_13C,        LoadStage
	command SYS_ROUND_13D,        LoadStage
	command SYS_ROUND_41A,        LoadStage
	command SYS_ROUND_41B,        LoadStage
	command SYS_ROUND_41C,        LoadStage
	command SYS_ROUND_41D,        LoadStage
	command SYS_ROUND_42A,        LoadStage
	command SYS_ROUND_42B,        LoadStage
	command SYS_ROUND_42C,        LoadStage
	command SYS_ROUND_42D,        LoadStage
	command SYS_ROUND_43C,        LoadStage
	command SYS_ROUND_43D,        LoadStage
	command SYS_ROUND_51A,        LoadStage
	command SYS_ROUND_51B,        LoadStage
	command SYS_ROUND_51C,        LoadStage
	command SYS_ROUND_51D,        LoadStage
	command SYS_ROUND_52A,        LoadStage
	command SYS_ROUND_52B,        LoadStage
	command SYS_ROUND_52C,        LoadStage
	command SYS_ROUND_52D,        LoadStage
	command SYS_ROUND_53C,        LoadStage
	command SYS_ROUND_53D,        LoadStage
	command SYS_ROUND_61A,        LoadStage
	command SYS_ROUND_61B,        LoadStage
	command SYS_ROUND_61C,        LoadStage
	command SYS_ROUND_61D,        LoadStage
	command SYS_ROUND_62A,        LoadStage
	command SYS_ROUND_62B,        LoadStage
	command SYS_ROUND_62C,        LoadStage
	command SYS_ROUND_62D,        LoadStage
	command SYS_ROUND_63C,        LoadStage
	command SYS_ROUND_63D,        LoadStage
	command SYS_ROUND_71A,        LoadStage
	command SYS_ROUND_71B,        LoadStage
	command SYS_ROUND_71C,        LoadStage
	command SYS_ROUND_71D,        LoadStage
	command SYS_ROUND_72A,        LoadStage
	command SYS_ROUND_72B,        LoadStage
	command SYS_ROUND_72C,        LoadStage
	command SYS_ROUND_72D,        LoadStage
	command SYS_ROUND_73C,        LoadStage
	command SYS_ROUND_73D,        LoadStage
	command SYS_ROUND_81A,        LoadStage
	command SYS_ROUND_81B,        LoadStage
	command SYS_ROUND_81C,        LoadStage
	command SYS_ROUND_81D,        LoadStage
	command SYS_ROUND_82A,        LoadStage
	command SYS_ROUND_82B,        LoadStage
	command SYS_ROUND_82C,        LoadStage
	command SYS_ROUND_82D,        LoadStage
	command SYS_ROUND_83C,        LoadStage
	command SYS_ROUND_83D,        LoadStage
	command SYS_SONG_8D,          PlayRound8DSong
	command SYS_SONG_BOSS,        PlayBossSong
	command SYS_SONG_FINAL,       PlayFinalBossSong,      
	command SYS_SONG_TITLE,       PlayTitleSong
	command SYS_SONG_TIME_ATTACK, PlayTimeAttackSong
	command SYS_SONG_RESULTS,     PlayResultsSong
	command SYS_SONG_SPEED_SHOES, PlaySpeedShoesSong
	command SYS_SONG_INVINCIBLE,  PlayInvincibleSong
	command SYS_SONG_GAME_OVER,   PlayGameOverSong
	command SYS_SONG_SPECIAL,     PlaySpecialStageSong
	command SYS_SONG_DA_GARDEN,   PlayDaGardenSong
	command SYS_SFX_PROTO_WARP,   PlayProtoWarpSound
	command SYS_SONG_OPENING,     PlayOpeningSong
	command SYS_SONG_ENDING,      PlayEndingSong
	command SYS_CDDA_STOP,        StopCdda,               
	command SYS_SPECIAL_STAGE,    LoadSpecialStage
	command SYS_SFX_FUTURE,       PlayFutureVoiceSfx
	command SYS_SFX_PAST,         PlayPastVoiceSfx
	command SYS_SFX_ALRIGHT,      PlayAlrightSfx
	command SYS_SFX_OUTTA_HERE,   PlayOuttaHereSfx
	command SYS_SFX_YES,          PlayYesSfx
	command SYS_SFX_YEAH,         PlayYeahSfx
	command SYS_SFX_AMY_GIGGLE,   PlayAmyGiggleSfx
	command SYS_SFX_AMY_YELP,     PlayAmyYelpSfx
	command SYS_SFX_STOMP,        PlayStompSfx
	command SYS_SFX_BUMPER,       PlayBumperSfx
	command SYS_SONG_PAST,        PlayPastSong
	command SYS_DA_GARDEN,        LoadDaGarden
	command SYS_PCM_FADE,         FadeOutPcm
	command SYS_PCM_STOP,         StopPcm,                
	command SYS_DEMO_11A,         LoadStage
	command SYS_VISUAL_MODE,      LoadVisualMode
	command SYS_SPECIAL_INIT,     InitSpecialStageFlags
	command SYS_BURAM_READ,       ReadBuramSaveData,      
	command SYS_BURAM_WRITE,      WriteBuramSaveData
	command SYS_BURAM_INIT,       LoadBuramInit
	command SYS_SPECIAL_RESET,    ResetSpecialStageFlags
	command SYS_TEMP_READ,        ReadTempSaveData
	command SYS_TEMP_WRITE,       WriteTempSaveData,      
	command SYS_THANKS,           LoadThankYou
	command SYS_BURAM_MANAGER,    LoadBuramManager
	command SYS_VOLUME_RESET,     ResetCddaVolumeCmd
	command SYS_PCM_PAUSE,        PausePcm,               
	command SYS_PCM_UNPAUSE,      UnpausePcm
	command SYS_SFX_BREAK,        PlayBreakSfx
	command SYS_BAD_END,          LoadBadEnding
	command SYS_GOOD_END,         LoadGoodEnding
	command SYS_TEST_R1A,         TestRound1ASong
	command SYS_TEST_R1C,         TestRound1CSong
	command SYS_TEST_R1D,         TestRound1DSong
	command SYS_TEST_R3A,         TestRound3ASong
	command SYS_TEST_R3C,         TestRound3CSong
	command SYS_TEST_R3D,         TestRound3DSong
	command SYS_TEST_R4A,         TestRound4ASong
	command SYS_TEST_R4C,         TestRound4CSong
	command SYS_TEST_R4D,         TestRound4DSong
	command SYS_TEST_R5A,         TestRound5ASong
	command SYS_TEST_R5C,         TestRound5CSong
	command SYS_TEST_R5D,         TestRound5DSong
	command SYS_TEST_R6A,         TestRound6ASong
	command SYS_TEST_R6C,         TestRound6CSong
	command SYS_TEST_R6D,         TestRound6DSong
	command SYS_TEST_R7A,         TestRound7ASong
	command SYS_TEST_R7C,         TestRound7CSong
	command SYS_TEST_R7D,         TestRound7DSong
	command SYS_TEST_R8A,         TestRound8ASong
	command SYS_TEST_R8C,         TestRound8CSong
	command SYS_TEST_R8D,         TestRound8DSong
	command SYS_TEST_BOSS,        TestBossSong
	command SYS_TEST_FINAL,       TestFinalSong
	command SYS_TEST_TITLE,       TestTitleSong
	command SYS_TEST_TIME_ATTACK, TestTimeAttackSong
	command SYS_TEST_RESULTS,     TestResultsSong
	command SYS_TEST_SPEED_SHOES, TestSpeedShoesSong
	command SYS_TEST_INVINCIBLE,  TestInvincibleSong
	command SYS_TEST_GAME_OVER,   TestGameOverSong
	command SYS_TEST_SPECIAL,     TestSpecialStageSong
	command SYS_TEST_DA_GARDEN,   TestDaGardenSong
	command SYS_TEST_PROTO_WARP,  TestProtoWarpSound
	command SYS_TEST_OPENING,     TestOpeningSong
	command SYS_TEST_ENDING,      TestEndingSong
	command SYS_TEST_FUTURE,      TestFutureVoiceSfx
	command SYS_TEST_PAST,        TestPastVoiceSfx
	command SYS_TEST_ALRIGHT,     TestAlrightSfx
	command SYS_TEST_OUTTA_HERE,  TestOuttaHereSfx
	command SYS_TEST_YES,         TestYesSfx
	command SYS_TEST_YEAH,        TestYeahSfx
	command SYS_TEST_AMY_GIGGLE,  TestAmyGiggleSfx
	command SYS_TEST_AMY_YELP,    TestAmyYelpSfx
	command SYS_TEST_STOMP,       TestStompSfx
	command SYS_TEST_BUMPER,      TestBumperSfx
	command SYS_TEST_R1B,         TestRound1BSong
	command SYS_TEST_R3B,         TestRound3BSong
	command SYS_TEST_R4B,         TestRound4BSong
	command SYS_TEST_R5B,         TestRound5BSong
	command SYS_TEST_R6B,         TestRound6BSong
	command SYS_TEST_R7B,         TestRound7BSong
	command SYS_TEST_R8B,         TestRound8BSong
	command SYS_FUN_IS_INFINITE,  LoadFunIsInfinite,      
	command SYS_SPECIAL_8_END,    LoadSpecialStage8End
	command SYS_MC_SONIC,         LoadMcSonic
	command SYS_TAILS,            LoadTails
	command SYS_BATMAN,           LoadBatman
	command SYS_CUTE_SONIC,       LoadCuteSonic
	command SYS_STAFF_TIMES,      LoadBestStaffTimes
	command SYS_DUMMY_1,          LoadDummyFile1
	command SYS_DUMMY_2,          LoadDummyFile2
	command SYS_DUMMY_3,          LoadDummyFile3
	command SYS_DUMMY_4,          LoadDummyFile4
	command SYS_DUMMY_5,          LoadDummyFile5
	command SYS_PENCIL_TEST,      LoadPencilTest
	command SYS_CDDA_PAUSE,       PauseCdda
	command SYS_CDDA_UNPAUSE,     UnpauseCdda
	command SYS_OPENING,          LoadOpening
	command SYS_COMIN_SOON,       LoadCominSoon
CommandsEnd:

; ------------------------------------------------------------------------------
; Load pencil test FMV
; ------------------------------------------------------------------------------

LoadPencilTest:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	PencilTestMainFile(pc),a0			; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	PencilTestSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$30000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load Backup RAM manager
; ------------------------------------------------------------------------------

LoadBuramManager:
	lea	BuramMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BuramSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Load "Thank You" screen
; ------------------------------------------------------------------------------

LoadThankYou:
	bsr.w	WaitWordRamAccess				; Load Main CPU file
	lea	ThankYouMainFile(pc),a0
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	ThankYouDataFile(pc),a0				; Load data file
	lea	WORD_RAM_2M+$10000,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	ThankYouSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Reset special stage flags
; ------------------------------------------------------------------------------

ResetSpecialStageFlags:
	moveq	#0,d0
	move.b	d0,time_stones_sub				; Reset time stones retrieved
	move.b	d0,special_stage_id				; Reset stage ID
	move.l	d0,special_stage_timer				; Reset timer
	move.w	d0,special_stage_rings				; Reset rings
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Initialize special stage flags
; ------------------------------------------------------------------------------

InitSpecialStageFlags:
	moveq	#0,d0
	move.b	d0,time_stones_sub				; Reset time stones retrieved
	move.b	d0,special_stage_id				; Reset stage ID
	move.l	d0,special_stage_timer				; Reset timer
	move.w	d0,special_stage_rings				; Reset rings
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Load Backup RAM initialization
; ------------------------------------------------------------------------------

LoadBuramInit:
	lea	BuramInitFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BuramSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Read save data
; ------------------------------------------------------------------------------
	
ReadBuramSaveData:
	lea	BuramScratch(pc),a0				; Initialize Backup RAM interaction
	lea	BuramStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM

.ReadData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	BuramReadParams(pc),a0				; Load save data
	lea	WORD_RAM_2M,a1
	move.w	#BRMREAD,d0
	jsr	_BURAM
	bcs.s	.ReadData					; If it failed, try again

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Write save data
; ------------------------------------------------------------------------------

WriteBuramSaveData:
	lea	BuramScratch(pc),a0				; Initialize Backup RAM interaction
	lea	BuramStrings(pc),a1
	move.w	#BRMINIT,d0
	jsr	_BURAM

.WriteData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	BuramWriteParams(pc),a0				; Write save data
	lea	WORD_RAM_2M,a1
	move.w	#BRMWRITE,d0
	moveq	#0,d1
	jsr	_BURAM
	bcs.s	.WriteData					; If it failed, try again
	
	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Read temporary save data
; ------------------------------------------------------------------------------

ReadTempSaveData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	TempSaveData,a0					; Copy from temporary save data buffer
	lea	WORD_RAM_2M,a1
	move.w	#save.struct_size/4-1,d7

.Read:
	move.l	(a0)+,(a1)+
	dbf	d7,.Read

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Write temporary save data
; ------------------------------------------------------------------------------

WriteTempSaveData:
	bsr.w	WaitWordRamAccess				; Wait for Word RAM access

	lea	TempSaveData,a0					; Copy to temporary save data buffer
	lea	WORD_RAM_2M,a1
	move.w	#save.struct_size/4-1,d7

.Write:
	move.l	(a1)+,(a0)+
	dbf	d7,.Write

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Load stage
; ------------------------------------------------------------------------------

LoadStage:
	add.w	d1,d1						; Get stage file based on command ID
	lea	.StageFiles(pc),a1
	move.w	(a1,d1.w),d2
	lea	(a1,d2.w),a0
	move.l	d1,-(sp)

	bsr.w	WaitWordRamAccess				; Load stage file
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Reset CD audio volume
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.l	(sp)+,d1					; Get PCM driver file based on command ID
	add.w	d1,d1
	lea	.PcmDrivers(pc),a1
	move.l	cur_pcm_driver,d0
	cmp.l	(a1,d1.w),d0					; Is this PCM driver already loaded?
	beq.s	.Done						; If so, branch

	movea.l	(a1,d1.w),a0					; If not, load it
	move.l	a0,cur_pcm_driver
	lea	PcmDriver,a1
	jsr	LoadFile

.Done:
	bset	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Enable timer interrupt
	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access

; ------------------------------------------------------------------------------
; Stage files
; ------------------------------------------------------------------------------

.StageFiles:
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Palmtree Panic Act 1 Present
	dc.w	Round11BFile-.StageFiles			; Palmtree Panic Act 1 Past
	dc.w	Round11CFile-.StageFiles			; Palmtree Panic Act 1 Good Future
	dc.w	Round11DFile-.StageFiles			; Palmtree Panic Act 1 Bad Future
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round12AFile-.StageFiles			; Palmtree Panic Act 2 Present
	dc.w	Round12BFile-.StageFiles			; Palmtree Panic Act 2 Past
	dc.w	Round12CFile-.StageFiles			; Palmtree Panic Act 2 Good Future
	dc.w	Round12DFile-.StageFiles			; Palmtree Panic Act 2 Bad Future
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Demo43CFile-.StageFiles				; Tidal Tempest Act 3 Good Future demo
	dc.w	Demo82AFile-.StageFiles				; Metallic Madness Act 2 Present demo
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round31AFile-.StageFiles			; Collision Chaos Act 1 Present
	dc.w	Round31BFile-.StageFiles			; Collision Chaos Act 1 Past
	dc.w	Round31CFile-.StageFiles			; Collision Chaos Act 1 Good Future
	dc.w	Round31DFile-.StageFiles			; Collision Chaos Act 1 Bad Future
	dc.w	Round32AFile-.StageFiles			; Collision Chaos Act 2 Present 
	dc.w	Round32BFile-.StageFiles			; Collision Chaos Act 2 Past 
	dc.w	Round32CFile-.StageFiles			; Collision Chaos Act 2 Good Future 
	dc.w	Round32DFile-.StageFiles			; Collision Chaos Act 2 Bad Future 
	dc.w	Round33CFile-.StageFiles			; Collision Chaos Act 3 Good Future 
	dc.w	Round33DFile-.StageFiles			; Collision Chaos Act 3 Bad Future 
	dc.w	Round13CFile-.StageFiles			; Palmtree Panic Act 3 Good Future
	dc.w	Round13DFile-.StageFiles			; Palmtree Panic Act 3 Bad Future 
	dc.w	Round41AFile-.StageFiles			; Tidal Tempest Act 1 Present
	dc.w	Round41BFile-.StageFiles			; Tidal Tempest Act 1 Past
	dc.w	Round41CFile-.StageFiles			; Tidal Tempest Act 1 Good Future
	dc.w	Round41DFile-.StageFiles			; Tidal Tempest Act 1 Bad Future
	dc.w	Round42AFile-.StageFiles			; Tidal Tempest Act 2 Present 
	dc.w	Round42BFile-.StageFiles			; Tidal Tempest Act 2 Past 
	dc.w	Round42CFile-.StageFiles			; Tidal Tempest Act 2 Good Future 
	dc.w	Round42DFile-.StageFiles			; Tidal Tempest Act 2 Bad Future 
	dc.w	Round43CFile-.StageFiles			; Tidal Tempest Act 3 Good Future 
	dc.w	Round43DFile-.StageFiles			; Tidal Tempest Act 3 Bad Future 
	dc.w	Round51AFile-.StageFiles			; Quartz Quadrant Act 1 Present
	dc.w	Round51BFile-.StageFiles			; Quartz Quadrant Act 1 Past
	dc.w	Round51CFile-.StageFiles			; Quartz Quadrant Act 1 Good Future
	dc.w	Round51DFile-.StageFiles			; Quartz Quadrant Act 1 Bad Future
	dc.w	Round52AFile-.StageFiles			; Quartz Quadrant Act 2 Present 
	dc.w	Round52BFile-.StageFiles			; Quartz Quadrant Act 2 Past 
	dc.w	Round52CFile-.StageFiles			; Quartz Quadrant Act 2 Good Future 
	dc.w	Round52DFile-.StageFiles			; Quartz Quadrant Act 2 Bad Future 
	dc.w	Round53CFile-.StageFiles			; Quartz Quadrant Act 3 Good Future 
	dc.w	Round53DFile-.StageFiles			; Quartz Quadrant Act 3 Bad Future 
	dc.w	Round61AFile-.StageFiles			; Wacky Workbench Act 1 Present
	dc.w	Round61BFile-.StageFiles			; Wacky Workbench Act 1 Past
	dc.w	Round61CFile-.StageFiles			; Wacky Workbench Act 1 Good Future
	dc.w	Round61DFile-.StageFiles			; Wacky Workbench Act 1 Bad Future
	dc.w	Round62AFile-.StageFiles			; Wacky Workbench Act 2 Present 
	dc.w	Round62BFile-.StageFiles			; Wacky Workbench Act 2 Past 
	dc.w	Round62CFile-.StageFiles			; Wacky Workbench Act 2 Good Future 
	dc.w	Round62DFile-.StageFiles			; Wacky Workbench Act 2 Bad Future 
	dc.w	Round63CFile-.StageFiles			; Wacky Workbench Act 3 Good Future 
	dc.w	Round63DFile-.StageFiles			; Wacky Workbench Act 3 Bad Future 
	dc.w	Round71AFile-.StageFiles			; Stardust Speedway Act 1 Present
	dc.w	Round71BFile-.StageFiles			; Stardust Speedway Act 1 Past
	dc.w	Round71CFile-.StageFiles			; Stardust Speedway Act 1 Good Future
	dc.w	Round71DFile-.StageFiles			; Stardust Speedway Act 1 Bad Future
	dc.w	Round72AFile-.StageFiles			; Stardust Speedway Act 2 Present 
	dc.w	Round72BFile-.StageFiles			; Stardust Speedway Act 2 Past 
	dc.w	Round72CFile-.StageFiles			; Stardust Speedway Act 2 Good Future 
	dc.w	Round72DFile-.StageFiles			; Stardust Speedway Act 2 Bad Future 
	dc.w	Round73CFile-.StageFiles			; Stardust Speedway Act 3 Good Future 
	dc.w	Round73DFile-.StageFiles			; Stardust Speedway Act 3 Bad Future 
	dc.w	Round81AFile-.StageFiles			; Metallic Madness Act 1 Present
	dc.w	Round81BFile-.StageFiles			; Metallic Madness Act 1 Past
	dc.w	Round81CFile-.StageFiles			; Metallic Madness Act 1 Good Future
	dc.w	Round81DFile-.StageFiles			; Metallic Madness Act 1 Bad Future
	dc.w	Round82AFile-.StageFiles			; Metallic Madness Act 2 Present 
	dc.w	Round82BFile-.StageFiles			; Metallic Madness Act 2 Past 
	dc.w	Round82CFile-.StageFiles			; Metallic Madness Act 2 Good Future 
	dc.w	Round82DFile-.StageFiles			; Metallic Madness Act 2 Bad Future 
	dc.w	Round83CFile-.StageFiles			; Metallic Madness Act 3 Good Future 
	dc.w	Round83DFile-.StageFiles			; Metallic Madness Act 3 Bad Future 
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Demo11AFile-.StageFiles				; Palmtree Panic Act 1 Present demo
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid
	dc.w	Round11AFile-.StageFiles			; Invalid

; ------------------------------------------------------------------------------
; PCM drivers
; ------------------------------------------------------------------------------

.PcmDrivers:
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Present
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Past
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Good Future
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Bad Future
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Present
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Past
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Good Future
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 2 Bad Future
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Good Future demo
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Present demo
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Present
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Past
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Good Future
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 1 Bad Future
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Present 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Past 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Good Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 2 Bad Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 3 Good Future 
	dc.l	PcmDriverR3BFile				; Collision Chaos Act 3 Bad Future 
	dc.l	PcmDriverBoss					; Palmtree Panic Act 3 Good Future
	dc.l	PcmDriverBoss					; Palmtree Panic Act 3 Bad Future 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Present
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Past
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Good Future
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 1 Bad Future
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Present 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Past 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Good Future 
	dc.l	PcmDriverR4BFile				; Tidal Tempest Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Good Future 
	dc.l	PcmDriverBoss					; Tidal Tempest Act 3 Bad Future 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Present
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Past
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Good Future
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 1 Bad Future
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Present 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Past 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Good Future 
	dc.l	PcmDriverR5BFile				; Quartz Quadrant Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Quartz Quadrant Act 3 Good Future 
	dc.l	PcmDriverBoss					; Quartz Quadrant Act 3 Bad Future 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Present
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Past
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Good Future
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 1 Bad Future
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Present 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Past 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Good Future 
	dc.l	PcmDriverR6BFile				; Wacky Workbench Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Wacky Workbench Act 3 Good Future 
	dc.l	PcmDriverBoss					; Wacky Workbench Act 3 Bad Future 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Present
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Past
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Good Future
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 1 Bad Future
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Present 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Past 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Good Future 
	dc.l	PcmDriverR7BFile				; Stardust Speedway Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Stardust Speedway Act 3 Good Future 
	dc.l	PcmDriverBoss					; Stardust Speedway Act 3 Bad Future 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Present
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Past
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Good Future
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 1 Bad Future
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Present 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Past 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Good Future 
	dc.l	PcmDriverR8BFile				; Metallic Madness Act 2 Bad Future 
	dc.l	PcmDriverBoss					; Metallic Madness Act 3 Good Future 
	dc.l	PcmDriverBoss					; Metallic Madness Act 3 Bad Future 
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	PcmDriverR1BFile				; Palmtree Panic Act 1 Present demo
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid
	dc.l	Round11AFile					; Invalid

; ------------------------------------------------------------------------------
; Load Mega Drive initialization
; ------------------------------------------------------------------------------

LoadMegaDriveInit:
	lea	MdInitFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load title screen
; ------------------------------------------------------------------------------

LoadTitleScreen:
	lea	TitleMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	TitleSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access

	bsr.w	ResetCddaVolume					; Play title screen music
	lea	TitleScreenSong(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts
	
; ------------------------------------------------------------------------------
; Load "Comin' Soon" screen
; ------------------------------------------------------------------------------

LoadCominSoon:
	lea	CominSoonFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bsr.w	ResetCddaVolume					; Play invincibility music
	lea	InvincibleSong(pc),a0
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS

; ------------------------------------------------------------------------------
; Load special stage 8 credits
; ------------------------------------------------------------------------------

LoadSpecialStage8End:
	lea	Special8EndFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayEndingSong					; Play ending music

; ------------------------------------------------------------------------------
; Load "Fun is infinite" screen
; ------------------------------------------------------------------------------

LoadFunIsInfinite:
	lea	FunIsInfiniteFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayBossSong					; Play boss music

; ------------------------------------------------------------------------------
; Load M.C. Sonic screen
; ------------------------------------------------------------------------------

LoadMcSonic:
	lea	McSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayRound8ASong					; Play Metallic Madness Present music

; ------------------------------------------------------------------------------
; Load Tails screen
; ------------------------------------------------------------------------------

LoadTails:
	lea	TailsFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayDaGardenSong				; Play D.A. Garden music

; ------------------------------------------------------------------------------
; Load Batman Sonic screen
; ------------------------------------------------------------------------------

LoadBatman:
	lea	BatmanSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayFinalBossSong				; Play final boss music

; ------------------------------------------------------------------------------
; Load cute Sonic screen
; ------------------------------------------------------------------------------

LoadCuteSonic:
	lea	CuteSonicFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bra.w	PlayRound1CSong					; Play Palmtree Panic Good Future music

; ------------------------------------------------------------------------------
; Load best staff times screen
; ------------------------------------------------------------------------------

LoadBestStaffTimes:
	lea	BestStaffTimesFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	SpeedShoesSong(pc),a0				; Play speed shoes music
	bsr.w	ResetCddaVolume
	move.w	#MSCPLAYR,d0
	jmp	_CDBIOS

; ------------------------------------------------------------------------------
; Load main program
; ------------------------------------------------------------------------------

LoadIpx:
	lea	IpxFile(pc),a0					; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load sound test
; ------------------------------------------------------------------------------

LoadSoundTest:
	lea	SoundTestFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile1:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile2:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile3:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile4:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load dummy file (unused)
; ------------------------------------------------------------------------------

LoadDummyFile5:
	lea	McSonicFile(pc),a0				; Load file
	bra.s	LoadFileIntoWordRam

; ------------------------------------------------------------------------------
; Load stage select
; ------------------------------------------------------------------------------

LoadStageSelect:
	lea	StageSelectFile(pc),a0				; Load file
	
; ------------------------------------------------------------------------------
; Load file into Word RAM
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

LoadFileIntoWordRam:
	bsr.w	WaitWordRamAccess				; Load file into Word RAM
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load Visual Mode menu
; ------------------------------------------------------------------------------

LoadVisualMode:
	lea	VisualModeFile(pc),a0				; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Play title screen music
	lea	TitleScreenSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	bra.w	GiveWordRamAccess				; Give Main CPU Word RAM access
	
; ------------------------------------------------------------------------------
; Load time warp cutscene
; ------------------------------------------------------------------------------

LoadWarp:
	lea	WarpFile(pc),a0					; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bra.w	GiveWordRamAccess

; ------------------------------------------------------------------------------
; Load time attack menu
; ------------------------------------------------------------------------------

LoadTimeAttack:
	lea	TimeAttackMainFile(pc),a0			; Load file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	bsr.w	ResetCddaVolume					; Play time attack music
	;if REGION=USA
		lea	DaGardenSong(pc),a0
	;else
	;	lea	TimeAttackSong(pc),a0
	;endif
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS
	rts

; ------------------------------------------------------------------------------
; Load D.A. Garden
; ------------------------------------------------------------------------------

LoadDaGarden:
	lea	DaGardenMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	DaGardenDataFile(pc),a0				; Load data file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M+DaGardenTrackTitles,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	DaGardenSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	bsr.w	ResetCddaVolume					; Play D.A. Garden music
	lea	DaGardenSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	rts

; ------------------------------------------------------------------------------
; Load opening FMV
; ------------------------------------------------------------------------------

LoadOpening:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	OpeningMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	OpeningSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$30000,a1
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load bad ending FMV
; ------------------------------------------------------------------------------

LoadBadEnding:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	EndingMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	BadEndingSubFile(pc),a0				; Load Sub CPU file
	lea	PRG_RAM+$30000,a1				; GOODEND.BIN loads BADEND.STM. Seriously.
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load good ending FMV
; ------------------------------------------------------------------------------

LoadGoodEnding:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	lea	EndingMainFile(pc),a0				; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile
	bsr.w	GiveWordRamAccess

	lea	GoodEndingSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$30000,a1				; BADEND.BIN loads GOODEND.STM. Seriously.
	jsr	LoadFile

	jsr	PRG_RAM+$30000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	andi.b	#~(MCDR_RET|MCDR_MODE),MCD_MEM_MODE		; Set to 2M mode
	move.b	#MCDR_SUB_READ,MCD_CDC_DEVICE			; Set CDC device to "Sub CPU"
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Load special stage
; ------------------------------------------------------------------------------

LoadSpecialStage:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.b	special_stage_id_cmd,special_stage_id		; Set stage ID
	move.b	time_stones_cmd,time_stones_sub			; Set time stones retrieved
	move.b	special_stage_flags,spec_stage_flags_copy	; Copy flags

	lea	SpecialStageMainFile(pc),a0			; Load Main CPU file
	bsr.w	WaitWordRamAccess
	lea	WORD_RAM_2M,a1
	jsr	LoadFile

	lea	SpecialStageSubFile(pc),a0			; Load Sub CPU file
	lea	PRG_RAM+$10000,a1
	jsr	LoadFile

	moveq	#0,d0						; Copy stage data into Word RAM
	move.b	special_stage_id,d0
	mulu.w	#6,d0
	lea	SpecialStageData,a0
	move.w	4(a0,d0.w),d7
	movea.l	(a0,d0.w),a0
	lea	WORD_RAM_2M+SpecialStageDataCopy,a1

.CopyData:
	move.b	(a0)+,(a1)+
	dbf	d7,.CopyData

	bsr.w	GiveWordRamAccess				; Give Main CPU Word RAM access

	bsr.w	ResetCddaVolume					; Play special stage music
	lea	SpecialStageSong(pc),a0
	move.w	#MSCPLAYR,d0
	jsr	_CDBIOS

	jsr	PRG_RAM+$10000					; Run Sub CPU program

	move.l	#MegaDriveIrq,_USERCALL2+2			; Restore IRQ2
	
	btst	#1,spec_stage_flags_copy			; Were we in time attack mode?
	bne.s	.NoResultsSong					; If so, branch
	
	bsr.w	ResetCddaVolume					; If not, play results music
	lea	ResultsSong(pc),a0
	move.w	#MSCPLAY1,d0
	jsr	_CDBIOS

.NoResultsSong:
	move.b	#0,spec_stage_flags_copy			; Clear special stage flags copy
	move.l	#0,cur_pcm_driver				; Reset current PCM driver
	rts

; ------------------------------------------------------------------------------
; Play "Future" voice clip
; ------------------------------------------------------------------------------

PlayFutureVoiceSfx:
	move.b	#PCM_SFX_FUTURE,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Past" voice clip
; ------------------------------------------------------------------------------

PlayPastVoiceSfx:
	move.b	#PCM_SFX_PAST,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Alright" voice clip
; ------------------------------------------------------------------------------

PlayAlrightSfx:
	move.b	#PCM_SFX_ALRIGHT,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "I'm outta here" voice clip
; ------------------------------------------------------------------------------

PlayOuttaHereSfx:
	move.b	#PCM_SFX_OUTTA_HERE,PcmSoundQueue		; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yes" voice clip
; ------------------------------------------------------------------------------

PlayYesSfx:
	move.b	#PCM_SFX_YES,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yeah" voice clip
; ------------------------------------------------------------------------------

PlayYeahSfx:
	move.b	#PCM_SFX_YEAH,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy giggle voice clip
; ------------------------------------------------------------------------------

PlayAmyGiggleSfx:
	move.b	#PCM_SFX_AMY_GIGGLE,PcmSoundQueue		; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy yelp voice clip
; ------------------------------------------------------------------------------

PlayAmyYelpSfx:
	move.b	#PCM_SFX_AMY_YELP,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play mech stomp sound
; ------------------------------------------------------------------------------

PlayStompSfx:
	move.b	#PCM_SFX_STOMP,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play bumper sound
; ------------------------------------------------------------------------------

PlayBumperSfx:
	move.b	#PCM_SFX_BUMPER,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play glass break sound
; ------------------------------------------------------------------------------

PlayBreakSfx:
	move.b	#PCM_SFX_BREAK,PcmSoundQueue			; Play sound
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play past music
; ------------------------------------------------------------------------------

PlayPastSong:
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Play music
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Fade out PCM
; ------------------------------------------------------------------------------

FadeOutPcm:
	move.b	#PCM_CMD_FADE_OUT,PcmSoundQueue			; Fade out PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Stop PCM
; ------------------------------------------------------------------------------

StopPcm:
	move.b	#PCM_CMD_STOP,PcmSoundQueue			; Stop PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Pause PCM
; ------------------------------------------------------------------------------

PausePcm:
	move.b	#PCM_CMD_PAUSE,PcmSoundQueue			; Pause PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Unpause PCM
; ------------------------------------------------------------------------------

UnpausePcm:
	move.b	#PCM_CMD_UNPAUSE,PcmSoundQueue			; Unpause PCM
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset CD audio volume
; ------------------------------------------------------------------------------

ResetCddaVolumeCmd:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Fade out CD audio
; ------------------------------------------------------------------------------

FadeOutCdda:
	move.w	#FDRCHG,d0					; Fade out CD audio
	moveq	#$20,d1
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Stop CD audio
; ------------------------------------------------------------------------------

StopCdda:
	move.w	#MSCSTOP,d0					; Stop CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Pause CD audio
; ------------------------------------------------------------------------------

PauseCdda:
	move.w	#MSCPAUSEON,d0					; Pause CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Unpause CD audio
; ------------------------------------------------------------------------------

UnpauseCdda:
	move.w	#MSCPAUSEOFF,d0					; Unpause CD audio
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Reset CD audio volume
; ------------------------------------------------------------------------------

ResetCddaVolume:
	move.l	a0,-(sp)					; Save registers
	
	move.w	#FDRSET,d0					; Set CD audio volume
	move.w	#$380,d1
	jsr	_CDBIOS

	move.w	#FDRSET,d0					; Set CD audio master volume
	move.w	#$8380,d1
	jsr	_CDBIOS

	movea.l	(sp)+,a0					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Play Palmtree Panic Present music
; ------------------------------------------------------------------------------

PlayRound1ASong:
	lea	Round1ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Good Future music
; ------------------------------------------------------------------------------

PlayRound1CSong:
	lea	Round1CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music
; ------------------------------------------------------------------------------

PlayRound1DSong:
	lea	Round1DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Present music
; ------------------------------------------------------------------------------

PlayRound3ASong:
	lea	Round3ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Good Future music
; ------------------------------------------------------------------------------

PlayRound3CSong:
	lea	Round3CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Bad Future music
; ------------------------------------------------------------------------------

PlayRound3DSong:
	lea	Round3DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Present music
; ------------------------------------------------------------------------------

PlayRound4ASong:
	lea	Round4ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Good Future music
; ------------------------------------------------------------------------------

PlayRound4CSong:
	lea	Round4CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music
; ------------------------------------------------------------------------------

PlayRound4DSong:
	lea	Round4DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Present music
; ------------------------------------------------------------------------------

PlayRound5ASong:
	lea	Round5ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music
; ------------------------------------------------------------------------------

PlayRound5CSong:
	lea	Round5CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music
; ------------------------------------------------------------------------------

PlayRound5DSong:
	lea	Round5DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Present music
; ------------------------------------------------------------------------------

PlayRound6ASong:
	lea	Round6ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Good Future music
; ------------------------------------------------------------------------------

PlayRound6CSong:
	lea	Round6CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music
; ------------------------------------------------------------------------------

PlayRound6DSong:
	lea	Round6DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Present music
; ------------------------------------------------------------------------------

PlayRound7ASong:
	lea	Round7ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Good Future music
; ------------------------------------------------------------------------------

PlayRound7CSong:
	lea	Round7CSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music
; ------------------------------------------------------------------------------

PlayRound7DSong:
	lea	Round7DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Present music
; ------------------------------------------------------------------------------

PlayRound8ASong:
	lea	Round8ASong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Good Future music
; ------------------------------------------------------------------------------

PlayRound8CSong:
	lea	Round8CSong(pc),a0				; Play music

; ------------------------------------------------------------------------------
; Loop CD audio
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; ------------------------------------------------------------------------------

LoopCdda:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	move.w	#MSCPLAYR,d0					; Play track on loop
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Metallic Madness Bad Future music
; ------------------------------------------------------------------------------

PlayRound8DSong:
	lea	Round8DSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play boss music
; ------------------------------------------------------------------------------

PlayBossSong:
	lea	BossSong(pc),a0					; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play final boss music
; ------------------------------------------------------------------------------

PlayFinalBossSong:
	lea	FinalBossSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play time attack menu music
; ------------------------------------------------------------------------------

PlayTimeAttackSong:
	lea	TimeAttackSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play special stage music
; ------------------------------------------------------------------------------

PlaySpecialStageSong:
	lea	SpecialStageSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play D.A. Garden music
; ------------------------------------------------------------------------------

PlayDaGardenSong:
	lea	DaGardenSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play prototype time warp sound
; ------------------------------------------------------------------------------

PlayProtoWarpSound:
	lea	ProtoWarpSound(pc),a0				; Play sound
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play opening music
; ------------------------------------------------------------------------------

PlayOpeningSong:
	lea	OpeningSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play ending music
; ------------------------------------------------------------------------------

PlayEndingSong:
	lea	EndingSong(pc),a0				; Play music
	bra.s	LoopCdda

; ------------------------------------------------------------------------------
; Play title screen music
; ------------------------------------------------------------------------------

PlayTitleSong:
	lea	TitleScreenSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play results music
; ------------------------------------------------------------------------------

PlayResultsSong:
	lea	ResultsSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play speed shoes music
; ------------------------------------------------------------------------------

PlaySpeedShoesSong:
	lea	SpeedShoesSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play invincibility music
; ------------------------------------------------------------------------------

PlayInvincibleSong:
	lea	InvincibleSong(pc),a0				; Play music
	bra.s	PlayCdda

; ------------------------------------------------------------------------------
; Play game over music
; ------------------------------------------------------------------------------

PlayGameOverSong:
	lea	GameOverSong(pc),a0				; Play music

; ------------------------------------------------------------------------------
; Play CD audio
; ------------------------------------------------------------------------------
; PARAMETERS
;	a0.l - Pointer to music ID
; ------------------------------------------------------------------------------

PlayCdda:
	bsr.w	ResetCddaVolume					; Reset CD audio volume
	move.w	#MSCPLAY1,d0					; Play track once
	jsr	_CDBIOS
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Palmtree Panic Present music (sound test)
; ------------------------------------------------------------------------------

TestRound1ASong:
	lea	Round1ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound1CSong:
	lea	Round1CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Palmtree Panic Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound1DSong:
	lea	Round1DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Present music (sound test)
; ------------------------------------------------------------------------------

TestRound3ASong:
	lea	Round3ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound3CSong:
	lea	Round3CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Collision Chaos Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound3DSong:
	lea	Round3DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Present music (sound test)
; ------------------------------------------------------------------------------

TestRound4ASong:
	lea	Round4ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound4CSong:
	lea	Round4CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Tidal Tempest Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound4DSong:
	lea	Round4DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Present music (sound test)
; ------------------------------------------------------------------------------

TestRound5ASong:
	lea	Round5ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound5CSong:
	lea	Round5CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Quartz Quadrant Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound5DSong:
	lea	Round5DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Present music (sound test)
; ------------------------------------------------------------------------------

TestRound6ASong:
	lea	Round6ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound6CSong:
	lea	Round6CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Wacky Workbench Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound6DSong:
	lea	Round6DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Present music (sound test)
; ------------------------------------------------------------------------------

TestRound7ASong:
	lea	Round7ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound7CSong:
	lea	Round7CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Stardust Speedway Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound7DSong:
	lea	Round7DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Present music (sound test)
; ------------------------------------------------------------------------------

TestRound8ASong:
	lea	Round8ASong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Good Future music (sound test)
; ------------------------------------------------------------------------------

TestRound8CSong:
	lea	Round8CSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play Metallic Madness Bad Future music (sound test)
; ------------------------------------------------------------------------------

TestRound8DSong:
	lea	Round8DSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play boss music (sound test)
; ------------------------------------------------------------------------------

TestBossSong:
	lea	BossSong(pc),a0					; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play final boss music (sound test)
; ------------------------------------------------------------------------------

TestFinalSong:
	lea	FinalBossSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play title screen music (sound test)
; ------------------------------------------------------------------------------

TestTitleSong:
	lea	TitleScreenSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play time attack menu music (sound test)
; ------------------------------------------------------------------------------

TestTimeAttackSong:
	lea	TimeAttackSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play results music (sound test)
; ------------------------------------------------------------------------------

TestResultsSong:
	lea	ResultsSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play speed shoes music (sound test)
; ------------------------------------------------------------------------------

TestSpeedShoesSong:
	lea	SpeedShoesSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play invincibility music (sound test)
; ------------------------------------------------------------------------------

TestInvincibleSong:
	lea	InvincibleSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play game over music (sound test)
; ------------------------------------------------------------------------------

TestGameOverSong:
	lea	GameOverSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play special stage music (sound test)
; ------------------------------------------------------------------------------

TestSpecialStageSong:
	lea	SpecialStageSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play D.A. Garden music (sound test)
; ------------------------------------------------------------------------------

TestDaGardenSong:
	lea	DaGardenSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play prototype warp sound (sound test)
; ------------------------------------------------------------------------------

TestProtoWarpSound:
	lea	ProtoWarpSound(pc),a0				; Play sound
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play opening music (sound test)
; ------------------------------------------------------------------------------

TestOpeningSong:
	lea	OpeningSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play ending music (sound test)
; ------------------------------------------------------------------------------

TestEndingSong:
	lea	EndingSong(pc),a0				; Play music
	bra.w	PlayCdda

; ------------------------------------------------------------------------------
; Play "Future" voice clip (sound test)
; ------------------------------------------------------------------------------

TestFutureVoiceSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_FUTURE,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Past" voice clip (sound test)
; ------------------------------------------------------------------------------

TestPastVoiceSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_PAST,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Alright" voice clip (sound test)
; ------------------------------------------------------------------------------

TestAlrightSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_ALRIGHT,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "I'm outta here" voice clip (sound test)
; ------------------------------------------------------------------------------

TestOuttaHereSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_OUTTA_HERE,PcmSoundQueue		; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yes" voice clip (sound test)
; ------------------------------------------------------------------------------

TestYesSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_YES,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play "Yeah" voice clip (sound test)
; ------------------------------------------------------------------------------

TestYeahSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_YEAH,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy giggle voice clip (sound test)
; ------------------------------------------------------------------------------

TestAmyGiggleSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_AMY_GIGGLE,PcmSoundQueue		; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Amy yelp voice clip (sound test)
; ------------------------------------------------------------------------------

TestAmyYelpSfx:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_AMY_YELP,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play mech stomp sound (sound test)
; ------------------------------------------------------------------------------

TestStompSfx:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_STOMP,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play bumper sound (sound test)
; ------------------------------------------------------------------------------

TestBumperSfx:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SFX_BUMPER,PcmSoundQueue			; Queue sound ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Palmtree Panic past music (sound test)
; ------------------------------------------------------------------------------

TestRound1BSong:
	lea	PcmDriverR1BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Collision Chaos past music (sound test)
; ------------------------------------------------------------------------------

TestRound3BSong:
	lea	PcmDriverR3BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Tidal Tempest past music (sound test)
; ------------------------------------------------------------------------------

TestRound4BSong:
	lea	PcmDriverR4BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Quartz Quadrant past music (sound test)
; ------------------------------------------------------------------------------

TestRound5BSong:
	lea	PcmDriverR5BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Wacky Workbench past music (sound test)
; ------------------------------------------------------------------------------

TestRound6BSong:
	lea	PcmDriverR6BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Stardust Speedway past music (sound test)
; ------------------------------------------------------------------------------

TestRound7BSong:
	lea	PcmDriverR7BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Play Metallic Madness past music (sound test)
; ------------------------------------------------------------------------------

TestRound8BSong:
	lea	PcmDriverR8BFile(pc),a0				; Load PCM driver
	bsr.w	LoadPcmDriver
	move.b	#PCM_SONG_PAST,PcmSoundQueue			; Queue music ID
	bra.w	FinishCommand

; ------------------------------------------------------------------------------
; Load PCM driver for sound test
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to file name
; ------------------------------------------------------------------------------

LoadPcmDriver:
	bclr	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Disable timer interrupt

	move.l	cur_pcm_driver,d0				; Is this driver already loaded?
	move.l	a0,cur_pcm_driver
	cmp.l	a0,d0
	beq.s	.End						; If so, branch
	
	lea	PcmDriver,a1					; Load driver
	jsr	LoadFile

.End:
	bset	#MCDR_IEN3_BIT,MCD_IRQ_MASK			; Enable timer interrupt
	rts

; ------------------------------------------------------------------------------
; Null graphics interrupt
; ------------------------------------------------------------------------------

NullGraphicsIrq:
	rte

; ------------------------------------------------------------------------------
; Run PCM driver (timer interrupt)
; ------------------------------------------------------------------------------

TimerIrq:
	bchg	#0,pcm_driver_flags				; Should we run the driver on this interrupt?
	beq.s	.End						; If not, branch

	movem.l	d0-a6,-(sp)					; Run the driver
	jsr	RunPcmDriver
	movem.l	(sp)+,d0-a6

.End:
	rte
	
; ------------------------------------------------------------------------------
; Give Word RAM access to the Main CPU (and finish off command)
; ------------------------------------------------------------------------------

GiveWordRamAccess:
	bset	#MCDR_RET_BIT,MCD_MEM_MODE			; Give Word RAM access to Main CPU
	btst	#MCDR_RET_BIT,MCD_MEM_MODE			; Has it been given?
	beq.s	GiveWordRamAccess				; If not, wait

; ------------------------------------------------------------------------------
; Finish off command
; ------------------------------------------------------------------------------

FinishCommand:
	move.w	MCD_MAIN_COMM_0,MCD_SUB_COMM_0			; Acknowledge command

.WaitMain:
	move.w	MCD_MAIN_COMM_0,d0				; Is the Main CPU ready?
	bne.s	.WaitMain					; If not, wait
	move.w	MCD_MAIN_COMM_0,d0
	bne.s	.WaitMain					; If not, wait

	move.w	#0,MCD_SUB_COMM_0				; Mark as ready for another command
	rts

; ------------------------------------------------------------------------------
; Wait for Word RAM access
; ------------------------------------------------------------------------------

WaitWordRamAccess:
	btst	#MCDR_DMNA_BIT,MCD_MEM_MODE			; Do we have Word RAM access?
	beq.s	WaitWordRamAccess				; If not, wait
	rts

; ------------------------------------------------------------------------------
