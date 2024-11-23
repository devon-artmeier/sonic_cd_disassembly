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
extern VBlankGeneral;
extern VBlankUpdates;
extern NullMapObjects;
extern CheckObjectDespawn2;
extern debug_speed;
extern section_count;

static DefineMisc(void)
{
	auto idx, idx_2, count;
	
	VBlank = 0;
	HBlank = 0;
	ObjectIndex = 0;
	ArtListIndex = 0;
	MapIndex = 0;
	SectionRanges = 0;
	SectionInitArtLists = 0;
	SectionUpdateArtLists = 0;
	InitMapObjectSpawn = 0;
	UpdateMapObjectSpawn = 0;
	VBlankGeneral = 0;
	VBlankUpdates = 0;
	NullMapObjects = 0;
	CheckObjectDespawn2 = 0;
	debug_speed = 0;
	section_count = 0;
	
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

		auto debugMap = Dword(debug_item + 2);
		if ((substr(Name(debugMap), 0, 4) != "Spr_") && (substr(Name(debugMap), strlen(Name(debugMap)) - 7, -1) != "Sprites")) {
			MakeName(debugMap, "Spr_" + sprintf("%X", debugMap));
			AnalyzeMappings(debugMap, "@Spr_" + sprintf("%X", debugMap), 0);
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
		section_count = 0;
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
	
	auto vblankPos = VBlank;
	while (Word(vblankPos) != 0x4EBB) {
		vblankPos = vblankPos + 2;
	}
	auto vintTable = NameFromOp(vblankPos, "VBlankRoutines", 0);
	
	SetTableOffFunc(vintTable, 0, "VBlankLag");
	VBlankGeneral = SetTableOffFunc(vintTable, 2, "VBlankGeneral");
	SetTableOffFunc(vintTable, 4, "VBlankS1Title");
	SetTableOffFunc(vintTable, 6, "VBlankUnknown6");
	SetTableOffFunc(vintTable, 8, "VBlankStage");
	SetTableOffFunc(vintTable, 0xA, "VBlankS1SpecialStage");
	SetTableOffFunc(vintTable, 0xC, "VBlankStageLoad");
	SetTableOffFunc(vintTable, 0xE, "VBlankUnknownE");
	SetTableOffFunc(vintTable, 0x10, "VBlankPause");
	SetTableOffFunc(vintTable, 0x12, "VBlankFade");
	SetTableOffFunc(vintTable, 0x14, "VBlankS1Sega");
	SetTableOffFunc(vintTable, 0x16, "VBlankS1Continue");
	SetTableOffFunc(vintTable, 0x18, "VBlankStageLoad");
	
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
}
