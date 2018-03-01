.include "common.s"
.include "bundlehelpers.s"

.export external_roms_start

.import blitz_enabled_keys
.import brix_enabled_keys
.import connect4_enabled_keys
.import default_keymap
.import delay_time_test_enabled_keys
.import hidden_enabled_keys
.import merlin_enabled_keys
.import missile_enabled_keys
.import nim_enabled_keys
.import slide_enabled_keys
.import space_invaders_enabled_keys
.import tank_enabled_keys
.import tank_keymap
.import tetris_enabled_keys
.import tetris_keymap
.import tictac_enabled_keys
.import tictac_keymap
.import ufo_enabled_keys

.segment "EXTERNALROMS"

external_roms_start:
            bundle "roms/games/15 Puzzle [Roger Ivie].ch8", "15 puzzle"
            bundle "roms/games/Airplane.ch8", "airplane"
            bundle "roms/games/Animal Race [Brian Astle].ch8", "animal race"
            bundle "roms/games/Astro Dodge [Revival Studios, 2008].ch8", "astro dodge"
            bundle "roms/games/Biorhythm [Jef Winsor].ch8", "biorhythm"
            bundle "roms/games/Blinky [Hans Christian Egeberg, 1991].ch8", "blinky"
            bundle "roms/games/Blitz [David Winter].ch8", "blitz", blitz_enabled_keys
            bundle "roms/games/Bowling [Gooitzen van der Wal].ch8", "bowling"
            bundle "roms/games/Brix [Andreas Gustafsson, 1990].ch8", "brix", brix_enabled_keys, , false
            bundle "roms/games/Cave.ch8", "cave"
            bundle "roms/games/Coin Flipping [Carmelo Cortez, 1978].ch8", "coin flipping"
            bundle "roms/games/Connect 4 [David Winter].ch8", "connect 4", connect4_enabled_keys
            bundle "roms/games/Craps [Camerlo Cortez, 1978].ch8", "craps"
            bundle "roms/games/Deflection [John Fort].ch8", "deflection"
            bundle "roms/games/Figures.ch8", "figures"
            bundle "roms/games/Filter.ch8", "filter"
            bundle "roms/games/Guess [David Winter].ch8", "guess"
            bundle "roms/games/Hidden [David Winter, 1996].ch8", "hidden", hidden_enabled_keys
            bundle "roms/games/Kaleidoscope [Joseph Weisbecker, 1978].ch8", "kaleid", , , false
            bundle "roms/games/Landing.ch8", "landing"
            bundle "roms/games/Lunar Lander (Udo Pernisz, 1979).ch8", "lunar lander"
            bundle "roms/games/Mastermind FourRow (Robert Lindley, 1978).ch8", "mastermind 4-row"
            bundle "roms/games/Merlin [David Winter].ch8", "merlin", merlin_enabled_keys
            bundle "roms/games/Missile [David Winter].ch8", "missile", missile_enabled_keys
            bundle "roms/games/Most Dangerous Game [Peter Maruhnic].ch8", "most dangerous"
            bundle "roms/games/Nim [Carmelo Cortez, 1978].ch8", "nim", nim_enabled_keys
            bundle "roms/games/Paddles.ch8", "paddles"
            bundle "roms/games/Pong 2 (Pong hack) [David Winter, 1997].ch8", "pong 2"
            bundle "roms/games/Pong [Paul Vervalin, 1990].ch8", "pong"
            bundle "roms/games/Puzzle.ch8", "puzzle"
            bundle "roms/games/Reversi [Philip Baltzer].ch8", "reversi"
            bundle "roms/games/Rocket Launch [Jonas Lindstedt].ch8", "rocket launch"
            bundle "roms/games/Rocket Launcher.ch8", "rocket launcher"
            bundle "roms/games/Rush Hour [Hap, 2006].ch8", "rush hour"
            bundle "roms/games/Russian Roulette [Carmelo Cortez, 1978].ch8", "russian roulette"
            bundle "roms/games/Sequence Shoot [Joyce Weisbecker].ch8", "sequence shoot"
            bundle "roms/games/Shooting Stars [Philip Baltzer, 1978].ch8", "shooting stars"
            bundle "roms/games/Slide [Joyce Weisbecker].ch8", "slide", slide_enabled_keys, , false
            bundle "roms/games/Soccer.ch8", "soccer"
            bundle "roms/games/Space Flight.ch8", "space flight"
