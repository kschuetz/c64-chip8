.include "common.s"
	
.import chip8_screen_charset
.importzp zp0, zp1
.import fill

	.export build_chip8_screen_charset


	

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
	
.proc build_chip8_screen_charset
	istore zp0, (chip8_screen_charset + 16 * 8)
	ldy #$7f
	ldx #$07
	lda #0
	jsr fill

	ldy #0
	ldx #0
@loop:	lda row_bits, x
	.repeat 4
		sta chip8_screen_charset, y
		iny
	.endrep
	inx
	cpx #32
	bne @loop
	
	rts
.endproc
