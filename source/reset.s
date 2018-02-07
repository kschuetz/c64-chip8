.export reset
.import clear_ram, clear_registers, load_font_set, clear_screen, load_bundled_rom, active_bundle, display_rom_title
.import test_draw

; A - bundle to load
.proc reset
			pha
			jsr clear_ram
			jsr load_font_set
			jsr clear_screen
			jsr test_draw				; temp
			
			pla
			tay
			jsr load_bundled_rom
			lda active_bundle
			jsr display_rom_title	
			
			jsr clear_registers
			rts
.endproc