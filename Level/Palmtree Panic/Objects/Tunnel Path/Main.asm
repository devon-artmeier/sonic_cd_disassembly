; ------------------------------------------------------------------------------
; Sonic CD (1993) Disassembly
; By Devon Artmeier
; ------------------------------------------------------------------------------
; Tunnel path object
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Sonic hole object
; ------------------------------------------------------------------------------

ObjSonicHole:
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	ObjSonicHole_Index(pc,d0.w),d0
	jsr	ObjSonicHole_Index(pc,d0.w)
	jmp	CheckObjDespawn

; ------------------------------------------------------------------------------
ObjSonicHole_Index:dc.w	ObjSonicHole_Init-ObjSonicHole_Index
	dc.w	ObjSonicHole_Main-ObjSonicHole_Index
	dc.w	ObjSonicHole_Display-ObjSonicHole_Index
; ------------------------------------------------------------------------------

ObjSonicHole_Init:
	addq.b	#2,obj.routine(a0)
	ori.b	#4,obj.sprite_flags(a0)
	move.w	#$3A0,obj.sprite_tile(a0)
	tst.b	time_zone
	bne.s	.NotPast
	move.w	#$3BB,obj.sprite_tile(a0)

.NotPast:
	move.l	#MapSpr_SonicHole,obj.sprites(a0)
	move.b	#$10,obj.width(a0)
	move.b	#$10,obj.collide_height(a0)
	move.b	#6,obj.sprite_layer(a0)
	bsr.w	ObjSonicHole_SetDisplay
	beq.s	.ClearDisplay
	addq.b	#2,obj.routine(a0)
	bra.w	ObjSonicHole_Display

; ------------------------------------------------------------------------------

.ClearDisplay:
	bclr	#6,2(a1,d0.w)
; End of function ObjSonicHole_Init

; ------------------------------------------------------------------------------

ObjSonicHole_Main:
	lea	player_object,a6
	tst.b	oPlayerCtrl(a6)
	beq.s	.End
	move.w	obj.x(a6),d0
	sub.w	obj.x(a0),d0
	addi.w	#$20,d0
	bmi.s	.End
	cmpi.w	#$40,d0
	bcc.s	.End
	move.w	obj.y(a6),d0
	sub.w	obj.y(a0),d0
	addi.w	#$20,d0
	bmi.s	.End
	cmpi.w	#$40,d0
	bcc.s	.End
	bsr.s	ObjSonicHole_SetDisplay
	move.w	#FM_A3,d0
	jsr	PlayFMSound
	addq.b	#2,obj.routine(a0)
	bra.s	ObjSonicHole_Display

; ------------------------------------------------------------------------------

.End:
	rts

; ------------------------------------------------------------------------------

ObjSonicHole_Display:
	jmp	DrawObject
; End of function ObjSonicHole_Main

; ------------------------------------------------------------------------------

ObjSonicHole_SetDisplay:
	moveq	#0,d0
	move.b	obj.state_id(a0),d0
	lea	map_object_states,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	time_zone,d1
	add.w	d1,d0
	bset	#6,2(a1,d0.w)
	rts
; End of function ObjSonicHole_SetDisplay

; ------------------------------------------------------------------------------

MapSpr_SonicHole:
	include	"Level/Palmtree Panic/Objects/Tunnel Path/Data/Mappings (Hole).asm"
	even

; ------------------------------------------------------------------------------
; Tunnel path object
; ------------------------------------------------------------------------------

oTunnelSteps	EQU	obj.var_2E
oTunnelVar32	EQU	obj.var_32
oTunnelX	EQU	obj.var_36
oTunnelY	EQU	obj.var_38
oTunnelIndex	EQU	obj.var_3A
oTunnelEnd	EQU	obj.var_3B
oTunnelData	EQU	obj.var_3C

; ------------------------------------------------------------------------------

ObjTunnelPath:
	btst	#7,time_zone
	beq.s	.NoTimeTravel
	
	moveq	#0,d0
	move.b	obj.state_id(a0),d0
	beq.s	.NoTimeTravel
	
	lea	map_object_states,a1
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	time_zone,d1
	bclr	#7,d1
	move.b	time_warp_direction,d2
	ext.w	d2
	neg.w	d2
	add.w	d2,d1
	bpl.s	.CapTimeZone
	moveq	#0,d1
	bra.s	.MarkUnloaded

.CapTimeZone:
	cmpi.w	#3,d1
	bcs.s	.MarkUnloaded
	moveq	#2,d1

.MarkUnloaded:
	add.w	d1,d0
	bclr	#7,2(a1,d0.w)

.NoTimeTravel:
	lea	player_object,a6
	cmpi.b	#$2B,obj.anim_id(a6)
	beq.s	.End
	cmpi.b	#6,obj.routine(a6)
	bcc.s	.End
	
	moveq	#0,d0
	move.b	obj.routine(a0),d0
	move.w	.Index(pc,d0.w),d1
	jsr	.Index(pc,d1.w)
	
	cmpi.b	#4,obj.routine(a0)
	bcc.s	.End
	jmp	CheckObjDespawn

