#include <idc.idc>

extern zone, act, time, file_id;

#include "ida_helpers.idc"
#include "define_variables.idc"
#include "define_data.idc"
#include "analyze_functions.idc"
#include "analyze_data.idc"
#include "analyze_object.idc"

static main(void)
{
	auto in_file = GetInputFile();
	
	zone = atol(substr(in_file, 1, 2)) - 1;
	if (zone >= 2) {
		zone = zone - 1;
	}
	act = atol(substr(in_file, 2, 3)) - 1;
	time = (substr(in_file, 3, 4));
	if (time == "A") {
		time = 0;
	} else if (time == "B") {
		time = 1;
	} else if (time == "C") {
		time = 2;
	} else if (time == "D") {
		time = 3;
	}
	file_id = (zone * 10) + (act * 4) + time;
	if (act == 2) {
		file_id = file_id - 2;
	}
	Message("Zone: %i, Act: %i, Time: %i, File: %i\n", zone, act, time, file_id);
	
	DefineMemory();	
	Wait();
	DefineData();
	Wait();
	DefineKnownFunctions();
	Wait();
	DefineKnownData();
	Wait();
	InitObjectDefine();
	Wait();
	DefineKnownObjects();
	Wait();
	FinishObjectDefine();
	
	Indent(8);
}