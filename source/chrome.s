.export build_chrome, keyboard_debug, display_rom_title, debug_output_hex
.import chrome_origin, chrome_color_origin, is_guest_key_pressed, host_screen
.import bundle_count, bundle_index_low, bundle_index_high, bundle_count_decimal
.import decimal_table_high, decimal_table_low
.importzp zp0, zp1, zp2, zp3, zp4, zp5, zp6
.importzp irq_zp0


.include "common.s"

.proc build_chrome
			ldy #1								; color ram
@1:			lda #0								; screen ram
			sta chrome_origin - 1, x
			sta chrome_origin + 179, x
			tya				
			sta chrome_color_origin - 1, x
			sta chrome_color_origin + 179, x
			dex
			bne @1
			
			jsr draw_keyboard_pic
			jsr init_keyboard_debug
			rts
			
			; test - remove soon
			ldy #0
			ldx #0
@2:			tya
			sta chrome_origin, x
			ora #128
			sta chrome_origin + 40, x
			iny
			inx
			cpx #40
			bne @2
			

.endproc

.proc draw_keyboard_pic

@kbd_origin = chrome_origin + 80 + guest_screen_offset_x
			ldx #0
			istore zp0, @kbd_origin
@1:			ldy #0
@2:			lda keyboard_pic, x
			sta (zp0), y
			inx
			iny
			cpy #5
			bne @2
			clc
			lda zp0
			adc #40
			sta zp0
			lda zp1
			adc #0
			sta zp1
			cpx #30
			bne @1					
					
			rts
.endproc


keyboard_debug_origin = 984   ; last 16 characters of last row

.proc init_keyboard_debug
			ldy #15
@loop:		lda keyboard_debug_chars, y
			sta host_screen + keyboard_debug_origin, y
			lda #2
			sta COLOR_RAM + keyboard_debug_origin, y
			dey
			bpl @loop				
			rts
.endproc

; must be called from irq
.proc keyboard_debug
			ldy #15
@loop:		sty irq_zp0
			tya
			jsr is_guest_key_pressed
			beq @no
			lda #1
			bne @1
@no:		lda #2
@1:			ldy irq_zp0
			sta COLOR_RAM + keyboard_debug_origin, y
			dey
			bpl @loop		
			rts				
.endproc

; zp0:zp1 - top row 
; zp2:zp3 - bottom row
; y - offset
; a - char
.macro output_big_char
			sta (zp0), y
			ora #128
			sta (zp2), y
.endmacro

rom_title_origin = chrome_origin + guest_screen_offset_x + 6

; A - bundle index
.proc display_rom_title
			tax			; save bundle_index
			tay

			istore zp0, rom_title_origin
			istore zp2,(rom_title_origin + 40)
			clc
			lda bundle_index_low, y
			adc #<BundleNode::title
			sta zp4
			lda bundle_index_high, y
			adc #>BundleNode::title
			sta zp5
			
			ldy #0
			inx
			jsr output_big_decimal			; bundle number
			
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
			
					; zp0:zp1 += y
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

; x - value
; y - next char position; return value contains new next char position
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

debug_hex_origin = 958
.proc debug_output_hex
			tax
			lsr a
			lsr a
			lsr a
			lsr a
			tay
			lda keyboard_debug_chars, y
			sta host_screen + debug_hex_origin
			txa
			and #$0f
			tay
			lda keyboard_debug_chars, y
			sta host_screen + debug_hex_origin + 1
			rts
.endproc

.rodata
keyboard_pic:	
			.byte 64, 65, 66, 67, 68
			.byte 96, 97, 98, 99, 100
			.byte 69, 70, 71, 72, 73
			.byte 101, 102, 103, 104, 105
			.byte 74, 75, 76, 77, 78
			.byte 106, 107, 108, 109, 110
			
keyboard_debug_chars:
			.byte 240, 241, 242, 243, 244, 245, 246, 247, 248, 249
			.byte 193, 194, 195, 196, 197, 198
			
decimal_digit_chars:
			.byte 48, 49, 50, 51, 52, 53, 54, 55, 56, 57		