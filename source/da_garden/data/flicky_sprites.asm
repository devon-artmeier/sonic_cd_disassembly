FlickySprites:
	dc.w	2
	dc.w	3, FlickySprite0-FlickySprites
	dc.w	3, FlickySprite1-FlickySprites
	
FlickySlowSprites:
	dc.w	2
	dc.w	8, FlickySprite0-FlickySlowSprites
	dc.w	8, FlickySprite1-FlickySlowSprites
	
FlickyCatchUpSprites:
	dc.w	2
	dc.w	1, FlickySprite0-FlickyCatchUpSprites
	dc.w	1, FlickySprite1-FlickyCatchUpSprites
	
FlickyGlideSprites:
	dc.w	1
	dc.w	0, FlickySprite0-FlickyGlideSprites
	
FlickySprite0:
	dc.w	1-1
	dc.w	$500, 0, 8, -8, 8, -8
	
FlickySprite1:
	dc.w	1-1
	dc.w	$500, 4, 8, -8, 8, -8
	