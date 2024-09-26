@echo off
set REGION=1
set OUTPUT=SCD.iso
set ASM68K=_Bin\asm68k.exe /p /o ae-,l.,ow+ /e REGION=%REGION%
set AS=_Bin\asw.exe -q -xx -n -A -L -U -E -i .
set P2BIN=_Bin\p2bin.exe

if not exist _Built mkdir _Built
if not exist _Built\Files mkdir _Built\Files
if not exist _Built\Misc mkdir _Built\Misc
if %REGION%==0 (copy _Original\Japan\*.* _Built\Files > nul)
if %REGION%==1 (copy _Original\USA\*.* _Built\Files > nul)
if %REGION%==2 (copy _Original\Europe\*.* _Built\Files > nul)
del _Built\Files\.gitkeep > nul

if %REGION%==0 (set FMVWAV="FMV\Data\Opening (Japan, Europe).wav")
if %REGION%==1 (set FMVWAV="FMV\Data\Opening (USA).wav")
if %REGION%==2 (set FMVWAV="FMV\Data\Opening (Japan, Europe).wav")

%AS% "Sound Drivers\FM\_Driver.asm"
if exist "Sound Drivers\FM\_Driver.p" (
    %P2BIN% "Sound Drivers\FM\_Driver.p" "_Built\Misc\FM Sound Driver.bin"
    del "Sound Drivers\FM\_Driver.p" > nul
) else (
    echo **************************************************************************************
    echo *                                                                                    *
    echo * FM sound driver failed to build. See "Sound Drivers\FM\_Driver.log" for more info. *
    echo *                                                                                    *
    echo **************************************************************************************
)

%ASM68K% "CD System Program\SP.asm", "_Built\Misc\SP.BIN", , "CD System Program\SP.lst"
%ASM68K% "CD System Program\SPX.asm", "_Built\Files\SPX___.BIN", "CD System Program\SPX.sym", "CD System Program\SPX.lst"

_Bin\extract-psyq-symbols.exe -i "CD System Program\SPX.sym" -o "_Include\File IDs.i" -p "FILE_"
_Bin\extract-psyq-symbols.exe -i "CD System Program\SPX.sym" -o "_Include\System Commands.i" -p "SCMD_"
if exist "CD System Program\SPX.sym" ( del "CD System Program\SPX.sym" > nul )

REM %ASM68K% "DA Garden\Track Titles.asm", "_Built\Files\PLANET_D.BIN", "DA Garden\Track Titles.sym"
REM _Bin\extract-psyq-symbols.exe -i "DA Garden\Track Titles.sym" -o "DA Garden\Track Title Labels.i"
REM if exist "DA Garden\Track Titles.sym" ( del "DA Garden\Track Titles.sym" > nul )
REM %ASM68K% "DA Garden\Main.asm", "_Built\Files\PLANET_M.MMD", , "DA Garden\Main.lst"
REM %ASM68K% "DA Garden\Sub.asm", "_Built\Files\PLANET_S.BIN", , "DA Garden\Sub.lst"

%ASM68K% "CD Initial Program\IP.asm", "_Built\Misc\IP.BIN", , "CD Initial Program\IP.lst"
%ASM68K% "CD Initial Program\IPX.asm", "_Built\Files\IPX___.MMD",  , "CD Initial Program\IPX.lst"

%ASM68K% "Backup RAM\Initialization\Main.asm", "_Built\Files\BRAMINIT.MMD", , "Backup RAM\Initialization\Main.lst"
%ASM68K% "Backup RAM\Sub.asm", "_Built\Files\BRAMSUB.BIN", , "Backup RAM\Sub.lst"
REM %ASM68K% "Mega Drive Init\Main.asm", "_Built\Files\MDINIT.MMD", , "Mega Drive Init\Main.lst"
REM %ASM68K% "Time Warp Cutscene\Main.asm", "_Built\Files\WARP__.MMD", , "Time Warp Cutscene\Main.lst"
REM %ASM68K% "Sound Drivers\PCM\Palmtree Panic.asm", "_Built\Files\SNCBNK1B.BIN", , "Sound Drivers\PCM\Palmtree Panic.lst"
REM %ASM68K% "Sound Drivers\PCM\Collision Chaos.asm", "_Built\Files\SNCBNK3B.BIN", , "Sound Drivers\PCM\Collision Chaos.lst"
REM %ASM68K% "Sound Drivers\PCM\Tidal Tempest.asm", "_Built\Files\SNCBNK4B.BIN", , "Sound Drivers\PCM\Tidal Tempest.lst"
REM %ASM68K% "Sound Drivers\PCM\Quartz Quadrant.asm", "_Built\Files\SNCBNK5B.BIN", , "Sound Drivers\PCM\Quartz Quadrant.lst"
REM %ASM68K% "Sound Drivers\PCM\Wacky Workbench.asm", "_Built\Files\SNCBNK6B.BIN", , "Sound Drivers\PCM\Wacky Workbench.lst"
REM %ASM68K% "Sound Drivers\PCM\Stardust Speedway.asm", "_Built\Files\SNCBNK7B.BIN", , "Sound Drivers\PCM\Stardust Speedway.lst"
REM %ASM68K% "Sound Drivers\PCM\Metallic Madness.asm", "_Built\Files\SNCBNK8B.BIN", , "Sound Drivers\PCM\Metallic Madness.lst"
REM %ASM68K% "Sound Drivers\PCM\Boss.asm", "_Built\Files\SNCBNKB1.BIN", , "Sound Drivers\PCM\Boss.lst"
REM %ASM68K% "Sound Drivers\PCM\Final Boss.asm", "_Built\Files\SNCBNKB2.BIN", , "Sound Drivers\PCM\Final Boss.lst"

