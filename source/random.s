.include "common.s"

.export get_random
.export init_random

.zeropage

random_seed:        .res 4
random_seed_arg:    .res 4

.segment "INITCODE"

;; Initializes random_seed from SID noise generator
.proc init_random
            lda #$ff
            sta $d40e
            sta $d40f

            lda #143
            sta $d418

            lda #129
            sta $d412

            ldy #3
@loop:      lda $d41b
            sta random_seed, y

            nop
            nop
            nop
            nop
            nop
            nop
            nop

            dey
            bpl @loop

            rts
.endproc

.code

;; loads A with a random value $00 - $ff
.proc get_random
            lda random_seed + 3
            asl a
            sta random_seed_arg + 3
            
            ; rotate 3
            lda random_seed + 2
            rol a
            sta random_seed_arg + 2

            ; rotate 2
            lda random_seed + 1
            rol a
            sta random_seed_arg + 1

            ; rotate 1
            lda random_seed + 0
            rol a
            sta random_seed_arg + 0

            sec
            rol random_seed_arg + 3
            rol random_seed_arg + 2
            rol random_seed_arg + 1
            rol random_seed_arg + 0
            clc
            
            ;; add 4
            lda random_seed_arg + 3
            adc random_seed + 3
            sta random_seed_arg + 3
            pha
                
            ;; add 3
            lda random_seed_arg + 2
            adc random_seed + 2
            sta random_seed_arg + 2

            pha
            ;; add 2
            lda random_seed_arg + 1
            adc random_seed + 1
            sta random_seed_arg + 1

            ;; add 1
            lda random_seed_arg + 0
            adc random_seed + 0
            sta random_seed_arg + 0

            clc
            lda random_seed_arg + 1
            adc random_seed + 3
            sta random_seed + 1
            lda random_seed_arg + 0
            adc random_seed + 2
            sta random_seed + 0
            pla
            sta random_seed + 2
            pla
            sta random_seed + 3
            lda random_seed + 0      ; most significant byte
            rts
.endproc
