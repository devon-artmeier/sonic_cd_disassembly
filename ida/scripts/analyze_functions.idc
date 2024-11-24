extern DrawHudPosition;
extern DrawHudNumber;
extern ResetHudScore;
extern DrawHudScore;
extern ResetHudRings;
extern DrawHudRings;
extern DrawHudMinutes;
extern DrawHudSeconds;
extern DrawHudLives;
extern DrawHudBonus;
extern ResetHudNumber;
extern DrawHudHexNumber;
extern DrawHudCounter;
extern DrawContinueTimer;
extern LoadMapCollision;
extern VBlank;
extern HBlank;
extern ObjectIndex;
extern ArtListIndex;
extern MapIndex;
extern SectionRanges;
extern SectionInitArtLists;
extern SectionUpdateArtLists;
extern InitMapObjectSpawn;
extern UpdateMapObjectSpawn;
extern VBlankRoutines;
extern VBlankGeneral;
extern VBlankUpdates;
extern NullMapObjects;
extern CheckObjectDespawn2;
extern RunStageEvents;
extern StageEvents;
extern RunStageEventsR1;
extern RunStageEventsR3;
extern RunStageEventsR4;
extern RunStageEventsR5;
extern RunStageEventsR6;
extern RunStageEventsR7;
extern RunStageEventsR8;
extern RunStageEventsR13;
extern CheckBossStart;
extern SetBossBoundaries;
extern debug_speed;

