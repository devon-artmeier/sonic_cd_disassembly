; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Addresses
; ------------------------------------------------------------------------------

; Z80 RAM
Z80_RAM			equ 0					; Z80 RAM start
Z80_SIZE		equ 2000h				; Z80 RAM size
Z80_END			equ Z80_RAM+Z80_SIZE			; Z80 RAM end

; YM2612
YM_ADDR_0		equ 4000h				; YM2612 address port 0
YM_DATA_0		equ 4001h				; YM2612 data port 0
YM_ADDR_1		equ 4002h				; YM2612 address port 1
YM_DATA_1		equ 4003h				; YM2612 data port 1

; PSG
PSG_CTRL		equ 7F11h				; PSG control port

; 68000 bank
M68K_BANK_SET		equ 6000h				; 68000 bank set
M68K_BANK		equ 8000h				; 68000 bank start
M68K_BANK_SIZE		equ 8000h				; 68000 bank size
M68K_BANK_END		equ M68K_BANK+M68K_BANK_SIZE		; 68000 bank end

; ------------------------------------------------------------------------------
