.export default_keymap
.exportzp active_keymap

.zeropage
active_keymap:  .res 2


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
