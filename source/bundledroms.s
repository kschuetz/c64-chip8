.include "defines.s"

.export bundle_start

.import connect4_enabled_keys
.import connect4_keymap
.import default_keymap
.import hidden_enabled_keys
.import hidden_keymap
.import tank_enabled_keys
.import tank_keymap
.import tetris_enabled_keys
.import tetris_keymap
.import tictac_enabled_keys
.import tictac_keymap

.macpack cbm

.segment "BUNDLE"

.macro bundle filename, title, enabled_key_mask, keymap_addr, key_repeat
            .local @end
            .word @end
            scrcode title
            .repeat (title_length - .strlen(title))
                .byte 0
            .endrep
            .ifnblank enabled_key_mask
                .word enabled_key_mask
            .else
                .word $ffff ; all keys enabled
            .endif
            .ifnblank keymap_addr
                .addr keymap_addr
            .else
                .addr default_keymap
            .endif
            .ifnblank key_repeat
                .byte $ff
            .else
                .byte 0
            .endif

            .incbin filename
@end:
.endmacro

bundle_start:
            bundle "roms/games/15 Puzzle [Roger Ivie].ch8", "15 puzzle"
            bundle "roms/games/Airplane.ch8", "airplane"
            bundle "roms/games/Animal Race [Brian Astle].ch8", "animal race"
            bundle "roms/games/Astro Dodge [Revival Studios, 2008].ch8", "astro dodge"
            bundle "roms/games/Biorhythm [Jef Winsor].ch8", "biorhythm"
            bundle "roms/games/Blinky [Hans Christian Egeberg, 1991].ch8", "blinky"
            bundle "roms/games/Blitz [David Winter].ch8", "blitz"
            bundle "roms/games/Brix [Andreas Gustafsson, 1990].ch8", "brix"
            ;bundle "roms/games/Bowling [Gooitzen van der Wal].ch8", "bowling"
            bundle "roms/games/Cave.ch8", "cave"
            bundle "roms/games/Coin Flipping [Carmelo Cortez, 1978].ch8", "coin flipping"
            bundle "roms/games/Connect 4 [David Winter].ch8", "connect 4", connect4_enabled_keys, connect4_keymap
            bundle "roms/games/Craps [Camerlo Cortez, 1978].ch8", "craps"
            ;bundle "roms/games/Deflection [John Fort].ch8", "deflection"
            bundle "roms/games/Figures.ch8", "figures"
            bundle "roms/games/Filter.ch8", "filter"
            bundle "roms/games/Guess [David Winter].ch8", "guess"
            bundle "roms/games/Hidden [David Winter, 1996].ch8", "hidden", hidden_enabled_keys, hidden_keymap
            bundle "roms/games/Kaleidoscope [Joseph Weisbecker, 1978].ch8", "kaleid", , , $ff
            bundle "roms/games/Landing.ch8", "landing"
            ; bundle "roms/games/Lunar Lander (Udo Pernisz, 1979).ch8", "lunar lander"
            bundle "roms/games/Mastermind FourRow (Robert Lindley, 1978).ch8", "mastermind 4-row"
            bundle "roms/demos/Maze [David Winter, 199x].ch8", "maze"
            bundle "roms/games/Merlin [David Winter].ch8", "merlin"
            bundle "roms/games/Missile [David Winter].ch8", "missile"
            ; bundle "roms/games/Most Dangerous Game [Peter Maruhnic].ch8", "most dangerous"
            bundle "roms/games/Nim [Carmelo Cortez, 1978].ch8", "nim"
            bundle "roms/games/Paddles.ch8", "paddles"
            bundle "roms/games/Pong [Paul Vervalin, 1990].ch8", "pong"
            bundle "roms/games/Pong 2 (Pong hack) [David Winter, 1997].ch8", "pong 2"
            bundle "roms/games/Puzzle.ch8", "puzzle"
            bundle "roms/games/Reversi [Philip Baltzer].ch8", "reversi"
            bundle "roms/games/Rocket Launch [Jonas Lindstedt].ch8", "rocket launch"
            bundle "roms/games/Rocket Launcher.ch8", "rocket launcher"
            ; bundle "roms/games/Rush Hour [Hap, 2006].ch8", "rush hour"
            bundle "roms/games/Russian Roulette [Carmelo Cortez, 1978].ch8", "russian roulette"
            bundle "roms/games/Sequence Shoot [Joyce Weisbecker].ch8", "sequence shoot"
            bundle "roms/games/Shooting Stars [Philip Baltzer, 1978].ch8", "shooting stars"
            bundle "roms/games/Slide [Joyce Weisbecker].ch8", "slide"
            bundle "roms/games/Soccer.ch8", "soccer"
            bundle "roms/games/Space Flight.ch8", "space flight"
            bundle "roms/games/Space Intercept [Joseph Weisbecker, 1978].ch8", "space intercept"
            bundle "roms/games/Space Invaders [David Winter].ch8", "invaders"
            bundle "roms/games/Spooky Spot [Joseph Weisbecker, 1978].ch8", "spooky spot"
            bundle "roms/games/Squash [David Winter].ch8", "squash"
            bundle "roms/games/Submarine [Carmelo Cortez, 1978].ch8", "submarine"
            bundle "roms/games/Sum Fun [Joyce Weisbecker].ch8", "sum fun"
            bundle "roms/games/Syzygy [Roy Trevino, 1990].ch8", "syzygy"
            bundle "roms/games/Tank.ch8", "tank", tank_enabled_keys, tank_keymap, $ff
            bundle "roms/games/Tapeworm [JDR, 1999].ch8", "tapeworm"
            bundle "roms/games/Tetris [Fran Dachille, 1991].ch8", "tetris", tetris_enabled_keys, tetris_keymap
            bundle "roms/games/Tic-Tac-Toe [David Winter].ch8", "tictac", tictac_enabled_keys, tictac_keymap
            bundle "roms/games/Timebomb.ch8", "timebomb"
            bundle "roms/games/Tron.ch8", "tron"
            bundle "roms/games/UFO [Lutz V, 1992].ch8", "ufo"
            bundle "roms/games/Vertical Brix [Paul Robson, 1996].ch8", "vbrix"
            bundle "roms/games/Vers [JMN, 1991].ch8", "vers"
            bundle "roms/games/Wall [David Winter].ch8", "wall"
            bundle "roms/games/Wipe Off [Joseph Weisbecker].ch8", "wipeoff"
            bundle "roms/games/Worm V4 [RB-Revival Studios, 2007].ch8", "worm v4"
            bundle "roms/games/X-Mirror.ch8", "x-mirror"
            bundle "roms/games/ZeroPong [zeroZshadow, 2007].ch8", "zeropong"