REM %ASM68K% "Title Screen\Main.asm", "_Built\Files\TITLEM.MMD", , "Title Screen\Main.lst"
REM %ASM68K% "Title Screen\Sub.asm", "_Built\Files\TITLES.BIN", , "Title Screen\Sub.lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Sound Test.asm", "_Built\Files\SOSEL_.MMD", , "Title Screen\Secrets\Sound Test.lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Stage Select.asm", "_Built\Files\STSEL_.MMD", , "Title Screen\Secrets\Stage Select.lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=1 "Title Screen\Secrets\Best Staff Times.asm", "_Built\Files\DUMMY4.MMD", , "Title Screen\Secrets\Best Staff Times.lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 "Title Screen\Secrets\Special Stage 8 Credits.asm", "_Built\Files\SPEEND.MMD", , "Title Screen\Secrets\Special Stage 8 Credits.lst"

REM if exist "_Built\Files\DUMMY5.MMD" (del "_Built\Files\DUMMY5.MMD" > nul)
REM %ASM68K% /e PROTOTYPE=1 /e H32=0 "Title Screen\Secrets\Sound Test (Prototype).asm", "_Built\Files\DUMMY5.MMD", , "Title Screen\Secrets\Sound Test (Prototype).lst"
REM if exist "_Built\Files\DUMMY5.MMD" (
REM     copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY6.MMD" > nul
REM     copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY7.MMD" > nul
REM     copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY8.MMD" > nul
REM     copy "_Built\Files\DUMMY5.MMD" "_Built\Files\DUMMY9.MMD" > nul
REM )

REM %ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=0 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\NISI.MMD", , "Title Screen\Secrets\Sound Test Image (Fun Is Infinite).lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=1 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY0.MMD", , "Title Screen\Secrets\Sound Test Image (M.C. Sonic).lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=2 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY1.MMD", , "Title Screen\Secrets\Sound Test Image (Tails).lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=3 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY2.MMD", , "Title Screen\Secrets\Sound Test Image (Batman).lst"
REM %ASM68K% /e PROTOTYPE=0 /e H32=0 /e EASTEREGG=4 "Title Screen\Secrets\Sound Test Image.asm", "_Built\Files\DUMMY3.MMD", , "Title Screen\Secrets\Sound Test Image (Cute Sonic).lst"

REM %ASM68K% "FMV\Main (Opening).asm", "_Built\Files\OPEN_M.MMD", , "FMV\Main (Opening).lst"
REM %ASM68K% "FMV\Sub (Opening).asm", "_Built\Files\OPEN_S.BIN", , "FMV\Sub (Opening).lst"
REM %ASM68K% /e DATAFILE=0 "FMV\Sub (Ending).asm", "_Built\Files\GOODEND.BIN", , "FMV\Sub (Good Ending).lst"
REM %ASM68K% /e DATAFILE=1 "FMV\Sub (Ending).asm", "_Built\Files\BADEND.BIN", , "FMV\Sub (Bad Ending).lst"
REM %ASM68K% "FMV\Sub (Pencil Test).asm", "_Built\Files\PTEST.BIN", , "FMV\Sub (Pencil Test).lst"
REM echo.
REM echo Making opening FMV STM...
REM _Bin\MakeSTM.exe "FMV\Data\Opening.gif" %FMVWAV% 0 0 "_Built\Files\OPN.STM"

REM %ASM68K% "Visual Mode\Main.asm", "_Built\Files\VM____.MMD", , "Visual Mode\Main.lst"

REM %ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Present.asm", "_Built\Files\R11A__.MMD", , "Level\Palmtree Panic\Act 1 Present.lst"
REM %ASM68K% /e DEMO=1 "Level\Palmtree Panic\Act 1 Present.asm", "_Built\Files\DEMO11A.MMD", , "Level\Palmtree Panic\Act 1 Present (Demo).lst"
REM %ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Past.asm", "_Built\Files\R11B__.MMD", , "Level\Palmtree Panic\Act 1 Past.lst"
REM %ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Good Future.asm", "_Built\Files\R11C__.MMD", , "Level\Palmtree Panic\Act 1 Good Future.lst"
REM %ASM68K% /e DEMO=0 "Level\Palmtree Panic\Act 1 Bad Future.asm", "_Built\Files\R11D__.MMD", , "Level\Palmtree Panic\Act 1 Bad Future.lst"

REM %ASM68K% /e DEMO=0 "Level\Wacky Workbench\Act 1 Present.asm", "_Built\Files\R61A__.MMD", , "Level\Wacky Workbench\Act 1 Present.lst"

REM %ASM68K% "Special Stage\Stage Data.asm", "Special Stage\Stage Data.bin", "Special Stage\Stage Data.sym"
REM _Bin\extract-psyq-symbols.exe -i "Special Stage\Stage Data.sym" -o "Special Stage\Stage Data Labels.i"
REM if exist "Special Stage\Stage Data.sym" ( del "Special Stage\Stage Data.sym" > nul )
REM %ASM68K% "Special Stage\Main.asm", "_Built\Files\SPMM__.MMD", , "Special Stage\Main.lst"
REM %ASM68K% "Special Stage\Sub.asm", "_Built\Files\SPSS__.BIN", , "Special Stage\Sub.lst"

echo.
echo Compiling filesystem...
_Bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "SEGA ENTERPRISES" -V "SONIC_CD___" -publisher "SEGA ENTERPRISES" -p "SEGA ENTERPRISES" -sysid "MEGA_CD" -iso-level 1 -o _Built\Misc\Files.BIN _Built\Files

%ASM68K% main.asm, _Built\%OUTPUT%
del _Built\Misc\Files.BIN > nul

pause