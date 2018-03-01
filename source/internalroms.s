.include "common.s"
.include "bundlehelpers.s"

.export internal_roms_start

.import external_roms_start
.import default_keymap

.segment "INTERNALROMS"

internal_roms_start:
title_screen_header:
            .addr external_roms_start
            rom_title "welcome"
            .word $ffff
            .addr default_keymap
            .byte true

.proc title_screen
            .byte $a0 | >title_screen_graphics_guest
            .byte <title_screen_graphics_guest          ; LD I, title_screen_graphics

            .byte $62, $10      ; LD v2, 16
            .byte $63, 8        ; LD v3, 8
            .byte $60, $00      ; LD v0, 0
            .byte $61, $00      ; LD v1, 0
@loop1 = $200 + (* - title_screen)
            .byte $d0, $1f      ; DRW v0, v1, 15
            .byte $f2, $1e      ; ADD I, v2
            .byte $70, $08      ; ADD v0, 8
            .byte $73, $ff      ; ADD v3, $ff
            .byte $33, $00      ; SKP v3, 0
            .byte $10 | >@loop1
            .byte <@loop1       ; JP loop1
            .byte $63, 8        ; LD, v3, 8
            .byte $60, $00      ; LD v0, 0
            .byte $61, $10      ; LD v1, 16
@loop2 = $200 + (* - title_screen)
            .byte $d0, $1f      ; DRW v0, v1, 15
            .byte $f2, $1e      ; ADD I, v2
            .byte $70, $08      ; ADD v0, 8
            .byte $73, $ff      ; ADD v3, $ff
            .byte $33, $00      ; SKP v3, 0
            .byte $10 | >@loop2
            .byte <@loop2       ; JP loop2

@done = $200 + (* - title_screen)
            .byte $10 | >@done
            .byte <@done
.endproc            

title_screen_graphics_host:
            .incbin "data/title-screen.bin", 0, $100

title_screen_graphics_guest := $200 + title_screen_graphics_host - title_screen
