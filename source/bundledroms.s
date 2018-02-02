.export bundle_start
.export invaders_rom, invaders_rom_size
.export title_length

	.macpack cbm
	
title_length = 16

	.segment "BUNDLE"


	.macro bundle filename, title
		.local @end
		.word @end
		scrcode title
		.repeat (title_length - .strlen(title))
		.byte 0
		.endrep
		.incbin filename
@end:
	.endmacro



bundle_start:	
	bundle "roms/15PUZZLE", "15 PUZZLE"
	bundle "roms/BLINKY", "BLINKY"
	bundle "roms/BLITZ", "BLITZ"
	bundle "roms/BRIX", "BRIX"
	bundle "roms/CONNECT4", "CONNECT 4"
	bundle "roms/GUESS", "GUESS"
	bundle "roms/HIDDEN", "HIDDEN"
invaders_start:	
	bundle "roms/INVADERS", "INVADERS"
invaders_end:	
	bundle "roms/KALEID", "KALEID"
	bundle "roms/MAZE", "MAZE"
	bundle "roms/MERLIN", "MERLIN"
	bundle "roms/MISSILE", "MISSILE"
	bundle "roms/PONG", "PONG"
	bundle "roms/PONG2", "PONG 2"
	bundle "roms/PUZZLE", "PUZZLE"
	bundle "roms/SYZYGY", "SYZYGY"
	bundle "roms/TANK", "TANK"
	bundle "roms/TETRIS", "TETRIS"
	bundle "roms/TICTAC", "TICTAC"
	bundle "roms/UFO", "UFO"
	bundle "roms/VBRIX", "VBRIX"
	bundle "roms/VERS", "VERS"
	bundle "roms/WIPEOFF", "WIPEOFF"


invaders_rom = invaders_start + 2 + title_length
invaders_rom_size = invaders_end - invaders_rom
