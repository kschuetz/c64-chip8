.export blitz_enabled_keys: absolute
.export brix_enabled_keys: absolute
.export connect4_enabled_keys: absolute
.export default_keymap
.export delay_time_test_enabled_keys
.export hidden_enabled_keys
.export merlin_enabled_keys
.export missile_enabled_keys
.export nim_enabled_keys
.export slide_enabled_keys
.export space_invaders_enabled_keys: absolute
.export tank_enabled_keys
.export tank_keymap
.export tetris_enabled_keys: absolute
.export tetris_keymap
.export tictac_enabled_keys
.export tictac_keymap
.export ufo_enabled_keys: absolute
.exportzp active_keymap

.zeropage

active_keymap:  .res 2

; Keymaps:
; physical_key_to_test = keymap[logical_key]
; if no physical key for a logical key, map to $ff

.rodata

; The default layout of the Chip 8 keyboard:
;
; 1	2 3	C
; 4 5 6 D
; 7 8 9 E
; A 0 B F
;
; Physical layout:
;
; 0 1 2 3
; 4 5 6 7
; 8 9 A B
; C D E F

default_keymap:
            .byte $d, $0, $1, $2
            .byte $4, $5, $6, $8
            .byte $9, $a, $c, $e
            .byte $3, $7, $b, $f

; Tank logical keys:
; left: 4
; right: 6
; up: 8
; down: 2
; fire: 5

tank_keymap:
            .byte $ff, $ff, $9, $ff
            .byte $4, $5, $6, $ff
            .byte $1, $ff, $ff, $ff
            .byte $ff, $ff, $ff, $ff

;                    FEDCBA9876543210
tank_enabled_keys = %0000001001110010

; Tetris logical keys:
; left: 5
; right: 6
; rotate: 4
; drop:   7

tetris_keymap:
            .byte $ff, $ff, $ff, $ff
            .byte $5, $4, $6, $1
            .byte $ff, $ff, $ff, $ff
            .byte $ff, $ff, $ff, $ff

;                      FEDCBA9876543210
tetris_enabled_keys = %0000000001110010

; Tic Tac
; 23Cx
; 456x
; D78x
; xxxx

tictac_keymap:
            .byte $ff, $0, $1, $2
            .byte $4, $5, $6, $8
            .byte $9, $a, $ff, $ff
            .byte $ff, $ff, $ff, $ff

;                      FEDCBA9876543210
tictac_enabled_keys = %0000011101110111

;                        FEDCBA9876543210
connect4_enabled_keys = %0000000001110000

;                      FEDCBA9876543210
hidden_enabled_keys = %0000001001110010

;                     FEDCBA9876543210
slide_enabled_keys = %0010000000000000

;                              FEDCBA9876543210
space_invaders_enabled_keys = %0000000001110000

;                    FEDCBA9876543210
brix_enabled_keys = %0000000001010000

;                     FEDCBA9876543210
blitz_enabled_keys = %0000000000100000

;                               FEDCBA9876543210
delay_time_test_enabled_keys = %0000001000100010

;                   FEDCBA9876543210
ufo_enabled_keys = %0000000001110000

;                      FEDCBA9876543210
merlin_enabled_keys = %0000001100110000

;                       FEDCBA9876543210
missile_enabled_keys = %0000001000000000

;                   FEDCBA9876543210
nim_enabled_keys = %1000000000000111