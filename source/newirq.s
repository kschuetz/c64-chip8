.export new_setup_irq, new_exit_irq

.import host_screen, screen_charset, chrome_charset, check_keyboard, get_guest_keypress, keyboard_debug
.import update_timers
.import check_ui_keys, set_ui_action
.importzp frame_counter, screen_bgcolor

.include "common.s"

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
.define timer_update_4 "timer_update_4"

.macro stabilize model
            .local @wedge, @stable

            istore IRQ_VECTOR, @wedge

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

.macro def_irq name, model
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
            istore IRQ_VECTOR, @vector
            jmp new_exit_irq
.endmacro

.macro end_def
            .endproc
.endmacro


.macro define_irqs model
    def_irq host_screen_top, model
            lda #chrome_bgcolor
            sta $d020
            lda screen_bgcolor
            sta $d021
            jsr update_timers
            setup_next model, 48, screen_top
    end_def

    def_irq screen_top, model
            stabilize model
            switch_vic_mem host_screen, screen_charset
            setup_next model, 64, frame_services
    end_def

    def_irq frame_services, model
            jsr check_keyboard
            jsr keyboard_debug

            jsr check_ui_keys
            jsr set_ui_action

            inc frame_counter
            bne :+
            inc frame_counter + 1
:
            jsr update_timers
            setup_next model, 128, timer_update_3
    end_def

    def_irq timer_update_3, model
            jsr update_timers
            setup_next model, 177, screen_bottom
    end_def

    def_irq screen_bottom, model
            stabilize model
            lda #chrome_bgcolor
            sta $d021
            sta $d020
            ldx #32
:           dex
            bne :-
            switch_vic_mem host_screen, chrome_charset

            setup_next model, 250, timer_update_4
    end_def

    def_irq timer_update_4, model
            jsr update_timers
            setup_next model, 0, host_screen_top
    end_def

.endmacro

.proc new_setup_irq
			sei
			ldy #0
			sty frame_counter
			sty frame_counter + 1
			lda #<host_screen_top_pal_63
			ldx #>host_screen_top_pal_63
			sta IRQ_VECTOR
			stx IRQ_VECTOR + 1
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

.proc new_exit_irq
            lda #1
            sta $d019
            pla
            tay
            pla
            tax
            pla
            rti
.endproc