;            bundle "roms/games/Space Intercept [Joseph Weisbecker, 1978].ch8", "space intercept"
            bundle "roms/games/Space Invaders [David Winter].ch8", "space invaders", space_invaders_enabled_keys, , false
            bundle "roms/games/Spooky Spot [Joseph Weisbecker, 1978].ch8", "spooky spot"
            bundle "roms/games/Squash [David Winter].ch8", "squash"
            bundle "roms/games/Submarine [Carmelo Cortez, 1978].ch8", "submarine"
            bundle "roms/games/Sum Fun [Joyce Weisbecker].ch8", "sum fun"
            bundle "roms/games/Syzygy [Roy Trevino, 1990].ch8", "syzygy"
            bundle "roms/games/Tank.ch8", "tank", tank_enabled_keys, tank_keymap, false
            bundle "roms/games/Tapeworm [JDR, 1999].ch8", "tapeworm"
            bundle "roms/games/Tetris [Fran Dachille, 1991].ch8", "tetris", tetris_enabled_keys, tetris_keymap
            bundle "roms/games/Tic-Tac-Toe [David Winter].ch8", "tictac", tictac_enabled_keys, tictac_keymap
            bundle "roms/games/Timebomb.ch8", "timebomb"
            bundle "roms/games/Tron.ch8", "tron"
            bundle "roms/games/UFO [Lutz V, 1992].ch8", "ufo", ufo_enabled_keys
            bundle "roms/games/Vers [JMN, 1991].ch8", "vers"
            bundle "roms/games/Vertical Brix [Paul Robson, 1996].ch8", "vbrix"
            bundle "roms/games/Wall [David Winter].ch8", "wall"
            bundle "roms/games/Wipe Off [Joseph Weisbecker].ch8", "wipeoff"
            bundle "roms/games/Worm V4 [RB-Revival Studios, 2007].ch8", "worm v4"
            bundle "roms/games/X-Mirror.ch8", "x-mirror"
            bundle "roms/games/ZeroPong [zeroZshadow, 2007].ch8", "zeropong"
            bundle "roms/demos/Maze [David Winter, 199x].ch8", "maze"
            bundle "roms/demos/Particle Demo [zeroZshadow, 2008].ch8", "particle demo"
            bundle "roms/demos/Sierpinski [Sergey Naydenov, 2010].ch8", "sierpinski"
            bundle "roms/demos/Stars [Sergey Naydenov, 2010].ch8", "stars"
;            bundle "roms/demos/Trip8 Demo (2008) [Revival Studios].ch8", "trip8 demo"
            bundle "roms/demos/Zero Demo [zeroZshadow, 2007].ch8", "zero demo"
            bundle "roms/programs/BMP Viewer - Hello (C8 example) [Hap, 2005].ch8", "hello"
            bundle "roms/programs/Chip8 Picture.ch8", "chip8 picture"
            bundle "roms/programs/Chip8 emulator Logo [Garstyciuks].ch8", "chip8 logo"
            bundle "roms/programs/Clock Program [Bill Fisher, 1981].ch8", "clock"
            bundle "roms/programs/Delay Timer Test [Matthew Mikolay, 2010].ch8", "delay timer test", delay_time_test_enabled_keys
;            bundle "roms/programs/Division Test [Sergey Naydenov, 2010].ch8", "division test"
;            bundle "roms/programs/Fishie [Hap, 2005].ch8", "fishie"
            bundle "roms/programs/Framed MK1 [GV Samways, 1980].ch8", "framed mk1"
            bundle "roms/programs/Framed MK2 [GV Samways, 1980].ch8", "framed mk2"
            bundle "roms/programs/IBM Logo.ch8", "ibm logo"
            bundle "roms/programs/Jumping X and O [Harry Kleinberg, 1977].ch8", "jumping x & o"
            bundle "roms/programs/Keypad Test [Hap, 2006].ch8", "keypad test"
            bundle "roms/programs/Life [GV Samways, 1980].ch8", "life"
            bundle "roms/programs/Minimal game [Revival Studios, 2007].ch8", "minimal game"
            bundle "roms/programs/Random Number Test [Matthew Mikolay, 2010].ch8", "random test"
            bundle "roms/programs/SQRT Test [Sergey Naydenov, 2010].ch8", "sqrt test"
