.export init_timers, update_timers, clear_timers, set_delay_timer, set_sound_timer
.exportzp delay_timer, sound_timer

.import exit_irq
.importzp host_model, paused

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

; call this 4 times per frame
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
            sbc #$40                       ; operand will be modifier by init_timers on startup
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
            sbc #$40                       ; operand will be modifier by init_timers on startup
            sta sound_timer_fine
            bcs done                       ; no borrow, so timer won't change won't change

                                           ; x contains nonzero here
            dex
            stx sound_timer

done:       jmp exit_irq

.endproc

;; fine counters are decremented 4 times per frame
ntsc_decrement_amount = 64     ; 256 / 4
pal_decrement_amount = 76      ; (312/262) * ntsc

; modifies the update_timers routine
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