.export init_random, get_random

.proc init_random
            lda #0
            sta next_random
            jmp refresh_randoms
.endproc

; loads A with a random value $00 - $ff
.proc get_random
            ldy next_random
            cpy #$ff
            bne @no_refresh
            jsr refresh_randoms
@no_refresh:
            lda random_buffer, y
            inc next_random
            rts
.endproc

.macro save_sid
            lda $d40e
            sta sid_stash
            lda $d40f
            sta sid_stash + 1
            lda $d412
            sta sid_stash + 2
.endmacro

.macro restore_sid
            lda sid_stash
            sta $d40e
            lda sid_stash + 1
            sta $d40f
            lda sid_stash + 2
            sta $d412
.endmacro

.proc refresh_randoms
            save_sid

            lda #$ff        ; maximum frequency value
            sta $d40e       ; voice 3 frequency low byte
            sta $d40f        ; voice 3 frequency high byte
            lda #$80        ; noise waveform, gate bit off
            sta $d412       ; voice 3 control register

            ldx #0
@loop:      lda $d41b
            sta random_buffer, x
            dex
            bne @loop

            restore_sid

            rts
.endproc

.zeropage
next_random:    .res 1

.bss
random_buffer:  .res 255
sid_stash:      .res 3
