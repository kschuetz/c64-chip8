.include "common.s"

.export init_sound
.export update_sound
.exportzp sound_enabled

.importzp frame_counter
.importzp paused
.importzp sound_timer

.zeropage

sound_enabled:      .res 1
sound_playing:      .res 1

.segment "INITCODE"

.proc init_sound
            lda #0                  ; disabled by default
            sta sound_enabled
            sta sound_playing
            rts
.endproc

.code

; Make sound only if all three are true:
; 1.  sound_enabled is true
; 2.  paused is false
; 3.  sound_timer is nonzero
.proc update_sound
            lda sound_enabled
            beq no_sound
            lda paused
            bne beep_off
            lda sound_timer
            beq beep_off
            ; continue to beep_on
.endproc


.proc beep_on
            lda sound_playing
            bne @playing

            lda #$9c
            sta $d400       ; freq lo
            lda #$1b
            sta $d401       ; freq hi
            lda #$11
            sta $d405       ; AD
            lda #$68
            sta $d406       ; SR
            lda #65
            sta $d404       ; pulse

            lda #15
            sta $d418       ; volume

            lda #1
            sta sound_playing
@playing:
.endproc

.proc update_pulse_envelope
            lda #3
            sta $d403

            lda frame_counter
            bpl @low
            eor #$ff
            clc
            adc #1
@low:
            asl a
            sta $d402

            rts
.endproc

.proc beep_off
            lda sound_playing
            bne @playing
            rts

@playing:   lda #64
            sta $d404       ; gate off
                   
            lda #0
            sta sound_playing
            jmp update_pulse_envelope
.endproc

.proc no_sound
            lda #0
            sta sound_playing
            sta $d418
            rts
.endproc
