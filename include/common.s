.include "c64.inc"
.include "defines.s"

.macro istore m, value
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
	    and #63
	    ora #guest_ram_page
.endmacro

.struct BundleNode
	    next .addr
	    title .byte title_length
	    data .byte
.endstruct

.enum UIAction
		none
		reset
		load_next
		load_prev
		pause
		bgcolor_prev
		bgcolor_next
		fgcolor_prev
		fgcolor_next
.endenum
