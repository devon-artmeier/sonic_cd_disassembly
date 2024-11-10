Stomp_Header:
	smpsHeaderStartSong	$07
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cPCM7, Stomp_PCM7, $00, $FF

Stomp_PCM7:
	smpsSetvoice	sStomp
	dc.b	nD1, $04, nCs2, $1E
	smpsStop
