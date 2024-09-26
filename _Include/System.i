; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; System definitions
; ------------------------------------------------------------------------------

	if def(SUB_CPU)

; ------------------------------------------------------------------------------
; Addresses
; ------------------------------------------------------------------------------

; System program
SpVariables		equ $7000				; Variables
TempSaveData		equ $7400				; Temporary save data buffer
MegaDriveIrq		equ $7700				; IRQ2 handler
LoadFile		equ $7800				; Load file
GetFileName		equ $7840				; Get file name
FileFunction		equ $7880				; File engine function handler
FileVariables		equ $8C00				; File engine variables

; System program extension
Spx			equ $B800				; SPX start location
SpxFileNameTable	equ Spx					; SPX file name table
SpxStart		equ Spx+$800				; SPX code start
Stack			equ $10000				; Stack base

; FMV
FMV_PCM_BUFFER		equ PRG_RAM+$40000			; PCM data buffer
FMV_GFX_BUFFER		equ WORD_RAM_1M				; Graphics data buffer

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; File engine functions
	rsreset
FILE_INIT		rs.b 1					; Initialize
FILE_OPERATION		rs.b 1					; Perform operation
FILE_STATUS		rs.b 1					; Get status
FILE_GET_FILES		rs.b 1					; Get files
FILE_LOAD_FILE		rs.b 1					; Load file
FILE_FIND_FILE		rs.b 1					; Find file
FILE_FMV		rs.b 1					; Load FMV
FILE_RESET		rs.b 1					; Reset
FILE_MUTE_FMV		rs.b 1					; Load mute FMV

; File engine operation modes
	rsreset
FILE_OPERATE_NONE	rs.b 1					; No function
FILE_OPERATE_GET_FILES	rs.b 1					; Get files
FILE_OPERATE_LOAD_FILE	rs.b 1					; Load file
FILE_OPERATE_FMV	rs.b 1					; Load FMV
FILE_OPERATE_FMV_MUTE	rs.b 1					; Load mute FMV

; File engine statuses
FILE_STATUS_OK		equ 100					; OK
FILE_STATUS_GET_FAIL	equ -1					; File get failed
FILE_STATUS_NOT_FOUND	equ -2					; File not found
FILE_STATUS_LOAD_FAIL	equ -3					; File load failed
FILE_STATUS_READ_FAIL	equ -100				; Failed
FILE_STATUS_FMV_FAIL	equ -111				; FMV load failed

; FMV data types
FMV_DATA_PCM		equ 0					; PCM data type
FMV_DATA_GFX		equ 1					; Graphics data type

; FMV flags
FMV_INIT_BIT		equ 3					; Initialized flag
FMV_INIT		equ 1<<FMV_INIT_BIT
FMV_PCM_BUFFER_ID_BIT	equ 4					; PCM buffer ID
FMV_PCM_BUFFER_ID	equ 1<<FMV_PCM_BUFFER_ID_BIT
FMV_READY_BIT		equ 5					; Ready flag
FMV_READY		equ 1<<FMV_READY_BIT
FMV_SECTION_1_BIT	equ 7					; Reading data section 1 flag
FMV_SECTION_1		equ 1<<FMV_SECTION_1_BIT

; File data
FILE_NAME_SIZE		equ 12					; File name size

; ------------------------------------------------------------------------------
; SP variables
; ------------------------------------------------------------------------------

	rsset SpVariables
cur_pcm_driver		rs.l 1					; Current PCM driver
spec_stage_flags_copy	rs.b 1					; Special stage flags copy
pcm_driver_flags	rs.b 1					; PCM driver flags
			rs.b $400-__rs
SP_VARIABLES_SIZE	rs.b 0					; Size of variables area

; ------------------------------------------------------------------------------
; File engine variables structure
; ------------------------------------------------------------------------------

	rsreset
file.bookmark		rs.l 1					; Operation bookmark
file.sector		rs.l 1					; Sector to read from
file.sector_count	rs.l 1					; Number of sectors to read
file.return		rs.l 1					; Return address for CD read functions
file.read_buffer	rs.l 1					; Read buffer address
file.read_time		rs.b 0					; Time of read sector
file.read_minute	rs.b 1					; Read sector minute
file.read_second	rs.b 1					; Read sector second
file.read_frame		rs.b 1					; Read sector frame
			rs.b 1
file.dir_sector_count	rs.b 0					; Directory sector count
file.size		rs.l 1					; File size buffer
file.operation_mode	rs.w 1					; Operation mode
file.status		rs.w 1					; Status code
file.count		rs.w 1					; File count
file.wait_time		rs.w 1					; Wait timer
file.retries		rs.w 1					; Retry counter
file.sectors_read	rs.w 1					; Number of sectors read
file.cdc_device		rs.b 1					; CDC mode
file.sector_frame	rs.b 1					; Sector frame
file.name		rs.b FILE_NAME_SIZE			; File name buffer
			rs.b $100-__rs
file.list		rs.b $2000				; File list
file.directory		rs.b $900				; Directory read buffer
file.fmv_frame		rs.w 1					; FMV frame
file.fmv_data_type	rs.b 1					; FMV read data type
file.fmv_flags		rs.b 1					; FMV flags
file.fmv_fail_count	rs.b 1					; FMV fail counter
file.struct_size	rs.b 0					; Size of structure

; ------------------------------------------------------------------------------
; File entry structure
; ------------------------------------------------------------------------------

	rsreset
file_entry.name		rs.b FILE_NAME_SIZE			; File name
			rs.b $17-__rs
file_entry.flags	rs.b 1					; File flags
file_entry.sector	rs.l 1					; File sector
file_entry.length	rs.l 1					; File size
file_entry.struct_len	rs.b 0					; Size of structure
	endif

; ------------------------------------------------------------------------------
