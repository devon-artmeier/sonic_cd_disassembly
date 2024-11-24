extern table_id, addrs, tables, start_addr, end_addr, addr_ranges, cur_object_idx, obj_spawn;

extern MapCollideSpecial;
extern ObjectCollide;
extern BigRingFlashObject;
extern MonitorObject;
extern TimeObject;
extern TimePostObject;
extern TimeIconObject;
extern ObjHud;
extern ObjPoints;
extern UnkSpringObject;
extern CheckObjectDespawn2;

static CheckObjAddr(addr_1, addr_2)
{
	if (addr_1 < start_addr) {
		start_addr = addr_1;
		SetArrayLong(addr_ranges, (cur_object_idx * 3) + 0, start_addr);
	}
	if (addr_2 > end_addr) {
		end_addr = addr_2;
		SetArrayLong(addr_ranges, (cur_object_idx * 3) + 1, end_addr);
	}
}

static CheckObjOpObj(addr, op, op_id)
{
	if (strlen(op) > 4) {
		auto op_indir = substr(op, strlen(op) - 4, strlen(op));
		if (op_indir == "(a0)") {
			OpStroff(addr, op_id, obj_struct);
		} else if (obj_spawn != 0 && op_indir == "(a1)") {
			OpStroff(addr, op_id, obj_struct);
		}
	}
}

static CheckObjFunction(addr) {
	return  (addr < ObjectIndex) ||
		(addr == PlaceMapBlock) ||
		(addr == QueueArtList) ||
		(addr == InitArtQueue) ||
		(addr == LoadArtList) ||
		(addr == DecompressNemesisVdp) ||
		(addr == DecompressNemesis) ||
		(addr == DecompressEnigma);
}

static SetTableOffset(addr, idx)
{
	ForceWord(addr + idx);
	OpOffEx(addr + idx, 0, REF_OFF32, -1, addr, 0);
	return addr + Word(addr + idx);
}

static AnalyzeObjTable(addr, name, id)
{
	if (GetArrayElement(AR_LONG, tables, addr) != 69) {
		SetArrayLong(tables, addr, 69);
		
		auto idx = 0;
		auto done = 0;
		
		while (done == 0) {
			if (idx > 0 && Name(addr + idx) != "") {
				done = 1;
			} else if ((name == "RingObject" && idx >= 0xA) ||
			           (name == "TunnelDoorVObject" && idx >= 6)) {
				done = 1;
			} else {
				if (Word(addr + idx) < 0x8000) {
					auto off = SetTableOffset(addr, idx);
					if (substr(Name(off), 0, strlen(name)) != name) {
						StartFunction(off, name + "_" + sprintf("%X", id) + "_Routine" + sprintf("%X", idx));
					}
					AnalyzeObjCode(off, name);
					idx = idx + 2;
				} else {
					done = 1;
				}
			}
		}
	}
}

static AnalyzeDataTable(addr, name)
{
	auto idx = 0;
	auto done = 0;
	
	while (done == 0) {
		if (idx > 0 && Name(addr + idx) != "") {
			done = 1;
		} else {
			auto off = SetTableOffset(addr, idx);
			if (substr(Name(off), 0, strlen(name)) != name) {
				MakeName(off, name + "_" + sprintf("%X", idx));
			}
			idx = idx + 2;
		}
	}
}

