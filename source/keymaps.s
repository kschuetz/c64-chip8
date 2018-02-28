.export default_keymap, tictac_keymap, tetris_keymap, tank_keymap, connect4_keymap, hidden_keymap
.export tictac_enabled_keys, tetris_enabled_keys: absolute, tank_enabled_keys
.export connect4_enabled_keys: absolute, hidden_enabled_keys
.export slide_enabled_keys
.export space_invaders_enabled_keys: absolute
.export brix_enabled_keys: absolute
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
; left: 8
; right: 9
; up: A
; down: 7
; fire: 0


tank_keymap:
            .byte $5, $ff, $ff, $ff
            .byte $ff, $ff, $ff, $9
            .byte $4, $6, $1, $ff
            .byte $ff, $ff, $ff, $ff

;                    FEDCBA9876543210
tank_enabled_keys = %0000001001110010

; Tetris logical keys:
; left: 7
; right: 8
; rotate: 9
; drop:   2

; enabled keys:

tetris_keymap:
            .byte $ff, $ff, $1, $ff
            .byte $ff, $ff, $ff, $4
            .byte $6, $5, $ff, $ff
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


connect4_keymap = default_keymap

;                        FEDCBA9876543210
connect4_enabled_keys = %0000000001110000

hidden_keymap = default_keymap

;                      FEDCBA9876543210
hidden_enabled_keys = %0000001001110010


;                     FEDCBA9876543210
slide_enabled_keys = %0010000000000000


;                              FEDCBA9876543210
space_invaders_enabled_keys = %0000000001110000

;                    FEDCBA9876543210
brix_enabled_keys = %0000000001010000