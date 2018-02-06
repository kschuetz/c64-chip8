.export reset
.import clear_ram, load_font_set, clear_screen, load_bundled_rom, active_bundle, display_rom_title

; A - bundle to load
.proc reset
			pha
			jsr clear_ram
			jsr load_font_set
			jsr clear_screen
			pla
			tay
			jsr load_bundled_rom
			lda active_bundle
			jsr display_rom_title	
			
			;; TODO - reset CPU and registers
			rts
.endproc