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

            lda #$35
            sta $1

            ; after we have switched out basic and kernal, it is safe to run code in INITCODE segment
            jsr initialize_phase_2

            lda $d011               ; enable screen
            ora #%00010000
            sta $d011
            rts
.endproc

; TODO: nmi
.proc nmi
			asl $d019   ;Ack all IRQs
			lda $dc0d
			lda $dd0d
			lda #$81    ;reset CIA 1 IRQ
			ldx #$00    ;remove raster IRQ
			ldy #$37    ;reset MMU to roms
			sta $dc0d
			stx $d01a
			sty $01
			ldx #$ff    ;clear the stack
			txs
			cli         ;reenable IRQs
			jmp start   ;reset!
.endproc

.segment "INITCODE"

.proc init_vic
			lda $dd02	;change VIC to bank 3
			ora #3
			sta $dd02
			lda $dd00
			and #$fc
			;ora #1
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
            lda #$1f    ;Disable CIA IRQ's
            sta $dc0d
            sta $dd0d

            lda #<nmi   ;Install NMI into
            ldx #>nmi   ;Hardware NMI and
            sta $fffa   ;RESET Vectors
            sta $fffc
            stx $fffb
            stx $fffd

            jsr init_random
            jsr init_timers
			jsr init_graphics_tables
			jsr build_decimal_table
			jsr build_bundle_index
			jsr init_core
			jsr init_keyboard

			jsr init_charsets
			jsr init_vars
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

.proc init_vars
			lda #default_screen_bgcolor	
			sta screen_bgcolor
			lda #default_screen_fgcolor
			sta screen_fgcolor
			rts
.endproc
