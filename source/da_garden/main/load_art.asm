; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------

	include	"include_main.inc"
	include	"../common.inc"
	include	"variables.inc"

	section code

; ------------------------------------------------------------------------------
; Load art
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - Art IDs (each byte is an ID)
; ------------------------------------------------------------------------------

	xdef LoadArt
LoadArt:
	lea	VDP_CTRL,a5					; VDP control port
	moveq	#4-1,d2						; Number of IDs in the queue

.Loop:
	moveq	#0,d1						; Get art ID
	move.b	d0,d1
	beq.s	.NextArt					; If it's blank, branch

	lsl.w	#3,d1						; Load art
	lea	.Art(pc),a0
	move.l	-8(a0,d1.w),(a5)
	movea.l	-4(a0,d1.w),a0
	jsr	DecompressNemesisVdp(pc)

.NextArt:
	ror.l	#8,d0						; Next art ID
	dbf	d2,.Loop					; Loop until art is loaded
	rts

; ------------------------------------------------------------------------------

.Art:
	vdpCmd dc.l,$B700,VRAM,WRITE				; Flicky (slot 1)
	dc.l	FlickyArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; Flicky (slot 2)
	dc.l	FlickyArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; Star (slot 1)
	dc.l	StarArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; Star (slot 2)
	dc.l	StarArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; UFO (slot 1)
	dc.l	UfoArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; UFO (slot 2)
	dc.l	UfoArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; Eggman
	dc.l	EggmanArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; Metal Sonic
	dc.l	MetalSonicArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; Tails
	dc.l	TailsArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Palmtree Panic" (slot 1)
	dc.l	WORD_RAM_2M+Round1ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Palmtree Panic 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round1CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Palmtree Panic 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round1DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Collision Chaos" (slot 1)
	dc.l	WORD_RAM_2M+Round3ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Collision Chaos 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round3CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Collision Chaos 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round3DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Tidal Tempest" (slot 1)
	dc.l	WORD_RAM_2M+Round4ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Tidal Tempest 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round4CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Tidal Tempest 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round4DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Quartz Quadrant" (slot 1)
	dc.l	WORD_RAM_2M+Round5ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Quartz Quadrant 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round5CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Quartz Quadrant 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round5DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Wacky Workbench" (slot 1)
	dc.l	WORD_RAM_2M+Round6ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Wacky Workbench 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round6CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Wacky Workbench 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round6DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Stardust Speedway" (slot 1)
	dc.l	WORD_RAM_2M+Round7ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Stardust Speedway 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round7CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Stardust Speedway 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round7DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Metallic Madness" (slot 1)
	dc.l	WORD_RAM_2M+Round8ATrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Metallic Madness 'G' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round8CTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Metallic Madness 'B' mix" (slot 1)
	dc.l	WORD_RAM_2M+Round8DTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Final Fever" (slot 1)
	dc.l	WORD_RAM_2M+FinalTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Little Planet" (slot 1)
	dc.l	WORD_RAM_2M+DaGardenTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Game Over" (slot 1)
	dc.l	WORD_RAM_2M+GameOverTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Zone Clear" (slot 1)
	dc.l	WORD_RAM_2M+ResultsTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Boss!!" (slot 1)
	dc.l	WORD_RAM_2M+BossTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Invincible!!" (slot 1)
	dc.l	WORD_RAM_2M+InvincibleTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Speed Up!!" (slot 1)
	dc.l	WORD_RAM_2M+SpeedShoesTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Title" (slot 1)
	dc.l	WORD_RAM_2M+TitleTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Special Stage" (slot 1)
	dc.l	WORD_RAM_2M+SpecialStageTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Opening" (slot 1)
	dc.l	WORD_RAM_2M+OpeningTrackArt
	vdpCmd dc.l,$B700,VRAM,WRITE				; "Ending" (slot 1)
	dc.l	WORD_RAM_2M+EndingTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Palmtree Panic" (slot 2)
	dc.l	WORD_RAM_2M+Round1ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Palmtree Panic 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round1CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Palmtree Panic 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round1DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Collision Chaos" (slot 2)
	dc.l	WORD_RAM_2M+Round3ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Collision Chaos 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round3CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Collision Chaos 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round3DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Tidal Tempest" (slot 2)
	dc.l	WORD_RAM_2M+Round4ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Tidal Tempest 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round4CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Tidal Tempest 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round4DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Quartz Quadrant" (slot 2)
	dc.l	WORD_RAM_2M+Round5ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Quartz Quadrant 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round5CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Quartz Quadrant 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round5DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Wacky Workbench" (slot 2)
	dc.l	WORD_RAM_2M+Round6ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Wacky Workbench 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round6CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Wacky Workbench 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round6DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Stardust Speedway" (slot 2)
	dc.l	WORD_RAM_2M+Round7ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Stardust Speedway 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round7CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Stardust Speedway 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round7DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Metallic Madness" (slot 2)
	dc.l	WORD_RAM_2M+Round8ATrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Metallic Madness 'G' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round8CTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Metallic Madness 'B' mix" (slot 2)
	dc.l	WORD_RAM_2M+Round8DTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Final Fever" (slot 2)
	dc.l	WORD_RAM_2M+FinalTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Little Planet" (slot 2)
	dc.l	WORD_RAM_2M+DaGardenTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Game Over" (slot 2)
	dc.l	WORD_RAM_2M+GameOverTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Zone Clear" (slot 2)
	dc.l	WORD_RAM_2M+ResultsTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Boss!!" (slot 2)
	dc.l	WORD_RAM_2M+BossTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Invincible!!" (slot 2)
	dc.l	WORD_RAM_2M+InvincibleTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Speed Up!!" (slot 2)
	dc.l	WORD_RAM_2M+SpeedShoesTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Title" (slot 2)
	dc.l	WORD_RAM_2M+TitleTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Special Stage" (slot 2)
	dc.l	WORD_RAM_2M+SpecialStageTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Opening" (slot 2)
	dc.l	WORD_RAM_2M+OpeningTrackArt
	vdpCmd dc.l,$BB80,VRAM,WRITE				; "Ending" (slot 2)
	dc.l	WORD_RAM_2M+EndingTrackArt

; ------------------------------------------------------------------------------
