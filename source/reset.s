.include "common.s"

.export reset

.import active_bundle
.import clear_ram
.import clear_registers
.import clear_screen
.import default_keymap
.import display_rom_title
.import init_debug
.import load_bundled_rom
.import load_font_set
.import sync_key_delay_indicator
.import test_draw
.importzp active_keymap
.importzp paused

; A - bundle to load
.proc reset
			pha
			jsr clear_ram
			jsr load_font_set
			jsr clear_screen
			lda #0
			sta paused

			pla
			tay
			jsr load_bundled_rom
			lda active_bundle
			jsr display_rom_title
			jsr sync_key_delay_indicator

			jsr init_debug
			jsr clear_registers
			rts
.endproc