static DefineKnownFunctions(void)
{
	if (file_id == 0 || file_id == 1 || file_id == 4 || file_id == 5) {
		StartFunction(0x200188, "CyclePaletteOld");
		StartFunction(0x200228, "DoCyclePalette");
	}
	
	DrawHudPosition = StartFuncFromOp(UpdateHud + 8, "DrawHudPosition", 0);
	DrawHudNumber = StartFuncFromOp(UpdateHud + 0x4E, "DrawHudNumber", 0);
	ResetHudScore = StartFuncFromOp(UpdateHud + 0x60, "ResetHudScore", 0);
	DrawHudScore = StartFuncFromOp(UpdateHud + 0x76, "DrawHudScore", 0);
	ResetHudRings = StartFuncFromOp(UpdateHud + 0x84, "ResetHudRings", 0);
	DrawHudRings = StartFuncFromOp(UpdateHud + 0xAC, "DrawHudRings", 0);
	DrawHudMinutes = StartFuncFromOp(UpdateHud + 0x114, "DrawHudMinutes", 0);
	DrawHudSeconds = StartFuncFromOp(UpdateHud + 0x126, "DrawHudSeconds", 0);
	DrawHudLives = StartFuncFromOp(UpdateHud + 0x16A, "DrawHudLives", 0);
	DrawHudBonus = StartFuncFromOp(UpdateHud + 0x194, "DrawHudBonus", 0);
	ResetHudNumber = StartFuncFromOp(ResetHudRings + 0x12, "ResetHudNumber", 0);
	DrawHudHexNumber = StartFuncFromOp(DrawHudPosition + 0xC, "DrawHudHexNumber", 0);
	DrawHudCounter = StartFunction(DrawHudScore + 8, "DrawHudCounter");
	DrawContinueTimer = StartFunction(DrawHudCounter + 0x58, "DrawContinueTimer");
	
	if (zone == 2) {
		LoadMapCollision = StartFunction(GlobalAnimations - 0xA, "LoadMapCollision");
	} else {
		LoadMapCollision = StartFunction(GlobalAnimations - 0x32, "LoadMapCollision");
	}
	
	auto idx, idx_2, count;
	
	SetMacro(0x200000, 0x100, "mmd 0, WORD_RAM_2M, 0, StartEntry, HBlankEntry, VBlankEntry");
	
	StartFunction(0x200100, "StartEntry");
	StartFunction(0x200106, "ErrorEntry");
	StartFunction(0x20010C, "HBlankEntry");
	StartFunction(0x200112, "VBlankEntry");
	StartFuncFromOp(0x200100, "Start", 0);
	StartFuncFromOp(0x200106, "Error", 0);
	HBlank = StartFuncFromOp(0x20010C, "HBlank", 0);
	VBlank = StartFuncFromOp(0x200112, "VBlank", 0);
	StartFuncFromOp(0x200166, "InitVdp", 0);
	StartFuncFromOp(0x20016A, "InitControllers", 0);
	StartFunction(0x200180, "GameModes");
	StartFuncFromOp(0x200180, "Stage", 0);
	StartFunction(0x200184, "CyclePalette");
	
	ObjectIndex = NameFromOp(UpdateObjects + 0x10, "ObjectIndex", 0);
	OpDecimal(UpdateObjects + 0x16, 0);
	
	ArtListIndex = NameFromOp(QueueArtList + 4, "ArtListIndex", 0);
	MapIndex = NameFromOp(LoadMapData + 2, "MapIndex", 0);
	
	debug_speed = MakeName(DebugMode + 0x190, "debug_speed");
	MakeName(DebugMode + 0x194, "DebugItemIndex");
	count = Byte(DebugMode + 0x194);
	MakeWord(DebugMode + 0x194);
	SetManualInsn(DebugMode + 0x194, "debugStart");
	for (idx = 0; idx < count; idx = idx + 1) {
		auto debug_item = DebugMode + 0x196 + (idx * 12);
		MakeStructEx(debug_item, -1, "debugItem");

		auto debug_spr = Dword(debug_item + 2);
		if ((substr(Name(debug_spr), 0, 4) != "Spr_") && (substr(Name(debug_spr), strlen(Name(debug_spr)) - 7, -1) != "Sprites")) {
			MakeName(debug_spr, "Spr_" + sprintf("%X", debug_spr));
			AnalyzeSprites(debug_spr, "@Spr_" + sprintf("%X", debug_spr), 0);
		}
	}

	for (idx = 0; idx < Word(ArtListIndex); idx = idx + 2) {
		auto art_list_start = SetTableOff(ArtListIndex, idx, "");

		if (idx == 0) {
			MakeName(art_list_start, "StageArtList");
		} else if (idx == 2) {
			MakeName(art_list_start, "StandardArtList");
		} else if (idx == 4) {
			MakeName(art_list_start, "Section0InitArtList");
		} else if (idx == 0x20) {
			MakeName(art_list_start, "ResultsArtList");
		} else if (idx == 0x24) {
			MakeName(art_list_start, "SignpostArtList");
		}
		
		if (time == 1) {
			if (idx == 8) {
				MakeName(art_list_start, "AnimalsArtList");
			} else if (idx == 0xA) {
				MakeName(art_list_start, "ProjectorAnimalsArtList");
			}
		}
		
		MakeWord(art_list_start);
		count = Word(art_list_start) + 1;
		for (idx_2 = 0; idx_2 < count; idx_2 = idx_2 + 1) {
			SetDwordPointer(art_list_start + 2 + (idx_2 * 6), "");
			MakeWord(art_list_start + 6 + (idx_2 * 6));
		}
	}
		
	if (LoadSectionArt > 0) {
		SectionRanges = NameFromOp(LoadSectionArt, "SectionRanges", 0);
		SectionInitArtLists = NameFromOp(LoadSectionArt + 0x1A, "SectionInitArtLists", 0);
		SectionUpdateArtLists = NameFromOp(UpdateSectionArt + 0x24, "SectionUpdateArtLists", 0);

		auto done = 0;
		auto section_count = 0;
		while (done == 0) {
			MakeWord(SectionRanges + (section_count * 2));
			if (Word(SectionRanges + (section_count * 2)) == 0xFFFF) {
				done = 1;
			}
			section_count = section_count + 1;
		}
		
		for (idx = 0; idx < section_count; idx = idx + 1) {
			MakeWord(SectionInitArtLists + (idx * 2));
			MakeWord(SectionUpdateArtLists + (idx * 2));
			
			auto plc_init = ArtListIndex + Word(ArtListIndex + (Word(SectionInitArtLists + (idx * 2)) * 2));
			auto plc_update = ArtListIndex + Word(ArtListIndex + (Word(SectionUpdateArtLists + (idx * 2)) * 2));
			
			if (substr(Name(plc_init), strlen(Name(plc_init)) - 7, -1) != "ArtList") {
				MakeName(plc_init, "Section" + sprintf("%X", idx) + "InitArtList");
			}
			if (substr(Name(plc_update), strlen(Name(plc_update)) - 7, -1) != "ArtList") {
				MakeName(plc_update, "Section" + sprintf("%X", idx) + "UpdateArtList");
			}
		}
	}
	
	InitMapObjectSpawn = SetTableOffFunc(SpawnMapObjects + 0xE, 0, "InitMapObjectSpawn");
	UpdateMapObjectSpawn = SetTableOffFunc(SpawnMapObjects + 0xE, 2, "UpdateMapObjectSpawn");
	
	SetTableOff(MapObjectsIndex, 0, "");
	NullMapObjects = SetTableOff(MapObjectsIndex, 2, "NullMapObjects");
	ForceFormattedWordArray(MapObjects - 8, 0, 4, 4, -1);
	ForceFormattedWordArray(NullMapObjects, 0, 3, 3, -1);
	
	for (idx = 0; idx < Word(MapLayoutIndex); idx = idx + 2) {
		SetTableOff(MapLayoutIndex, idx, "");
	}
	
	for (idx = PaletteIndex; idx < Dword(PaletteIndex); idx = idx + 8) {
		ForceDword(idx);
		OpOff(idx, 0, 0);
		ForceWord(idx + 4);
		ForceWord(idx + 6);
	}
	
	auto vblank_pos = VBlank;
	while (Word(vblank_pos) != 0x4EBB) {
		vblank_pos = vblank_pos + 2;
	}
	VBlankRoutines = NameFromOp(vblank_pos, "VBlankRoutines", 0);
	
	SetTableOffFunc(VBlankRoutines, 0, "VBlankLag");
	VBlankGeneral = SetTableOffFunc(VBlankRoutines, 2, "VBlankGeneral");
	SetTableOffFunc(VBlankRoutines, 4, "VBlankS1Title");
	SetTableOffFunc(VBlankRoutines, 6, "VBlankUnknown6");
	SetTableOffFunc(VBlankRoutines, 8, "VBlankStage");
	SetTableOffFunc(VBlankRoutines, 0xA, "VBlankS1SpecialStage");
	SetTableOffFunc(VBlankRoutines, 0xC, "VBlankStageLoad");
	SetTableOffFunc(VBlankRoutines, 0xE, "VBlankUnknownE");
	SetTableOffFunc(VBlankRoutines, 0x10, "VBlankPause");
	SetTableOffFunc(VBlankRoutines, 0x12, "VBlankFade");
	SetTableOffFunc(VBlankRoutines, 0x14, "VBlankS1Sega");
	SetTableOffFunc(VBlankRoutines, 0x16, "VBlankS1Continue");
	SetTableOffFunc(VBlankRoutines, 0x18, "VBlankStageLoad");
	
	VBlankUpdates = StartFuncFromOp(VBlankGeneral, "VBlankUpdates", 0);
	
	CheckObjectDespawn2 = CheckObjectDespawn + 4;

	idx = ObjectIndex;
	while (idx < NullObject) {
		SetDwordPointer(idx, "");
		idx = idx + 4;
	}
	
	if (WaterEvents > 0) {
		idx = WaterEvents + 0x2C;
		SetTableOffFunc(idx, 0, "WaterEventsAct1");
		SetTableOffFunc(idx, 2, "WaterEventsAct2");
		SetTableOffFunc(idx, 4, "WaterEventsAct3");
	}

	if (file_id == 0) {
		RunStageEvents = StartFuncFromOp(ScrollMap + 0x20, "RunStageEvents", 0);
	} else {
		RunStageEvents = StartFuncFromOp(ScrollMap + 0x24, "RunStageEvents", 0);
	}
	
	StageEvents = NameFromOp(RunStageEvents + 0xE, "StageEvents", 0);
	RunStageEventsR1 = SetTableOffFunc(StageEvents, 0, "RunStageEventsR1");
	RunStageEventsR3 = SetTableOffFunc(StageEvents, 2, "RunStageEventsR3");
	RunStageEventsR4 = SetTableOffFunc(StageEvents, 4, "RunStageEventsR4");
	RunStageEventsR5 = SetTableOffFunc(StageEvents, 6, "RunStageEventsR5");
	RunStageEventsR6 = SetTableOffFunc(StageEvents, 8, "RunStageEventsR6");
	RunStageEventsR7 = SetTableOffFunc(StageEvents, 0xA, "RunStageEventsR7");
	RunStageEventsR8 = SetTableOffFunc(StageEvents, 0xC, "RunStageEventsR8");

	auto events_table = NameFromOp(RunStageEventsR1 + 0xE, "StageEventsR1", 0);
	SetTableOffFunc(events_table, 0, "RunStageEventsR11");
	SetTableOffFunc(events_table, 2, "RunStageEventsR12");
	RunStageEventsR13 = SetTableOffFunc(events_table, 4, "RunStageEventsR13");

	events_table = NameFromOp(RunStageEventsR3 + 0xE, "StageEventsR3", 0);
	SetTableOffFunc(events_table, 0, "RunStageEventsR312");
	SetTableOff(events_table, 2, "");
	SetTableOffFunc(events_table, 4, "RunStageEventsR33");

	events_table = NameFromOp(RunStageEventsR4 + 0xE, "StageEventsR4", 0);
	SetTableOffFunc(events_table, 0, "RunStageEventsR41");
	SetTableOffFunc(events_table, 2, "RunStageEventsR42");
	SetTableOffFunc(events_table, 4, "RunStageEventsR43");

	events_table = NameFromOp(RunStageEventsR5 + 0xE, "StageEventsR5", 0);
	SetTableOffFunc(events_table, 0, "RunStageEventsR512");
	SetTableOff(events_table, 2, "");
	SetTableOffFunc(events_table, 4, "RunStageEventsR53");

	events_table = NameFromOp(RunStageEventsR7 + 0xE, "StageEventsR7", 0);
	SetTableOffFunc(events_table, 0, "RunStageEventsR71");
	SetTableOffFunc(events_table, 2, "RunStageEventsR72");
	SetTableOffFunc(events_table, 4, "RunStageEventsR73");

	events_table = NameFromOp(RunStageEventsR8 + 0xE, "StageEventsR8", 0);
	SetTableOffFunc(events_table, 0, "RunStageEventsR812");
	SetTableOff(events_table, 2, "");
	SetTableOffFunc(events_table, 4, "RunStageEventsR83");
	
	CheckBossStart = StartFuncFromOp(RunStageEventsR13 + 0x14, "CheckBossStart", 0);
	SetBossBoundaries = StartFuncFromOp(CheckBossStart + 4, "SetBossBoundaries", 0);
}
