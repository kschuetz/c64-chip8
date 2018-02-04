.include "common.s"
	
.import screen_charset, chrome_charset
.importzp zp0, zp2, zp4
.import fill, move_up

.export init_charsets


.rodata
chrome_charset_data:	
			.incbin "data/chrome-charset.bin"
	

.rodata

	oo = %00000000
	ox = %00001111
	xo = %11110000
	xx = %11111111

row_bits:
	.byte oo, oo
	.byte oo, ox
	.byte oo, xo
	.byte oo, xx
	.byte ox, oo
	.byte ox, ox
	.byte ox, xo
	.byte ox, xx
	.byte xo, oo
	.byte xo, ox
	.byte xo, xo
	.byte xo, xx
	.byte xx, oo
	.byte xx, ox
	.byte xx, xo
	.byte xx, xx

.code

.proc init_charsets
	jsr init_chrome_charset
	jmp build_screen_charset
.endproc

.proc init_chrome_charset
	istore zp0, chrome_charset_data
	istore zp2, chrome_charset
	istore zp4, $0800
	jmp move_up
.endproc	
		
.proc build_screen_charset
	istore zp0, (screen_charset + 16 * 8)
	ldy #$7f
	ldx #$07
	lda #0
	jsr fill

	ldy #0
	ldx #0
@loop:	lda row_bits, x
	.repeat 4
		sta screen_charset, y
		iny
	.endrep
	inx
	cpx #32
	bne @loop
	
	rts
.endproc

