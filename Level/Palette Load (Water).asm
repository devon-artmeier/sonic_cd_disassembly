; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Water palette loading function
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Load a palette into the water palette buffer
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Palette ID
; ------------------------------------------------------------------------------

LoadWaterPal:
	lea	PaletteTable,a1			; Get pointer to palette metadata
	lsl.w	#3,d0
	adda.w	d0,a1

	movea.l	(a1)+,a2			; Get palette pointer
	movea.w	(a1)+,a3			; Get palette buffer pointer
	suba.w	#palette-water_palette,a3
	move.w	(a1)+,d7			; Get palette length

.Load:
	move.l	(a2)+,(a3)+
	dbf	d7,.Load			; Loop until palette is loaded

	rts
	
; ------------------------------------------------------------------------------
