Stomp_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Stomp_PCM7, $05, $FF

Stomp_PCM7:
	smpsSetvoice	sStomp
	dc.b	nA1, $1C
	smpsStop
