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
            bundle "roms/15PUZZLE", "15 puzzle"
            bundle "roms/Airplane.ch8", "airplane"
            bundle "roms/Animal Race [Brian Astle].ch8", "animal race"
            bundle "roms/Astro Dodge [Revival Studios, 2008].ch8", "astro dodge"
            bundle "roms/Biorhythm [Jef Winsor].ch8", "biorhythm"
            bundle "roms/BLINKY", "blinky"
            bundle "roms/BLITZ", "blitz"
            bundle "roms/BRIX", "brix"
            ;bundle "roms/Bowling [Gooitzen van der Wal].ch8", "bowling"
            bundle "roms/Cave.ch8", "cave"
            bundle "roms/Coin Flipping [Carmelo Cortez, 1978].ch8", "coin flipping"
            bundle "roms/CONNECT4", "connect 4", connect4_enabled_keys, connect4_keymap
            bundle "roms/Craps [Camerlo Cortez, 1978].ch8", "craps"
            ;bundle "roms/Deflection [John Fort].ch8", "deflection"
            bundle "roms/Figures.ch8", "figures"
            bundle "roms/Filter.ch8", "filter"
            bundle "roms/GUESS", "guess"
            bundle "roms/HIDDEN", "hidden", hidden_enabled_keys, hidden_keymap
            bundle "roms/INVADERS", "invaders"
            bundle "roms/KALEID", "kaleid", , , $ff
            bundle "roms/Landing.ch8", "landing"
            ; bundle "roms/Lunar Lander (Udo Pernisz, 1979).ch8", "lunar lander"
            bundle "roms/Mastermind FourRow (Robert Lindley, 1978).ch8", "mastermind 4-row"
            bundle "roms/MAZE", "maze"
            bundle "roms/MERLIN", "merlin"
            bundle "roms/MISSILE", "missile"
            ; bundle "roms/Most Dangerous Game [Peter Maruhnic].ch8", "most dangerous"
            bundle "roms/Nim [Carmelo Cortez, 1978].ch8", "nim"
            bundle "roms/Paddles.ch8", "paddles"
            bundle "roms/PONG", "pong"
            bundle "roms/PONG2", "pong 2"
            bundle "roms/PUZZLE", "puzzle"
            bundle "roms/Reversi [Philip Baltzer].ch8", "reversi"
            bundle "roms/Rocket Launch [Jonas Lindstedt].ch8", "rocket launch"
            bundle "roms/Rocket Launcher.ch8", "rocket launcher"
            ; bundle "roms/Rush Hour [Hap, 2006].ch8", "rush hour"
            bundle "roms/Russian Roulette [Carmelo Cortez, 1978].ch8", "russian roulette"
            bundle "roms/Sequence Shoot [Joyce Weisbecker].ch8", "sequence shoot"
            bundle "roms/Shooting Stars [Philip Baltzer, 1978].ch8", "shooting stars"
            bundle "roms/Slide [Joyce Weisbecker].ch8", "slide"
            bundle "roms/Soccer.ch8", "soccer"
            bundle "roms/Space Flight.ch8", "space flight"
            bundle "roms/Space Intercept [Joseph Weisbecker, 1978].ch8", "space intercept"
            bundle "roms/Spooky Spot [Joseph Weisbecker, 1978].ch8", "spooky spot"
            bundle "roms/Squash [David Winter].ch8", "squash"
            bundle "roms/Submarine [Carmelo Cortez, 1978].ch8", "submarine"
            bundle "roms/Sum Fun [Joyce Weisbecker].ch8", "sum fun"
            bundle "roms/SYZYGY", "syzygy"
            bundle "roms/TANK", "tank", tank_enabled_keys, tank_keymap, $ff
            bundle "roms/Tapeworm [JDR, 1999].ch8", "tapeworm"
            bundle "roms/TETRIS", "tetris", tetris_enabled_keys, tetris_keymap
            bundle "roms/TICTAC", "tictac", tictac_enabled_keys, tictac_keymap
            bundle "roms/Timebomb.ch8", "timebomb"
            bundle "roms/Tron.ch8", "tron"
            bundle "roms/UFO", "ufo"
            bundle "roms/VBRIX", "vbrix"
            bundle "roms/VERS", "vers"
            bundle "roms/Wall [David Winter].ch8", "wall"
            bundle "roms/WIPEOFF", "wipeoff"
            bundle "roms/Worm V4 [RB-Revival Studios, 2007].ch8", "worm v4"
            bundle "roms/X-Mirror.ch8", "x-mirror"
            bundle "roms/ZeroPong [zeroZshadow, 2007].ch8", "zeropong"
