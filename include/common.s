.include "defines.s"

.define true $ff
.define false $00

.macro store16 m, value
		lda #<value
		sta m
		lda #>value
		sta m + 1
.endmacro

.macro switch_vic_mem screen, charset
		.local @screen
		.local @charset
		@screen = (screen - vic_bank_base) >> 10	
		@charset = ((charset - vic_bank_base) >> 10)
		
		lda #<((@screen << 4) | (@charset & 14))
		sta $d018
.endmacro 

;; converts high byte of logical RAM (in A) to physical RAM location
.macro map_to_host
	    and #15
	    ora #guest_ram_page
.endmacro

.struct BundleNode
	    next .addr
	    title .byte title_length
	    enabled_keys .word
	    keymap .addr
	    key_repeat_default .byte
	    data .byte
.endstruct

.enum UIAction
		none = 0
		reset = 1
		load_prev = 2
		load_next = 3
		pause = 4
		bgcolor_next = 5
		fgcolor_next = 6
		pixel_style_next = 7
		toggle_key_repeat = 8
		toggle_sound = 9
.endenum
