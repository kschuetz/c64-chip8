.include "common.s"
	
.import screen_charset, chrome_charset, guest_ram
.importzp zp0, zp2, zp4
.import fill, move_up

.export init_charsets, load_font_set, load_pixel_set

.code

.proc init_charsets
			jsr init_chrome_charset
			jmp init_screen_charset
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
@loop:		lda row_bits, x
			.repeat 4
				sta screen_charset, y
				iny
			.endrep
			inx
			cpx #32
			bne @loop
			
			rts
.endproc

.proc init_screen_charset
            istore zp0, screen_charset
            ldy #$7f
            ldx #$07
            lda #0
            jsr fill

            ; character 16 solid
            lda #255
            ldy #7
@loop:      sta screen_charset + 16 * 8, y
            dey
            bpl @loop

            ldy #4
            jmp load_pixel_set
.endproc

; Y - index of pixel set (0..15)
.macro load_pixel_set_impl
            lda pixel_set_address_low, y
            sta @source + 1
            lda pixel_set_address_high, y
            sta @source + 2
            ldy #127
@loop:
@source:    lda $ffff, y
            sta screen_charset, y
            dey
            bpl @loop
.endmacro

.proc load_pixel_set
            load_pixel_set_impl
.endproc

;; Y - pixel_set index (0..15)
;; X - character index (0..15)
;.proc load_partial_pixel_set
;            clc
;            lda times_8, x
;            adc pixel_set_address_low, y
;            sta @source + 1
;            lda pixel_set_address_high, y
;            adc #0
;            sta @source + 2
;            ldy #8
;@loop:
;@source:    lda $ffff, y
;            sta screen_charset, y
;            dey
;            bpl @loop
;.endproc

.proc load_font_set
			ldy #79
@loop:		lda font_set, y
			sta guest_ram, y
			dey
			bpl @loop
.endproc

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

pixel_set_address_low:
            .repeat 16, i
                .byte <(pixel_set_data + 128 * i)
            .endrepeat

pixel_set_address_high:
            .repeat 16, i
                .byte >(pixel_set_data + 128 * i)
            .endrepeat

times_8:
            .repeat 8, i
                .byte i * 8
            .endrepeat

chrome_charset_data:
			.incbin "data/chrome-charset.bin"
pixel_set_data:
            .incbin "data/pixel-sets.bin"


font_set:
            .byte $f0, $90, $90, $90, $f0 ; 0
            .byte $20, $60, $20, $20, $70 ; 1
            .byte $f0, $10, $f0, $80, $f0 ; 2
            .byte $f0, $10, $f0, $10, $f0 ; 3
            .byte $90, $90, $f0, $10, $10 ; 4
            .byte $f0, $80, $f0, $10, $f0 ; 5
            .byte $f0, $80, $f0, $90, $f0 ; 6
            .byte $f0, $10, $20, $40, $40 ; 7
            .byte $f0, $90, $f0, $90, $f0 ; 8
            .byte $f0, $90, $f0, $10, $f0 ; 9
            .byte $f0, $90, $f0, $90, $90 ; a
            .byte $e0, $90, $e0, $90, $e0 ; b
            .byte $f0, $80, $80, $80, $f0 ; c
            .byte $e0, $90, $90, $90, $e0 ; d
            .byte $f0, $80, $f0, $80, $f0 ; e
            .byte $f0, $80, $f0, $80, $80 ; f
