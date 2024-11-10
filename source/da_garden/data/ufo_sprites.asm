UfoSprites:
	dc.w	4
	dc.w	9, UfoSprite0-UfoSprites
	dc.w	9, UfoSprite1-UfoSprites
	dc.w	9, UfoSprite0-UfoSprites
	dc.w	9, UfoSprite2-UfoSprites
	
UfoDownSprites:
	dc.w	1
	dc.w	0, UfoSprite1-UfoDownSprites
	
UfoUpSprites:
	dc.w	1
	dc.w	0, UfoSprite2-UfoUpSprites
	
UfoSprite0:
	dc.w	1-1
	dc.w	$A00, 1, $C, -$C, $C, -$C
	
UfoSprite1:
	dc.w	1-1
	dc.w	$A00, $A, $C, -$C, $C, -$C
	
UfoSprite2:
	dc.w	1-1
	dc.w	$A00, $13, $C, -$C, $C, -$C