.End:
	rts

; ------------------------------------------------------------------------------

.Index:
	dc.w	ObjTunnelPath_Init-.Index
	dc.w	ObjTunnelPath_Main-.Index
	dc.w	ObjTunnelPath_GotPlayer-.Index
	dc.w	ObjTunnelPath_MovePlayer-.Index
	
; ------------------------------------------------------------------------------

ObjTunnelPath_Init:
	move.l	#MapSpr_Powerup,obj.sprites(a0)
	move.b	#4,obj.sprite_flags(a0)
	move.b	#1,obj.sprite_layer(a0)
	move.b	#$10,obj.width(a0)
	move.w	#$541,obj.sprite_tile(a0)
	addq.b	#2,obj.routine(a0)
	
	move.b	obj.subtype(a0),d0
	add.w	d0,d0
	andi.w	#$FE,d0
	lea	ObjTunnelPath_Paths(pc),a2
	adda.w	(a2,d0.w),a2
	move.w	(a2)+,oTunnelIndex(a0)
	move.l	a2,oTunnelData(a0)
	move.w	(a2)+,oTunnelX(a0)
	move.w	(a2)+,oTunnelY(a0)

; ------------------------------------------------------------------------------

ObjTunnelPath_Main:
	move.w	obj.x(a6),d0
	sub.w	obj.x(a0),d0
	addi.w	#16,d0
	cmpi.w	#32,d0
	bcc.w	.End
	
	move.w	obj.y(a6),d1
	sub.w	obj.y(a0),d1
	addi.w	#16,d1
	cmpi.w	#32,d1
	bcc.w	.End
	
	tst.b	oPlayerCtrl(a6)
	bne.w	.End
	
	cmpi.b	#4,obj.routine(a6)
	bne.s	.NotHurt
	subq.b	#2,obj.routine(a6)
	move.w	#$78,oPlayerHurt(a6)
	
.NotHurt:
	addq.b	#2,obj.routine(a0)
	move.b	#%10000001,oPlayerCtrl(a6)
	tst.b	obj.subtype_2(a0)
	beq.s	.NoInvisiblePlayer
	ori.b	#$40,oPlayerCtrl(a6)
	
.NoInvisiblePlayer:
	move.b	#2,obj.anim_id(a6)
	bsr.w	ObjTunnelPath_SetPlayerGVel
	move.w	#0,obj.x_speed(a6)
	move.w	#0,obj.y_speed(a6)
	bclr	#5,obj.flags(a0)
	bclr	#5,obj.flags(a6)
	bset	#1,obj.flags(a6)
	clr.b	oPlayerJump(a6)
	move.w	obj.x(a0),obj.x(a6)
	move.w	obj.y(a0),obj.y(a6)
	clr.b	oTunnelVar32(a0)
	move.w	#FM_91,d0
	jsr	PlayFMSound

.End:
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_GotPlayer:
	bsr.w	ObjTunnelPath_SetPlayerSpeed
	addq.b	#2,obj.routine(a0)
	move.w	#FM_91,d0
	jsr	PlayFMSound
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_MovePlayer:
	subq.b	#1,oTunnelSteps(a0)
	bpl.s	.Move
	
	move.w	oTunnelX(a0),obj.x(a6)
	move.w	oTunnelY(a0),obj.y(a6)
	
	moveq	#0,d1
	move.b	oTunnelIndex(a0),d1
	addq.b	#4,d1
	cmp.b	oTunnelEnd(a0),d1
	bcs.s	.NotEnd
	moveq	#0,d1
	bra.s	.Release

.NotEnd:
	move.b	d1,oTunnelIndex(a0)
	movea.l	oTunnelData(a0),a2
	move.w	(a2,d1.w),oTunnelX(a0)
	move.w	2(a2,d1.w),oTunnelY(a0)
	bra.w	ObjTunnelPath_SetPlayerSpeed

