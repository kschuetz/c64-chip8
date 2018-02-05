.export bundle_start

.include "defines.s"

.macpack cbm

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
		bundle "roms/15PUZZLE", "15 puzzle"
		bundle "roms/BLINKY", "blinky"
		bundle "roms/BLITZ", "blitz"
		bundle "roms/BRIX", "brix"
		bundle "roms/CONNECT4", "connect 4"
		bundle "roms/GUESS", "guess"
		bundle "roms/HIDDEN", "hidden"
		bundle "roms/INVADERS", "invaders"
		bundle "roms/KALEID", "kaleid"
		bundle "roms/MAZE", "maze"
		bundle "roms/MERLIN", "merlin"
		bundle "roms/MISSILE", "missile"
		bundle "roms/PONG", "pong"
		bundle "roms/PONG2", "pong 2"
		bundle "roms/PUZZLE", "puzzle"
		bundle "roms/SYZYGY", "syzygy"
		bundle "roms/TANK", "tank"
		bundle "roms/TETRIS", "tetris"
		bundle "roms/TICTAC", "tictac"
		bundle "roms/UFO", "ufo"
		bundle "roms/VBRIX", "vbrix"
		bundle "roms/VERS", "vers"
		bundle "roms/WIPEOFF", "wipeoff"