static AnalyzeObjCode(addr, name)
{
	auto done = 0;
	if (addr < 0x200000 || addr >= 0x210000) {
		done = 1;
	}
	
	while (done == 0) {
		auto insLen = MakeCode(addr);
		auto ins = GetMnem(addr);
		auto op1 = GetOpnd(addr, 0);
		auto op2 = GetOpnd(addr, 1);
		auto branch;
		Wait();
		CheckObjAddr(addr, addr + insLen);
		
		SetArrayLong(addrs, addr, 69);
	
		CheckObjOpObj(addr, op1, 0);
		CheckObjOpObj(addr, op2, 1);
		
		if (ins == "bra" || ins == "jmp" || ins == "bra.s" || ins == "bra.w") {
			if (GetOpType(addr, 0) != o_displ) {
				branch = LocByName(GetOpnd(addr, 0));
				if (branch != BADADDR) {
					if (!CheckObjFunction(branch) && GetArrayElement(AR_LONG, addrs, branch) != 69) {
						addr = branch - insLen;
					} else {
						done = 1;
					}
				}
			} else {
				table_id = table_id + 1;
				AnalyzeObjTable(LocByName(GetOpnd(addr, 0)), name, table_id);
				done = 1;
			}
		} else if (ins == "rts" || ins == "rte" || ins == "rtr") {
			done = 1;
		} else  {
			// I hate this, but I'm lazy.
			auto branch_type = 0;
			if (ins == "b" || ins == "bsr" || ins == "jsr" || ins == "bsr.s" || ins == "bsr.w" ||
				ins == "bcc.s" || ins == "bcs.s" || ins == "beq.s" || ins == "bge.s" ||
				ins == "bgt.s" || ins == "bhi.s" || ins == "ble.s" || ins == "bls.s" ||
				ins == "blt.s" || ins == "bmi.s" || ins == "bne.s" || ins == "bpl.s" ||
				ins == "bvc.s" || ins == "bvs.s" || ins == "bhs.s" || ins == "blo.s" ||
				ins == "bcc.w" || ins == "bcs.w" || ins == "beq.w" || ins == "bge.w" ||
				ins == "bgt.w" || ins == "bhi.w" || ins == "ble.w" || ins == "bls.w" ||
				ins == "blt.w" || ins == "bmi.w" || ins == "bne.w" || ins == "bpl.w" ||
				ins == "bvc.w" || ins == "bvs.w" || ins == "bhs.w" || ins == "blo.w") {
				branch_type = 1;
			} else if (ins == "db" ||
				ins == "dbcc" || ins == "dbcs" || ins == "dbeq" || ins == "dbge" ||
				ins == "dbgt" || ins == "dbhi" || ins == "dble" || ins == "dbls" ||
				ins == "dblt" || ins == "dbmi" || ins == "dbne" || ins == "dbpl" ||
				ins == "dbvc" || ins == "dbvs" || ins == "dbf" || ins == "dbt" ||
				ins == "dbhs" || ins == "dblo" || ins == "dbra") {
				branch_type = 2;
			}
			
			if (branch_type > 0) {
				if (GetOpType(addr, 0) != o_displ) {
					if (branch_type == 2) {
						branch = LocByName(GetOpnd(addr, 1));
					} else {
						branch = LocByName(GetOpnd(addr, 0));
					}
					if (branch != BADADDR) {
						if (!CheckObjFunction(branch) && GetArrayElement(AR_LONG, addrs, branch) != 69) {
							AnalyzeObjCode(branch, name);
						}
						if (branch == SpawnObject || branch == SpawnObjectAfter) {
							obj_spawn = 1;
						}
					}
				} else {
					table_id = table_id + 1;
					AnalyzeObjTable(LocByName(GetOpnd(addr, 0)), name, table_id);
				}
			}
		}
		
		addr = addr + insLen;
	}
}

static AnalyzeObject(addr, name)
{
	table_id = -1;
	obj_spawn = 0;
	
	DeleteArray(GetArrayId("addrs"));
	DeleteArray(GetArrayId("tables"));
	addrs = CreateArray("addrs");
	tables = CreateArray("tables");
	
	start_addr = addr;
	end_addr = addr;
	
	SetArrayLong(addr_ranges, (cur_object_idx * 3) + 0, start_addr);
	SetArrayLong(addr_ranges, (cur_object_idx * 3) + 1, end_addr);
	SetArrayString(addr_ranges, (cur_object_idx * 3) + 2, name);
	
	MakeName(addr, name);
	AnalyzeObjCode(addr, name);
	Wait();
	
	DeleteArray(addrs);
	DeleteArray(tables);
	
	cur_object_idx = cur_object_idx + 1;
	
	return addr;
}

