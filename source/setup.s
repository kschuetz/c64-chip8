.export initialize

.import clear_screen, host_screen, screen_charset, chrome_charset, start, build_screen_margins
.import build_bundle_index, clear_ram, load_bundled_rom, init_charsets
.import init_keyboard, init_core, init_graphics_tables, init_timers, init_random
.import update_screen_color
.import build_chrome
.import reset
.import build_decimal_table
.import check_host_model
.import init_buttons, init_button_sprites
.importzp screen_bgcolor, screen_fgcolor

.include "common.s"

.proc init_vic
			lda $dd02	;change VIC to bank 2
			ora #3
			sta $dd02
			lda $dd00
			and #$fc
			ora #1
			sta $dd00
			
			switch_vic_mem host_screen, chrome_charset

			lda $d011
			and #%10010000
			ora #%00001011
			sta $d011

			; lda #0
			; sta $d015           ; disable all sprites

			jmp init_button_sprites
.endproc

.proc initialize
            cld
            jsr check_host_model

            lda #chrome_bgcolor
            sta $d020

            lda $d011               ; blank screen during initialization
            and #%11101111
            sta $d011
            
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
			
			lda screen_fgcolor
			jsr update_screen_color
			jsr clear_screen
			jsr build_screen_margins
			jsr build_chrome

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
			
			lda #$35
			sta $1
			
			lda #default_rom_index	
			jsr reset


            lda $d011               ; enable screen
            ora #%00010000
            sta $d011
			
			rts
.endproc

.proc init_vars
			lda #default_screen_bgcolor	
			sta screen_bgcolor
			lda #default_screen_fgcolor
			sta screen_fgcolor
			rts
.endproc

.proc nmi
			asl $d019   ;Ack all IRQ's
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
			cli         ;reenable IRQ's
			jmp start    ;reset!
.endproc
