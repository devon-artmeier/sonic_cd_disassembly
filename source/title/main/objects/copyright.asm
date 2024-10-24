; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; Copyright object
; ------------------------------------------------------------------------------

	xdef ObjCopyright
ObjCopyright:
	move.l	#CopyrightSprites,obj.sprites(a0)		; Set mappings
	move.w	#$E000|($DE00/$20),obj.sprite_tile(a0)		; Set sprite tile ID
	move.b	#%1,obj.flags(a0)				; Set flags
	;if REGION=USA
		move.w	#208,obj.y(a0)				; Set Y position
		move.w	#80,obj.x(a0)				; Set X position
		move.b	#1,obj.sprite_frame(a0)			; Display with trademark
	;else
	;	move.w	#91,obj.x(a0)				; Set X position
	;	move.w	#208,obj.y(a0)				; Set Y position
	;endif

; ------------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	.Done						; Remain static

; ------------------------------------------------------------------------------
; Copyright text sprites
; ------------------------------------------------------------------------------

	xdef CopyrightSprites
CopyrightSprites:
	;if REGION=USA
		include	"../data/copyright_sprites_u.asm"
	;else
	;	include	"../data/copyright_sprites_je.asm"
	;endif
	even

; ------------------------------------------------------------------------------
; Trademark symbol object
; ------------------------------------------------------------------------------

	xdef ObjTm
ObjTm:
	move.l	#TmSprites,obj.sprites(a0)			; Set mappings
	;if REGION=USA						; Set sprite tile ID
		move.w	#$E000|($DFC0/$20),obj.sprite_tile(a0)
	;else
	;	move.w	#$E000|($DF20/$20),obj.sprite_tile(a0)
	;endif
	move.b	#%1,obj.flags(a0)				; Set flags
	move.w	#194,obj.x(a0)					; Set X position
	move.w	#131,obj.y(a0)					; Set Y position
	
; ------------------------------------------------------------------------------

.Done:
	bsr.w	BookmarkObject					; Set bookmark
	bra.s	.Done						; Remain static

; ------------------------------------------------------------------------------
; Trademark symbol sprites
; ------------------------------------------------------------------------------

	xdef TmSprites
TmSprites:
	include	"../data/copyright_tm_sprites.asm"
	even

; ------------------------------------------------------------------------------