.Move:
	move.l	obj.x(a6),d2
	move.l	obj.y(a6),d3
	move.w	obj.x_speed(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d2
	move.w	obj.y_speed(a6),d0
	ext.l	d0
	asl.l	#8,d0
	add.l	d0,d3
	move.l	d2,obj.x(a6)
	move.l	d3,obj.y(a6)
	rts

.Release:
	andi.w	#$7FF,obj.y(a6)
	clr.b	obj.routine(a0)
	clr.b	oPlayerCtrl(a6)
	move.w	#2,obj.routine(a0)
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_SetPlayerSpeed:
	moveq	#0,d0
	move.w	oPlayerGVel(a6),d2
	move.w	oPlayerGVel(a6),d3
	move.w	oTunnelX(a0),d0
	sub.w	obj.x(a6),d0
	bge.s	.PlayerLeft
	neg.w	d0
	neg.w	d2

.PlayerLeft:
	moveq	#0,d1
	move.w	oTunnelY(a0),d1
	sub.w	obj.y(a6),d1
	bge.s	.PlayerAbove
	neg.w	d1
	neg.w	d3

.PlayerAbove:
	cmp.w	d0,d1
	bcs.s	.XGreater
	moveq	#0,d1
	move.w	oTunnelY(a0),d1
	sub.w	obj.y(a6),d1
	swap	d1
	divs.w	d3,d1
	moveq	#0,d0
	move.w	oTunnelX(a0),d0
	sub.w	obj.x(a6),d0
	beq.s	.SetSpeed
	swap	d0
	divs.w	d1,d0

.SetSpeed:
	move.w	d0,obj.x_speed(a6)
	move.w	d3,obj.y_speed(a6)
	tst.w	d1
	bpl.s	.SetSteps
	neg.w	d1

.SetSteps:
	move.w	d1,oTunnelSteps(a0)
	rts

; ------------------------------------------------------------------------------

.XGreater:
	moveq	#0,d0
	move.w	oTunnelX(a0),d0
	sub.w	obj.x(a6),d0
	swap	d0
	divs.w	d2,d0
	moveq	#0,d1
	move.w	oTunnelY(a0),d1
	sub.w	obj.y(a6),d1
	beq.s	.SetSpeed2
	swap	d1
	divs.w	d0,d1

.SetSpeed2:
	move.w	d1,obj.y_speed(a6)
	move.w	d2,obj.x_speed(a6)
	tst.w	d0
	bpl.s	.SetSteps2
	neg.w	d0

.SetSteps2:
	move.w	d0,oTunnelSteps(a0)
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_SetPlayerGVel:
	move.w	#$1000,oPlayerGVel(a6)
	moveq	#0,d0
	move.b	obj.subtype(a0),d0
	bmi.s	.End
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	ObjTunnelPath_GVels(pc,d0.w),d0
	cmp.w	oPlayerGVel(a6),d0
	ble.s	.End
	move.w	d0,oPlayerGVel(a6)

.End:
	rts

; ------------------------------------------------------------------------------

ObjTunnelPath_GVels:
	dc.w	$1000
	dc.w	$C00
	dc.w	$C00
	dc.w	$800

ObjTunnelPath_Paths:
	dc.w	ObjTunnelPath_Path0-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path1-ObjTunnelPath_Paths
	dc.w	ObjTunnelPath_Path2-ObjTunnelPath_Paths

ObjTunnelPath_Path0:
	dc.w	$88
	dc.w	$1440, $F0
	dc.w	$1478, $108
	dc.w	$1490, $140
	dc.w	$1490, $1E0
	dc.w	$1440, $1F8
	dc.w	$1400, $1E0
	dc.w	$13F0, $1C0
	dc.w	$13F0, $180
	dc.w	$1400, $170
	dc.w	$1420, $168
	dc.w	$1440, $170
	dc.w	$1468, $1A8
	dc.w	$1660, $218
	dc.w	$16A0, $210
	dc.w	$16C0, $1F8
	dc.w	$16D0, $1C8
	dc.w	$16C0, $1A8
	dc.w	$1680, $198
	dc.w	$1658, $1A0
	dc.w	$1640, $1C8
	dc.w	$1650, $1F0
	dc.w	$1680, $200
	dc.w	$16C0, $200
	dc.w	$16D0, $210
	dc.w	$16D0, $288
	dc.w	$16C0, $2C0
	dc.w	$1680, $2D8
	dc.w	$1650, $2C0
	dc.w	$1650, $2A0
	dc.w	$1680, $290
	dc.w	$1700, $290
	dc.w	$1728, $2A0
	dc.w	$1728, $2E0
	dc.w	$1700, $2F0

ObjTunnelPath_Path1:
	dc.w	$44
	dc.w	$F08, $1A0
	dc.w	$F90, $1A0
	dc.w	$FC8, $1B8
	dc.w	$FE0, $1F0
	dc.w	$FE0, $260
	dc.w	$1000, $290
	dc.w	$1030, $2A0
	dc.w	$1068, $288
	dc.w	$1080, $250
	dc.w	$1068, $218
	dc.w	$1030, $200
	dc.w	$FF0, $220
	dc.w	$FE0, $260
	dc.w	$1000, $290
	dc.w	$1030, $2A0
	dc.w	$1068, $288
	dc.w	$1130, $1C8

ObjTunnelPath_Path2:
	dc.w	$44
	dc.w	$1630, $290
	dc.w	$1630, $318
	dc.w	$1638, $338
	dc.w	$16D0, $3D0
	dc.w	$1700, $3E0
	dc.w	$1738, $3C8
	dc.w	$1758, $390
	dc.w	$1738, $358
	dc.w	$16F8, $340
	dc.w	$16C0, $360
	dc.w	$16A8, $390
	dc.w	$16D0, $3D0
	dc.w	$1700, $3E0
	dc.w	$1738, $3C8
	dc.w	$17B8, $348
	dc.w	$17D0, $320
	dc.w	$17D0, $268

; ------------------------------------------------------------------------------