static InitObjectDefine(void)
{
	MapCollideSpecial = 0;
	ObjectCollide = 0;
	BigRingFlashObject = 0;
	MonitorObject = 0;
	TimeObject = 0;
	TimePostObject = 0;
	TimeIconObject = 0;
	ObjHud = 0;
	ObjPoints = 0;
	UnkSpringObject = 0;
	CheckObjectDespawn2 = 0;
	
	CheckObjectDespawn2 = CheckObjectDespawn + 4;
	MakeName(CheckObjectDespawn2, "CheckObjectDespawn2");
	
	cur_object_idx = 0;
	DeleteArray(GetArrayId("addr_ranges"));
	addr_ranges = CreateArray("addr_ranges");
}

static FinishObjectDefine(void)
{
	DeleteArray(addr_ranges);
}

static AnalyzeSonic(void)
{
	auto SonicInitState, SonicMainState, SonicHurtState, SonicDeadState, SonicRestartState;
	auto SonicGroundMode, SonicAirMode, SonicRollMode, SonicJumpMode;
	auto CheckTimeWarp, SonicModes, SonicMoveGround, AnimateSonic;
	auto SonicMoveRoll, SonicCheckJump, PlayerAirCollision;
	
	auto index_loc;
	index_loc = 0x54;
	
	SonicInitState = SonicObject + index_loc + Word(SonicObject + index_loc + 0);
	SonicMainState = SonicObject + index_loc + Word(SonicObject + index_loc + 2);
	SonicHurtState = SonicObject + index_loc + Word(SonicObject + index_loc + 4);
	SonicDeadState = SonicObject + index_loc + Word(SonicObject + index_loc + 6);
	SonicRestartState = SonicObject + index_loc + Word(SonicObject + index_loc + 8);
	
	StartFuncFromOp(SonicMainState, "ExtendedCamera", 0);
	StartFuncFromOp(SonicMainState + 2, "MakeWaterfallSplash", 0);
	
	if (zone != 4) {
		CheckTimeWarp = StartFuncFromOp(SonicMainState + 0x4A, "CheckTimeWarp", 0);
		SonicModes = NameFromOp(SonicMainState + 0x5A, "SonicModes", 0);
		MapCollideSpecial = StartFuncFromOp(SonicMainState + 0x62, "MapCollideSpecial", 0);
		StartFuncFromOp(SonicMainState + 0x68, "DrawSonic", 0);
		StartFuncFromOp(SonicMainState + 0x6A, "RecordSonicPosition", 0);
		StartFuncFromOp(SonicMainState + 0x6E, "SonicWater", 0);
		AnimateSonic = StartFuncFromOp(SonicMainState + 0x90, "AnimateSonic", 0);
		ObjectCollide = StartFuncFromOp(SonicMainState + 0xA2, "ObjectCollide", 0);
		StartFuncFromOp(SonicMainState + 0xA8, "CheckPlayerMapChunk", 0);
	} else {
		CheckTimeWarp = StartFuncFromOp(SonicMainState + 0x34, "CheckTimeWarp", 0);
		SonicModes = NameFromOp(SonicMainState + 0x44, "SonicModes", 0);
		StartFuncFromOp(SonicMainState + 0x4C, "CheckBouncyFloor", 0);
		StartFuncFromOp(SonicMainState + 0x50, "CheckSparks", 0);
		StartFuncFromOp(SonicMainState + 0x54, "CheckElectricBeam", 0);
		StartFuncFromOp(SonicMainState + 0x58, "CheckHangBar", 0);
		StartFuncFromOp(SonicMainState + 0x5C, "CheckRotatePole", 0);
		
		StartFuncFromOp(SonicMainState + 0x60, "DrawSonic", 0);
		StartFuncFromOp(SonicMainState + 0x62, "RecordSonicPosition", 0);
		AnimateSonic = StartFuncFromOp(SonicMainState + 0x72, "AnimateSonic", 0);
		ObjectCollide = StartFuncFromOp(SonicMainState + 0x84, "ObjectCollide", 0);
		StartFuncFromOp(SonicMainState + 0x8A, "CheckPlayerMapChunk", 0);
	}
	
	SonicGroundMode = SonicModes + Word(SonicModes + 0);
	SonicAirMode = SonicModes + Word(SonicModes + 2);
	SonicRollMode = SonicModes + Word(SonicModes + 4);
	SonicJumpMode = SonicModes + Word(SonicModes + 6);

	if (zone != 4) {
		StartFuncFromOp(SonicGroundMode, "CheckBoredom", 0);
		StartFuncFromOp(SonicGroundMode + 0x26, "CheckMapBoundaries", 0);
		StartFuncFromOp(SonicGroundMode + 0x30, "Handle3dRamp", 0);
		SonicCheckJump = StartFuncFromOp(SonicGroundMode + 0x38, "SonicCheckJump", 0);
		StartFuncFromOp(SonicGroundMode + 0x3C, "SonicSlopeResist", 0);
		SonicMoveGround = StartFuncFromOp(SonicGroundMode + 0x40, "SonicMoveGround", 0);
		StartFuncFromOp(SonicGroundMode + 0x44, "SonicCheckRoll", 0);
		StartFuncFromOp(SonicGroundMode + 0x56, "SonicCheckFall", 0);
		
		StartFuncFromOp(SonicAirMode + 0x22, "SonicJumpHeight", 0);
		StartFuncFromOp(SonicAirMode + 0x26, "SonicMoveAir", 0);
		StartFuncFromOp(SonicAirMode + 0x42, "SonicResetAirAngle", 0);
		PlayerAirCollision = StartFuncFromOp(SonicAirMode + 0x46, "PlayerAirCollision", 0);
		
		StartFuncFromOp(CheckTimeWarp + 0xAC, "SaveTimeWarpData", 0);
		StartFuncFromOp(CheckTimeWarp + 0xC2, "MakeTimeWarpStars", 0);
		
		StartFuncFromOp(SonicMoveGround + 0x2B8, "SonicStartRoll", 0);
		StartFunction(SonicMoveGround + 0x348, "PlayerWallCollision");
	} else {
		StartFuncFromOp(SonicGroundMode + 0x12, "CheckBoredom", 0);
		StartFuncFromOp(SonicGroundMode + 0x38, "CheckMapBoundaries", 0);
		StartFuncFromOp(SonicGroundMode + 0x42, "Handle3dRamp", 0);
		SonicCheckJump = StartFuncFromOp(SonicGroundMode + 0x4A, "SonicCheckJump", 0);
		StartFuncFromOp(SonicGroundMode + 0x4E, "SonicSlopeResist", 0);
		SonicMoveGround = StartFuncFromOp(SonicGroundMode + 0x52, "SonicMoveGround", 0);
		StartFuncFromOp(SonicGroundMode + 0x56, "SonicCheckRoll", 0);
		StartFuncFromOp(SonicGroundMode + 0x68, "SonicCheckFall", 0);
		
		StartFuncFromOp(SonicAirMode + 0x1C, "SonicHangBar", 0);
		StartFuncFromOp(SonicAirMode + 0x2A, "SonicJumpHeight", 0);
		StartFuncFromOp(SonicAirMode + 0x2E, "SonicMoveAir", 0);
		StartFuncFromOp(SonicAirMode + 0x4A, "SonicResetAirAngle", 0);
		PlayerAirCollision = StartFuncFromOp(SonicAirMode + 0x4E, "PlayerAirCollision", 0);
		
		StartFuncFromOp(SonicJumpMode + 8, "SonicRotatePole", 0);
	
		StartFuncFromOp(CheckTimeWarp + 0x86, "SaveTimeWarpData", 0);
		StartFuncFromOp(CheckTimeWarp + 0x98, "MakeTimeWarpStars", 0);
		
		StartFuncFromOp(SonicMoveGround + 0x2A0, "SonicStartRoll", 0);
		StartFunction(SonicMoveGround + 0x348, "PlayerWallCollision");
	}
	
	StartFuncFromOp(SonicRollMode + 0xC, "SonicSlopeResistRoll", 0);
	SonicMoveRoll = StartFuncFromOp(SonicRollMode + 0x10, "SonicMoveRoll", 0);
	
	StartFuncFromOp(SonicMoveGround + 0x24, "SonicObject_MoveGndLeft", 0);
	StartFuncFromOp(SonicMoveGround + 0x30, "SonicObject_MoveGndRight", 0);
	
	StartFuncFromOp(SonicMoveRoll + 0x28, "SonicMoveRollLeft", 0);
	StartFuncFromOp(SonicMoveRoll + 0x34, "SonicMoveRollRight", 0);
	
	StartFuncFromOp(SonicCheckJump + 0x2E, "CheckFlipper", 0);
	StartFuncFromOp(PlayerAirCollision + 0x64, "MapCollideDownWide", 0);
	StartFuncFromOp(PlayerAirCollision + 0xFE, "MapCollideUpWide", 0);
	StartFuncFromOp(PlayerAirCollision + 0x18E, "GroundPlayerSteep", 0);
	StartFuncFromOp(PlayerMapCollideAbove + 0x14, "MapCollideLeftWide", 0);
	StartFuncFromOp(PlayerMapCollideAbove + 0x24, "MapCollideRightWide", 0);
	
	Rename("@SonicAnims_0", "SonicWalkAnim");
	Rename("@SonicAnims_1", "SonicRunAnim");
	Rename("@SonicAnims_2", "SonicRollAnim");
	Rename("@SonicAnims_3", "SonicRollFastAnim");
	Rename("@SonicAnims_4", "SonicPushAnim");
	Rename("@SonicAnims_5", "SonicIdleAnim");
	Rename("@SonicAnims_6", "SonicBalanceAnim");
	Rename("@SonicAnims_7", "SonicLookUpAnim");
	Rename("@SonicAnims_8", "SonicDuckAnim");
	Rename("@SonicAnims_9", "SonicS1Warp1Anim");
	Rename("@SonicAnims_A", "SonicS1Warp2Anim");
	Rename("@SonicAnims_B", "SonicS1Warp3Anim");
	Rename("@SonicAnims_C", "SonicS1Warp4Anim");
	Rename("@SonicAnims_D", "SonicSkidAnim");
	Rename("@SonicAnims_E", "SonicS1Float1Anim");
	Rename("@SonicAnims_F", "SonicFloatAnim");
	Rename("@SonicAnims_10", "SonicSpringAnim");
	Rename("@SonicAnims_11", "SonicHangAnim");
	Rename("@SonicAnims_12", "SonicS1Leap1Anim");
	Rename("@SonicAnims_13", "SonicS1Leap2Anim");
	Rename("@SonicAnims_14", "SonicS1SurfAnim");
	Rename("@SonicAnims_15", "SonicBubbleAnim");
	Rename("@SonicAnims_16", "SonicDeathBwAnim");
	Rename("@SonicAnims_17", "SonicDrownAnim");
	Rename("@SonicAnims_18", "SonicDeathAnim");
	Rename("@SonicAnims_19", "SonicS1ShrinkAnim");
	Rename("@SonicAnims_1A", "SonicHurtAnim");
	Rename("@SonicAnims_1B", "SonicSlideAnim");
	Rename("@SonicAnims_1C", "SonicBlankAnim");
	Rename("@SonicAnims_1D", "SonicS1Float3Anim");
	Rename("@SonicAnims_1E", "SonicS1Float4Anim");
	Rename("@SonicAnims_1F", "SonicIdleMiniAnim");
	Rename("@SonicAnims_20", "SonicDuckMiniAnim");
	Rename("@SonicAnims_21", "SonicWalkMiniAnim");
	Rename("@SonicAnims_22", "SonicRunMiniAnim");
	Rename("@SonicAnims_23", "SonicRollMiniAnim");
	Rename("@SonicAnims_24", "SonicSkidMiniAnim");
	Rename("@SonicAnims_25", "SonicHurtMiniAnim");
	Rename("@SonicAnims_26", "SonicBalanceMiniAnim");
	Rename("@SonicAnims_27", "SonicPushMiniAnim");
	Rename("@SonicAnims_28", "SonicStandMiniAnim");
	Rename("@SonicAnims_29", "SonicLookBackAnim");
	Rename("@SonicAnims_2A", "SonicSneezeAnim");
	Rename("@SonicAnims_2B", "SonicGiveUpAnim");
	Rename("@SonicAnims_2C", "SonicHang2Anim");
	Rename("@SonicAnims_2D", "SonicStandRotateAnim");
	Rename("@SonicAnims_2E", "SonicWadeAnim");
	Rename("@SonicAnims_2F", "SonicFloat2Anim");
	Rename("@SonicAnims_30", "SonicGiveUpMiniAnim");
	Rename("@SonicAnims_31", "SonicPeeloutAnim");
	Rename("@SonicAnims_32", "SonicBalance2Anim");
	Rename("@SonicAnims_33", "SonicRotateBackAnim");
	Rename("@SonicAnims_34", "SonicRotateFrontAnim");
	Rename("@SonicAnims_35", "SonicRun3dAnim");
	Rename("@SonicAnims_36", "SonicRoll3dAnim");
	Rename("@SonicAnims_37", "SonicFallAwayAnim");
	Rename("@SonicAnims_38", "SonicGrowAnim");
	Rename("@SonicAnims_39", "SonicShrinkAnim");
	if (zone != 4) {
		Rename("@SonicAnims_3A", "SonicRoll3dAnim");
	} else {
		Rename("@SonicAnims_3A", "SonicBoosterAnim");
	}
}

