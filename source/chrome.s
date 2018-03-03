.include "common.s"

.export build_chrome
.export display_rom_title
.export sync_bgcolor_indicator
.export sync_fgcolor_indicator
.export sync_key_delay_indicator
.export sync_paused_indicator
.export sync_pixel_style_indicator
.export sync_sound_indicator

.import active_pixel_style
.import bundle_count
.import bundle_count_decimal
.import bundle_index_high
.import bundle_index_low
.import chrome_color_origin
.import chrome_origin
.import decimal_table_high
.import decimal_table_low
.import host_screen
.import is_guest_key_pressed
.importzp irq_zp0
.importzp key_delay_mode
.importzp paused
.importzp pixel_style_representative
.importzp screen_bgcolor
.importzp screen_fgcolor
.importzp sound_enabled
.importzp zp0
.importzp zp1
.importzp zp2
.importzp zp3
.importzp zp4
.importzp zp5
.importzp zp6

chrome_text_column_1 = guest_screen_offset_x + 7
chrome_text_origin = 120 + chrome_text_column_1
chrome_text_screen_origin := chrome_origin + chrome_text_origin
chrome_text_color_origin := chrome_color_origin + chrome_text_origin

.segment "INITCODE"

.proc build_chrome
            ldx #180
			ldy #chrome_text_color				; color ram
@1:			lda #0								; screen ram
			sta chrome_origin - 1, x
			sta chrome_origin + 179, x
			tya				
			sta chrome_color_origin - 1, x
			sta chrome_color_origin + 179, x
			dex
			bne @1

			lda #chrome_bgcolor
			ldx #79
:           sta chrome_color_origin, x
            dex
            bpl :-

            ldy #27
@2:         lda chrome_line_1, y
            sta chrome_text_screen_origin, y
            lda chrome_line_2, y
            sta chrome_text_screen_origin + 40, y
			lda chrome_line_3, y
            sta chrome_text_screen_origin + 80, y
            lda chrome_line_4, y
            sta chrome_text_screen_origin + 120, y
            lda chrome_line_5, y
            sta chrome_text_screen_origin + 160, y
            dey
            bpl @2

            lda #chrome_ui_key_color
            .repeat 4, i
                sta chrome_text_color_origin + 40 * i
                sta chrome_text_color_origin + 40 * i + 1
            .endrepeat

            .repeat 5, i
                sta chrome_text_color_origin + 40 * i + 12
                sta chrome_text_color_origin + 40 * i + 13
            .endrepeat

            lda #pixel_style_indicator_color
            sta pixel_style_indicator_color_addr
            sta pixel_style_indicator_color_addr + 1

            jsr sync_pixel_style_indicator
            jsr sync_bgcolor_indicator
            jsr sync_fgcolor_indicator
            jsr sync_key_delay_indicator
            jsr sync_sound_indicator
            jsr sync_paused_indicator
			rts
.endproc

.code

;; zp0:zp1 - top row
;; zp2:zp3 - bottom row
;; Y - offset
;; A - char
.macro output_big_char
			sta (zp0), y
			ora #128
			sta (zp2), y
.endmacro

rom_title_origin = chrome_origin + guest_screen_offset_x + 7

;; A - rom index
.proc display_rom_title
			tax			; save rom index
			tay

			store16 zp0, rom_title_origin
			store16 zp2,(rom_title_origin + 40)
			clc
			lda bundle_index_low, y
			adc #<BundleNode::title
			sta zp4
			lda bundle_index_high, y
			adc #>BundleNode::title
			sta zp5
			
			ldy #0
			inx
			jsr output_big_decimal			; show rom index + 1
			
			lda #47							; slash
			output_big_char
			iny
			
			ldx bundle_count
			jsr output_big_decimal 
			
			lda #58							; colon
			output_big_char
			iny
			lda #32							; space	
			output_big_char
			iny
			
		    ;; zp0:zp1 += y
			clc
			tya
			adc zp0
			sta zp0
			lda #0
			adc zp1
			sta zp1
			
			clc
			tya
			adc zp2
			sta zp2
			lda #0
			adc zp3
			sta zp3

			ldy #0
@title_loop:
			lda (zp4), y
			output_big_char
			iny
			cpy #title_length
			bne @title_loop
			rts
.endproc

