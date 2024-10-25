; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../../common.inc"
	include	"../variables.inc"

	section code

; ------------------------------------------------------------------------------
; Banner object
; ------------------------------------------------------------------------------

	xdef ObjBanner
ObjBanner:
	move.l	#BannerSprites,obj.sprites(a0)			; Set mappings
	move.w	#$A000|($F000/$20),obj.sprite_tile(a0)		; Set sprite tile ID
	move.b	#%11,obj.flags(a0)				; Set flags
	move.w	#127,obj.x(a0)					; Set X position
	move.w	#127,obj.y(a0)					; Set Y position

; ------------------------------------------------------------------------------

.Done:
	jsr	BookmarkObject(pc)				; Set bookmark
	bra.s	.Done						; Remain static

; ------------------------------------------------------------------------------
; Banner sprites
; ------------------------------------------------------------------------------

	xdef BannerSprites
BannerSprites:
	include	"../../data/banner_sprites.asm"
	even

; ------------------------------------------------------------------------------