static DefineKnownObjects(void)
{
	// Sonic
	Rename("SonicObject_0_Routine0", "SonicInitState");
	Rename("SonicObject_0_Routine2", "SonicMainState");
	Rename("SonicObject_0_Routine4", "SonicHurtState");
	Rename("SonicObject_0_Routine6", "SonicDeadState");
	Rename("SonicObject_0_Routine8", "SonicRestartState");
	Rename("SonicObject_1_Routine0", "SonicGroundMode");
	Rename("SonicObject_1_Routine2", "SonicAirMode");
	Rename("SonicObject_1_Routine4", "SonicRollMode");
	Rename("SonicObject_1_Routine6", "SonicJumpMode");
	AnalyzeSonic();
	
	// HUD/Points
	Rename("HudPointsObject_0_Routine0", "PointsInitState");
	Rename("HudPointsObject_0_Routine2", "PointsMainState");
	Rename("HudPointsObject_1_Routine0", "HudInitState");
	Rename("HudPointsObject_1_Routine2", "HudMainState");
	if (HudPointsObject > 0) {
		ObjPoints = StartFuncFromOp(HudPointsObject + 4, "ObjPoints", 0);
		ObjHud = StartFunction(HudPointsObject + 8, "ObjHud");
	}
	
	// Results
	Rename("ResultsObject_0_Routine0", "ResultsInitState");
	Rename("ResultsObject_0_Routine2", "ResultsWaitPlcState");
	Rename("ResultsObject_0_Routine4", "ResultsMoveState");
	Rename("ResultsObject_0_Routine6", "ResultsBonusState");
	Rename("ResultsObject_0_Routine8", "ResultsDoneState");
	
	// Powerup
	Rename("PowerupObject_0_Routine0", "PowerupInitState");
	Rename("PowerupObject_0_Routine2", "PowerupShieldState");
	Rename("PowerupObject_0_Routine4", "PowerupInvincibleState");
	Rename("PowerupObject_0_Routine6", "PowerupTimeWarpState");
	
	// Ring
	Rename("RingObject_0_Routine0", "RingInitState");
	Rename("RingObject_0_Routine2", "RingMainState");
	Rename("RingObject_0_Routine4", "RingCollectState");
	Rename("RingObject_0_Routine6", "RingSparkleState");
	Rename("RingObject_0_Routine8", "RingDeleteState");
	
	// Lost ring
	Rename("LostRingObject_0_Routine0", "LostRingInitState");
	Rename("LostRingObject_0_Routine2", "LostRingMainState");
	Rename("LostRingObject_0_Routine4", "LostRingCollectState");
	Rename("LostRingObject_0_Routine6", "LostRingSparkleState");
	Rename("LostRingObject_0_Routine8", "LostRingDeleteState");
	
	// Monitor/Time post
	Rename("MonitorTimeObject_0_Routine0", "TimeIconInitState");
	Rename("MonitorTimeObject_0_Routine2", "TimeIconMainState");
	Rename("MonitorTimeObject_1_Routine0", "TimePostInitState");
	Rename("MonitorTimeObject_1_Routine2", "TimePostWaitState");
	Rename("MonitorTimeObject_1_Routine4", "TimePostSpinState");
	Rename("MonitorTimeObject_1_Routine6", "TimePostDoneState");
	Rename("MonitorTimeObject_2_Routine0", "MonitorInitState");
	Rename("MonitorTimeObject_2_Routine2", "MonitorMainState");
	Rename("MonitorTimeObject_2_Routine4", "MonitorBreakState");
	Rename("MonitorTimeObject_2_Routine6", "MonitorAnimateState");
	Rename("MonitorTimeObject_2_Routine8", "MonitorDrawState");
	if (MonitorTimeObject > 0) {
		MonitorObject = StartFuncFromOp(MonitorTimeObject + 4, "MonitorObject", 0);
		TimeObject = StartFuncFromOp(MonitorObject + 6, "TimeObject", 0);
		TimeIconObject = StartFuncFromOp(TimeObject + 0x14, "TimeIconObject", 0);
		TimePostObject = StartFunction(TimeObject + 0x18, "TimePostObject");
	}
	
	// Monitor item
	Rename("MonitorItemObject_0_Routine0", "MonitorItemInitState");
	Rename("MonitorItemObject_0_Routine2", "MonitorItemMainState");
	Rename("MonitorItemObject_0_Routine4", "MonitorItemDeleteState");
	
	// Moving spring
	Rename("MoveSpringObject_0_Routine0", "MoveSpringInitState");
	Rename("MoveSpringObject_0_Routine2", "MoveSpringFallState");
	Rename("MoveSpringObject_0_Routine4", "MoveSpringMainState");
	
	// Spring
	Rename("SpringObject_0_Routine0", "UnkSpringInitState");
	Rename("SpringObject_0_Routine2", "UnkSpringMainState");
	Rename("SpringObject_1_Routine0", "SpringInitState");
	Rename("SpringObject_1_Routine2", "SpringUpMainState");
	Rename("SpringObject_1_Routine4", "SpringUpAnimateState");
	Rename("SpringObject_1_Routine6", "SpringUpResetState");
	Rename("SpringObject_1_Routine8", "SpringSideMainState");
	Rename("SpringObject_1_RoutineA", "SpringSideAnimateState");
	Rename("SpringObject_1_RoutineC", "SpringSideResetState");
	Rename("SpringObject_1_RoutineE", "SpringDownMainState");
	Rename("SpringObject_1_Routine10", "SpringDownAnimateState");
	Rename("SpringObject_1_Routine12", "SpringDownResetState");
	Rename("SpringObject_1_Routine14", "SpringDiagMainState");
	Rename("SpringObject_1_Routine16", "SpringDiagAnimateState");
	Rename("SpringObject_1_Routine18", "SpringDiagResetState");
	if (SpringObject > 0) {
		UnkSpringObject = StartFuncFromOp(SpringObject + 6, "UnkSpringObject", 0);
	}
	
	// Test badnik
	Rename("TestBadnikObject_0_Routine0", "TestBadnikInitState");
	Rename("TestBadnikObject_0_Routine2", "TestBadnikMainState");
	
	// Boulder
	Rename("BoulderObject_0_Routine0", "BoulderInitState");
	Rename("BoulderObject_0_Routine2", "BoulderMainState");
	
	// Checkpoint
	Rename("CheckpointObject_0_Routine0", "CheckpointInitState");
	Rename("CheckpointObject_0_Routine2", "CheckpointMainState");
	Rename("CheckpointObject_0_Routine4", "CheckpointBallState");
	Rename("CheckpointObject_0_Routine6", "CheckpointAnimateState");

	// Explosion
	Rename("ExplosionObject_0_Routine0", "ExplosionInitState");
	Rename("ExplosionObject_0_Routine2", "ExplosionMainState");
	Rename("ExplosionObject_0_Routine4", "ExplosionDoneState");

	// Flower
	Rename("FlowerObject_0_Routine0", "FlowerInitState");
	Rename("FlowerObject_0_Routine2", "FlowerSeedState");
	Rename("FlowerObject_0_Routine4", "FlowerAnimateState");
	Rename("FlowerObject_0_Routine6", "FlowerGrowState");
	Rename("FlowerObject_0_Routine8", "FlowerDoneState");
	
	// Flower capsule
	Rename("CapsuleObject_0_Routine0", "CapsuleInitState");
	Rename("CapsuleObject_0_Routine2", "CapsuleMainState");
	Rename("CapsuleObject_0_Routine4", "CapsuleExplodeState");
	Rename("CapsuleObject_0_RoutineA", "CapsuleSeedState");
	
	// Big ring
	Rename("BigRingObject_0_Routine0", "BigRingFlashInitState");
	Rename("BigRingObject_0_Routine2", "BigRingFlashAnimateState");
	Rename("BigRingObject_0_Routine4", "BigRingFlashDeleteState");
	Rename("BigRingObject_1_Routine0", "BigRingInitState");
	Rename("BigRingObject_1_Routine2", "BigRingMainState");
	Rename("BigRingObject_1_Routine4", "BigRingAnimateState");
	if (BigRingObject > 0) {
		BigRingFlashObject = StartFuncFromOp(BigRingObject + 4, "BigRingFlashObject", 0);
	}
	
	// Goal post
	Rename("GoalObject_0_Routine0", "GoalInitState");
	Rename("GoalObject_0_Routine2", "GoalMainState");
	Rename("GoalObject_0_Routine4", "GoalDoneState");
	
	// Signpost
	Rename("SignpostObject_0_Routine0", "SignpostInitState");
	Rename("SignpostObject_0_Routine2", "SignpostMainState");
	Rename("SignpostObject_0_Routine4", "SignpostSpinState");
	Rename("SignpostObject_0_Routine6", "StartResults");
	Rename("SignpostObject_0_Routine8", "ResultsActive");

	// Robot generator
	Rename("RobotGeneratorObject_0_Routine0", "RobotGenInitState");
	Rename("RobotGeneratorObject_0_Routine2", "RobotGenMainState");
	Rename("RobotGeneratorObject_0_Routine4", "RobotGenExplodeState");
	Rename("RobotGeneratorObject_0_Routine6", "RobotGenDestroyedState");

	// Game over
	Rename("GameOverObject_0_Routine0", "GameOverInitState");
	Rename("GameOverObject_0_Routine2", "GameOverMainState");
	
	// Title card
	Rename("TitleCardObject_0_Routine0", "TitleCardInitState");
	Rename("TitleCardObject_0_Routine2", "TitleCardSlideInVState");
	Rename("TitleCardObject_0_Routine4", "TitleCardSlideInHState");
	Rename("TitleCardObject_0_Routine6", "TitleCardSlideOutVState");
	Rename("TitleCardObject_0_Routine8", "TitleCardSlideOutHState");
	Rename("TitleCardObject_0_RoutineA", "TitleCardWaitState");
}
