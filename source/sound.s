.include "common.s"

.export init_sound
.exportzp sound_enabled

.zeropage

sound_enabled:      .res 1

.segment "INITCODE"

.proc init_sound
            lda #0                  ; disabled by default
            sta sound_enabled
            rts
.endproc

.code
