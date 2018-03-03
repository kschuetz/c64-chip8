.include "common.s"

.export initialize

.import build_bundle_index
.import build_chrome
.import build_decimal_table
.import build_screen_margins
.import check_host_model
.import chrome_charset
.import clear_ram
.import clear_screen
.import host_screen
.import init_buttons
.import init_button_sprites
.import init_charsets
.import init_colors
.import init_core
.import init_graphics_tables
.import init_keyboard
.import init_random
.import init_sound
.import init_timers
.import load_bundled_rom
.import reset
.import screen_charset
.import start
.import update_screen_color
.importzp screen_bgcolor
.importzp screen_fgcolor

.code

.proc initialize
            cld
            jsr check_host_model
            jsr init_random

            lda #$35                ; switch out BASIC and Kernal
            sta $1

            ;; after we have switched out BASIC and Kernal, it is safe to run code in INITCODE segment
            jsr init_nmi
            jsr initialize_phase_2

            lda $d011               ; re-enable screen
            ora #%00010000
            sta $d011
            rts
.endproc

.proc nmi
            rti
.endproc

.segment "INITCODE"

;; Disables 'restore' key
.proc init_nmi
            lda #<nmi             ; set NMI vector
            sta $0318
            sta $fffa
            lda #>nmi
            sta $0319
            sta $fffb
            lda #$81
            sta $dd0d             ; use Timer A
            lda #$01              ; Timer A count ($0001)
            sta $dd04
            lda #$00
            sta $dd05
            lda #%00011001        ; run Timer A
            sta $dd0e
            rts
.endproc

.proc init_vic
            lda $dd02           ; change VIC to bank 3
            ora #3
            sta $dd02
            lda $dd00
            and #$fc
            sta $dd00

            switch_vic_mem host_screen, chrome_charset

            lda $d011
            and #%10010000
            ora #%00001011
            sta $d011

            jmp init_button_sprites
.endproc

.proc initialize_phase_2
            lda #chrome_bgcolor
            sta $d020

            lda $d011               ; blank screen during initialization
            and #%11101111
            sta $d011

            jsr init_vic
            lda #$1f                ; disable CIA IRQs
            sta $dc0d
            sta $dd0d

            jsr init_timers
            jsr init_graphics_tables
            jsr build_decimal_table
            jsr build_bundle_index
            jsr init_core
            jsr init_keyboard
            jsr init_charsets
            jsr init_colors
            jsr init_buttons
            jsr init_sound

            lda screen_fgcolor
            jsr update_screen_color
            jsr clear_screen
            jsr build_screen_margins
            jsr build_chrome

            lda #default_rom_index
            jmp reset                   ; at this point, everything in INITCODE and INITDATA is clobbered
.endproc
