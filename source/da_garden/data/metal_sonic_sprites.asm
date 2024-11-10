MetalSonicSprites:
	dc.w	3
	dc.w	1, MetalSonicSprite0-MetalSonicSprites
	dc.w	1, MetalSonicSprite1-MetalSonicSprites
	dc.w	2, MetalSonicSprite2-MetalSonicSprites
	
MetalSonicBackUpSprites:
	dc.w	3
	dc.w	1, MetalSonicSprite0-MetalSonicBackUpSprites
	dc.w	1, MetalSonicSprite1-MetalSonicBackUpSprites
	dc.w	1, MetalSonicSprite2-MetalSonicBackUpSprites
	
MetalSonicSprite0:
	dc.w	3-1
	dc.w	$F00, $13, $10, $10, $18, $18
	dc.w	$D00, $23, $10, $10, -8, -8
	dc.w	$A00, 1, $1C, -5, $C, -$C
	
MetalSonicSprite1:
	dc.w	3-1
	dc.w	$F00, $13, $10, $10, $18, $18
	dc.w	$D00, $23, $10, $10, -8, -8
	dc.w	$A00, $1001, $1C, -5, $C, -$C
	
MetalSonicSprite2:
	dc.w	2-1
	dc.w	$F00, $13, $10, $10, $18, $18
	dc.w	$D00, $23, $10, $10, -8, -8
	