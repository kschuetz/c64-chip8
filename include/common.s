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
		sta VMCSB
.endmacro 

.struct BundleNode
	next .addr
	title .byte title_length
	data .byte
.endstruct