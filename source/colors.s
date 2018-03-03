.include "common.s"

.export init_colors
.export title_bar_colors
.exportzp screen_bgcolor
.exportzp screen_fgcolor

.zeropage

screen_bgcolor:     .res 1
screen_fgcolor:     .res 1

.segment "INITCODE"

.proc init_colors
            lda #default_screen_bgcolor
            sta screen_bgcolor
            lda #default_screen_fgcolor
            sta screen_fgcolor
            rts
.endproc

.rodata

title_bar_colors:
            .byte 11, 12, 15, 1, 15, 1, 1, 1, 1, 1, 1, 15, 1, 15, 12, 11, chrome_bgcolor
