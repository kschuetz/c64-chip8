.include "common.s"

.export exit_irq
.export setup_irq
.exportzp frame_counter

.import button_sprite_pointer
.import button_sprites_1
.import button_sprites_2
.import button_sprites_3
.import check_keyboard
.import check_ui_keys
.import chrome_charset
.import get_guest_keypress
.import host_screen
.import update_sound
.import screen_charset
.import set_button_sprite_frames
.import set_ui_action
.import sprite_pointers
.import title_bar_colors
.import update_timers
.importzp host_model
.importzp screen_bgcolor

.zeropage

frame_counter:     .res 2

.code

.define pal_63 0
.define ntsc_64 1
.define ntsc_65 2

.define pal_63_suffix "_pal_63"
.define ntsc_64_suffix "_ntsc_64"
.define ntsc_65_suffix "_ntsc_65"

.define host_screen_top "host_screen_top"
.define screen_top "screen_top"
.define frame_services "frame_services"
.define timer_update_3 "timer_update_3"
.define screen_bottom "screen_bottom"
.define chrome_top "chrome_top"
.define button_pic_1 "button_pic_1"
.define button_pic_2 "button_pic_2"

.macro stabilize model
            .local @wedge, @stable

            store16 IRQ_VECTOR, @wedge

            inc $d012
            lda #1
            sta $d019

            tsx
            cli

            .repeat 8
                nop
            .endrepeat
            .if model = ntsc_65
                nop
            .endif
@wedge:
            txs

            .if model = ntsc_64
                ldx #8
:               dex
                bne :-
                nop
                nop
            .elseif model = ntsc_65
                ldx #9
:               dex
                bne :-
            .else   ; pal_63
                ldx #8
:               dex
                bne :-
                bit $00
            .endif

            lda $d012
            cmp $d012
            beq @stable
@stable:
.endmacro

.macro begin_irq name, model
            .if model = ntsc_64
                .proc .ident(.concat(name, ntsc_64_suffix))
            .elseif model = ntsc_65
                .proc .ident(.concat(name, ntsc_65_suffix))
            .else
                .proc .ident(.concat(name, pal_63_suffix))
            .endif
            
            pha
            txa
            pha
            tya
            pha
.endmacro

.macro setup_next model, screen_line, name
            .local @vector

            .if model = ntsc_64
                @vector = .ident(.concat(name, ntsc_64_suffix))
            .elseif model = ntsc_65
                @vector = .ident(.concat(name, ntsc_65_suffix))
            .else
                @vector = .ident(.concat(name, pal_63_suffix))
            .endif

            lda #screen_line
            sta $d012
            store16 IRQ_VECTOR, @vector
            jmp exit_irq
.endmacro

.macro end_irq
            .endproc
.endmacro

.macro define_irqs model
    begin_irq host_screen_top, model
            lda #chrome_bgcolor
            sta $d020
            lda screen_bgcolor
            sta $d021
            jsr update_timers                         ; update_timers (1/4)
            setup_next model, 48, screen_top
    end_irq

    begin_irq screen_top, model
            stabilize model
            switch_vic_mem host_screen, screen_charset
            setup_next model, 64, frame_services
    end_irq

    begin_irq frame_services, model
            jsr check_keyboard

            jsr check_ui_keys
            jsr set_ui_action

            inc frame_counter
            bne :+
            inc frame_counter + 1
:
            jsr set_button_sprite_frames
            jsr update_sound
            jsr update_timers                          ; update_timers (2/4)
            setup_next model, 128, timer_update_3
    end_irq

    begin_irq timer_update_3, model
            jsr button_sprites_1
            jsr update_timers                          ; update_timers (3/4)
            setup_next model, 177, screen_bottom
    end_irq

    begin_irq screen_bottom, model
            stabilize model
            lda #chrome_bgcolor
            sta $d021
            sta $d020
            setup_next model, 184, chrome_top
    end_irq

    begin_irq chrome_top, model
            stabilize model
            switch_vic_mem host_screen, chrome_charset
            ldy #0
@next_line:
           .if model = ntsc_64
                ldx title_bar_wait_ntsc_64, y
           .elseif model = ntsc_65
                ldx title_bar_wait_ntsc_65, y
           .else
                ldx title_bar_wait_pal_63, y
           .endif
:           dex
            bne :-
            lda title_bar_colors, y
            sta $d021
            iny
            cpy #17
            bne @next_line

            setup_next model, 218, button_pic_1
    end_irq

    begin_irq button_pic_1, model
            jsr button_sprites_2
            setup_next model, 230, button_pic_2
    end_irq

    begin_irq button_pic_2, model
            jsr button_sprites_3        ; button_sprites_3 calls update_timers (4/4)
            setup_next model, 0, host_screen_top
    end_irq

.endmacro

.proc setup_irq
			sei
			ldy #0
			sty frame_counter
			sty frame_counter + 1
			ldy host_model
            dey 			            ; host_model is 1..4
            lda irq_entry_low, y
            sta IRQ_VECTOR
            lda irq_entry_high, y
            sta IRQ_VECTOR + 1
			lda $d011
			and #$7f
			sta $d011
			lda #0
			sta $d012
			lda #1
			sta $d01a
			lda #$7f
			sta $dc0d
			cli
			rts
.endproc

define_irqs pal_63

define_irqs ntsc_64

define_irqs ntsc_65

.proc exit_irq
            lda #1
            sta $d019
            pla
            tay
            pla
            tax
            pla
            rti
.endproc

.rodata

.define model_irqs host_screen_top_ntsc_64, host_screen_top_ntsc_65, host_screen_top_pal_63, host_screen_top_ntsc_65

irq_entry_low:      .lobytes model_irqs
irq_entry_high:     .hibytes model_irqs

;; host_model:
;; $01: OLD NTSC - 64 cycles
;; $02: NTSC - 65 cycles
;; $03: PAL - 63 cycles
;; $04: Drean - 65 cycles

title_bar_wait_ntsc_65:  .byte 7, 5, 8, 8, 8, 10, 9, 10, 9, 5, 8, 8, 8, 9, 10, 9, 10
title_bar_wait_ntsc_64:  .byte 7, 5, 8, 8, 8, 10, 9, 10, 7, 4, 8, 8, 9, 9, 10, 9, 10
title_bar_wait_pal_63:   .byte 7, 5, 8, 8, 8, 10, 9, 10, 6, 4, 8, 8, 8, 9, 10, 9, 10
