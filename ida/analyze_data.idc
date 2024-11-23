static AnalyzeSprites(addr, name, entry_count)
{
	auto idx, off;
	if (entry_count == 0) {
		entry_count = 256;
	}
	for (idx = 0; idx < entry_count * 2; idx = idx + 2) {
		if (idx > 0 && strlen(Name(addr + idx)) > 0) {
			entry_count = idx / 2;
			break;
		}
		off = SetTableOffset(addr, idx);
		if (substr(Name(off), 0, strlen(name)) != name) {
			MakeName(off, name + "_" + sprintf("%X", idx / 2));
		}
	}

	for (idx = 0; idx < entry_count * 2; idx = idx + 2) {
		off = addr + Word(addr + idx);
		auto count = Byte(off);
		if (count >= 0x80 || count < 0) {
			count = 0;
		}
		ForceByte(off);
		auto spr;
		for (spr = off + 1; spr < off + 1 + (5 * count); spr = spr + 5) {
			ForceFormattedArray(spr, 0, 5, 5, -1);
		}
	}
}

static AnalyzeDplcs(addr, name, entry_count)
{
	auto idx, off;
	if (entry_count == 0) {
		entry_count = 256;
	}
	for (idx = 0; idx < entry_count * 2; idx = idx + 2) {
		if (idx > 0 && strlen(Name(addr + idx)) > 0) {
			entry_count = idx / 2;
			break;
		}
		off = SetTableOffset(addr, idx);
		if (substr(Name(off), 0, strlen(name)) != name) {
			MakeName(off, name + "_" + sprintf("%X", idx / 2));
		}
	}

	for (idx = 0; idx < entry_count * 2; idx = idx + 2) {
		off = addr + Word(addr + idx);
		auto count = Word(off);
		ForceWord(off);
		auto tile;
		for (tile = off + 2; tile < off + 2 + (2 * count); tile = tile + 2) {
			ForceWord(tile);
		}
	}
}

static AnalyzeAnimations(addr, name, entry_count)
{
	auto idx, off;
	if (entry_count == 0) {
		entry_count = 256;
	}
	for (idx = 0; idx < entry_count * 2; idx = idx + 2) {
		if (idx > 0 && strlen(Name(addr + idx)) > 0) {
			entry_count = idx / 2;
			break;
		}
		off = SetTableOffset(addr, idx);
		if (substr(Name(off), 0, strlen(name)) != name) {
			MakeName(off, name + "_" + sprintf("%X", idx / 2));
		}
	}

	for (idx = 0; idx < entry_count * 2; idx = idx + 2) {
		off = addr + Word(addr + idx);
		ForceByte(off);
		auto size;
		auto frame = Byte(off + 1);
		for (size = 0; frame < 0xFC; size = size + 1) {
			if ((file_id == 18 && (off + size + 2) == 0x20EA92) ||
			    (file_id == 19 && (off + size + 2) == 0x20EA5A) ||
			    Name(off + size + 2) != "") {
				break;
			    }
			frame = Byte(off + size + 2);
		}

		if (frame == 0xFD || frame == 0xFE) {
			ForceArray(off + 1 + size, 2);
		} else if (frame >= 0xF0) {
			ForceByte(off + 1 + size);
		} else {
			size = size + 1;
		}

		ForceFormattedArray(off + 1, 0, size, 8, -1);
	}
}

static DefineKnownData(void)
{
	auto Hud100000;
	
	NameFromOp(ResetHudRings + 0xA, "ResetHudRingsTiles", 0);
	NameFromOp(ResetHudScore + 0x14, "ResetHudScoreTiles", 0);
	NameFromOp(ResetHudNumber, "HudNumbersArt", 0);
	Hud100000 = NameFromOp(DrawHudScore, "Hud100000", 0);
	
	ForceDword(Hud100000);
	NameDword(Hud100000 + 4, "Hud10000");
	NameDword(Hud100000 + 8, "Hud1000");
	NameDword(Hud100000 + 0xC, "Hud100");
	NameDword(Hud100000 + 0x10, "Hud10");
	NameDword(Hud100000 + 0x14, "Hud1");
	NameDword(Hud100000 + 0x18, "Hud1000h");
	NameDword(Hud100000 + 0x1C, "Hud100h");
	NameDword(Hud100000 + 0x20, "Hud10h");
	NameDword(Hud100000 + 0x24, "Hud1h");
	
	if (zone != 2) {
		ForceDword(LoadMapCollision + 0x12);
		ForceDword(LoadMapCollision + 0x16);
		ForceDword(LoadMapCollision + 0x1A);
		ForceDword(LoadMapCollision + 0x1E);
		ForceDword(LoadMapCollision + 0x22);
		ForceDword(LoadMapCollision + 0x26);
		ForceDword(LoadMapCollision + 0x2A);
		ForceDword(LoadMapCollision + 0x2E);
	}

	auto kama = LocByName("KamaKamaObject_0_Routine0");
	if (kama != BADADDR) {
		MakeName(Dword(kama + 2), "KamaKamaSprites1");
		AnalyzeSprites(Dword(kama + 2), "@KamaKamaSprites1", 8);
		MakeName(Dword(kama + 0x14), "KamaKamaSprites2");
		AnalyzeSprites(Dword(kama + 0x14), "@KamaKamaSprites2", 8);
	}
	
	auto sine = CalcSine;
	if (sine != BADADDR) {
		NameFormattedWordArray(sine + 0x18, AP_SIGNED, 0x140, 8, 5, "SineTable");
	}
	
	auto angle = CalcAngle;
	if (angle != BADADDR) {
		NameFormattedArray(angle + 0x66, 0, 0x101, 8, 4, "AtanTable");
	}
}
