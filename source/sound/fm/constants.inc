; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------

; IDs
FM_START		equ 90h					; Starting SFX ID
FM_END			equ 0DFh				; Ending SFX ID
FM_CMD_STOP		equ 0E0h				; Stop command ID

; Track counts
TRACK_COUNT		equ 6					; Number of tracks

; Track flags
TRACK_FM3_DETUNE	equ 0					; FM3 detune mode flag
TRACK_LEGATO		equ 1					; Legato flag
TRACK_MUTE		equ 2					; Mute flag
TRACK_RAW_FREQ		equ 3					; Raw frequency mode
TRACK_REST		equ 4					; Rest flag
TRACK_PORTAMENTO	equ 5					; Portamento flag
TRACK_VIBRATO_END	equ 6					; Vibrato envelope end flag
TRACK_PLAY		equ 7					; Play flag

; ------------------------------------------------------------------------------