;; X - value
;; Y - next char position; return value contains new next char position
.proc output_big_decimal
			sty zp6
			lda decimal_table_high, x
			and #15
			beq @tens
			tay
			lda decimal_digit_chars, y
			ldy zp6
			output_big_char
			iny
			sty zp6
			
@tens:		lda decimal_table_low, x
			lsr a
			lsr a
			lsr a
			lsr a
			beq @ones
			tay
			lda decimal_digit_chars, y
			ldy zp6
			output_big_char	
			iny
			sty zp6
@ones:		lda decimal_table_low, x
			and #15
			tay
			lda decimal_digit_chars, y	
			ldy zp6
			output_big_char	
			iny
			rts
.endproc

key_delay_indicator_color_addr := chrome_text_color_origin + 26
pixel_style_indicator_color_addr := key_delay_indicator_color_addr + 40
bgcolor_indicator_color_addr := pixel_style_indicator_color_addr + 40
fgcolor_indicator_color_addr := bgcolor_indicator_color_addr + 40
sound_indicator_color_addr := fgcolor_indicator_color_addr + 40
paused_indicator_color_addr := chrome_text_color_origin + 163

key_delay_indicator_addr := chrome_text_screen_origin + 26
pixel_style_indicator_addr := key_delay_indicator_addr + 40
sound_indicator_addr := pixel_style_indicator_addr + 120

.proc sync_pixel_style_indicator
            lda active_pixel_style
            clc
            adc #pixel_style_representative
            sta pixel_style_indicator_addr
            sta pixel_style_indicator_addr + 1
            rts
.endproc

.proc sync_bgcolor_indicator
            lda screen_bgcolor
            sta bgcolor_indicator_color_addr
            sta bgcolor_indicator_color_addr + 1
            rts
.endproc

.proc sync_fgcolor_indicator
            lda screen_fgcolor
            sta fgcolor_indicator_color_addr
            sta fgcolor_indicator_color_addr + 1
            rts
.endproc

.proc sync_paused_indicator
            lda paused
            beq @off
            lda #paused_indicator_color
            .byte $2c   ; BIT instruction
@off:       lda #chrome_bgcolor
            ldy #6
@loop:      sta paused_indicator_color_addr, y
            dey
            bpl @loop
            rts
.endproc

.macro sync_on_off_indicator source, screen_mem, color_mem
            lda source
            beq @off1
            ldx #77
            .byte $2c   ; BIT instruction
@off1:      ldx #79
            stx screen_mem
            inx
            stx screen_mem + 1

            lda source
            beq @off2
            lda #indicator_on_color
            .byte $2c   ; BIT instruction
@off2:      lda #indicator_off_color
            sta color_mem
            sta color_mem + 1
            rts
.endmacro

.proc sync_key_delay_indicator
            sync_on_off_indicator key_delay_mode, key_delay_indicator_addr, key_delay_indicator_color_addr
.endproc

.proc sync_sound_indicator
            sync_on_off_indicator sound_enabled, sound_indicator_addr, sound_indicator_color_addr
.endproc

.rodata

decimal_digit_chars:
			.byte 48, 49, 50, 51, 52, 53, 54, 55, 56, 57

.segment "INITDATA"

chrome_line_1:
            .byte 65, 66, 0, 210, 197, 211, 197, 212, 0, 0, 0, 0
            .byte 70, 71, 203, 197, 217, 0, 196, 197, 204, 193, 217, 0, 0, 0, 0, 0
chrome_line_2:
            .byte 65, 67, 0, 208, 210, 197, 214, 0, 210, 207, 205, 0
            .byte 72, 71, 208, 201, 216, 197, 204, 0, 211, 212, 217, 204, 197, 0, 0, 0
chrome_line_3:
            .byte 65, 68, 0, 206, 197, 216, 212, 0, 210, 207, 205, 0
            .byte 73, 71, 194, 199, 0, 195, 207, 204, 207, 210, 0, 0, 0, 0, 76, 76
chrome_line_4:
            .byte 65, 69, 0, 208, 193, 213, 211, 197, 0, 0, 0, 0
            .byte 74, 71, 198, 199, 0, 195, 207, 204, 207, 210, 0, 0, 0, 0, 76, 76
chrome_line_5:
            .byte 0, 0, 0, 81, 82, 83, 84, 85, 86, 87, 0, 0
            .byte 75, 71, 211, 207, 213, 206, 196, 0, 0, 0, 0, 0, 0, 0, 0, 0
