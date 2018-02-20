.export reset
.import clear_ram, clear_registers, load_font_set, clear_screen, load_bundled_rom, active_bundle, display_rom_title
.import test_draw
.import init_debug
.import default_keymap
.importzp paused, active_keymap

.include "common.s"

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

			; TODO: load ROM specific keymap
			istore active_keymap, default_keymap

			jsr init_debug
			jsr clear_registers
			rts
.endproc