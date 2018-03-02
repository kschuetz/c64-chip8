.include "common.s"

.export active_pixel_style
.export cycle_pixel_style
.export init_charsets
.export load_font_set
.export load_pixel_style
.exportzp pixel_style_count
.exportzp pixel_style_representative

.import chrome_charset
.import fill
.import guest_ram
.import move_up
.import screen_charset
.importzp zp0
.importzp zp2
.importzp zp4

pixel_style_count = 8

pixel_style_representative = 112

.segment "LOW"

active_pixel_style:
            .res 1

.segment "INITCODE"

.proc init_charsets
			jsr init_chrome_charset
			jmp init_screen_charset
.endproc

.proc init_chrome_charset
			istore zp0, chrome_charset_data
			istore zp2, chrome_charset
			istore zp4, $0800
			jsr move_up

            ; copy pixel style representatives
            ; (chrome_charset characters 112..127)
            ldy #7
@loop:
            .repeat 8, i
                lda pixel_style_data + 128 * i + 72, y
                sta chrome_charset + (pixel_style_representative + i) * 8, y
            .endrepeat
            dey
            bpl @loop
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

            ldy #default_pixel_style_index
            jmp load_pixel_style
.endproc

.code

.proc cycle_pixel_style
             ldy active_pixel_style
             iny
             cpy #pixel_style_count
             bcc @ok
             ldy #0
@ok:         ; continue to load_pixel_style
.endproc

; Y - index of pixel set (0..15)
.proc load_pixel_style
            sty active_pixel_style
            lda pixel_style_address_low, y
            sta @source + 1
            lda pixel_style_address_high, y
            sta @source + 2
            ldy #127
@loop:
@source:    lda $ffff, y
            sta screen_charset, y
            dey
            bpl @loop
            rts
.endproc

.proc load_font_set
			ldy #79
@loop:		lda font_set, y
			sta guest_ram, y
			dey
			bpl @loop
			rts
.endproc

.rodata

pixel_style_address_low:
            .repeat 16, i
                .byte <(pixel_style_data + 128 * i)
            .endrepeat

pixel_style_address_high:
            .repeat 16, i
                .byte >(pixel_style_data + 128 * i)
            .endrepeat

times_8:
            .repeat 8, i
                .byte i * 8
            .endrepeat

pixel_style_data:
            .incbin "data/pixel-styles.bin", 0, pixel_style_count * 128

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

.segment "INITDATA"

chrome_charset_data:
			.incbin "data/chrome-charset.bin"
