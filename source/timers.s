;; Timers (delay_timer and sound_timer) are 16-bits and are updated 4 times per frame, called at various positions of the raster.
;; The amount to decrement on each update depends on CPU model (PAL is 50Hz and NTSC is 60Hz).  The goal is to get as close to a 60Hz
;; timer (the official CHIP-8 frequency) as possible, regardless of host model.
;; Applications only have access to the upper 8-bits of the timers.

.include "common.s"

.export clear_timers
.export init_timers
.export set_delay_timer
.export set_sound_timer
.export update_timers
.exportzp delay_timer
.exportzp sound_timer

.import new_exit_irq
.importzp host_model
.importzp paused

.zeropage

delay_timer:        .res 1
sound_timer:        .res 1
delay_timer_fine:   .res 1
sound_timer_fine:   .res 1

.code

; A - new value for timer
.proc set_delay_timer
            sta delay_timer
            lda #$ff
            sta delay_timer_fine
            rts
.endproc

; A - new value for timer
.proc set_sound_timer
            sta sound_timer
            lda #$ff
            sta sound_timer_fine
            rts
.endproc

.proc clear_timers
            lda #0
            sta delay_timer
            sta delay_timer_fine
            sta sound_timer
            sta sound_timer_fine
            rts
.endproc

;; Call this 4 times per frame
.proc update_timers

delay_dec_value = dec_delay + 1
sound_dec_value = dec_sound + 1
            lda paused
            bne done                       ; don't update timers if paused

            ldx delay_timer
            beq check_sound_timer          ; skip if off
            sec
            lda delay_timer_fine
dec_delay:
            sbc #$40                       ; operand will be modified by init_timers on startup
            sta delay_timer_fine
            bcs check_sound_timer          ; no borrow, so timer won't change

                                           ; x contains nonzero here
            dex
            stx delay_timer

check_sound_timer:
            ldx sound_timer
            beq done                       ; skip if off
            sec
            lda sound_timer_fine
dec_sound:
            sbc #$40                       ; operand will be modified by init_timers on startup
            sta sound_timer_fine
            bcs done                       ; no borrow, so timer won't change

                                           ; x contains nonzero here
            dex
            stx sound_timer

done:       rts

.endproc

.segment "INITCODE"

;; fine counters are decremented 4 times per frame
ntsc_decrement_amount = 64     ; 256 / 4
pal_decrement_amount = 76      ; (312/262) * ntsc

;; modifies the update_timers routine depending on host model
.proc init_timers
            ldx host_model
            dex
            beq @ntsc                       ; 1 or 2: ntsc
            dex
            beq @ntsc
            lda #pal_decrement_amount       ; otherwise pal
            bne @modify
@ntsc:      lda #ntsc_decrement_amount
@modify:    sta update_timers::delay_dec_value
            sta update_timers::sound_dec_value
            rts
.endproc
