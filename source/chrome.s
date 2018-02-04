.export build_chrome
.import chrome_origin, chrome_color_origin
.importzp zp0, zp1

.include "common.s"

.proc build_chrome
			; set color ram
			lda #1
			ldx #180
@1:			sta chrome_color_origin - 1, x
			sta chrome_color_origin + 179, x
			dex
			bne @1
			
			jsr draw_keyboard_pic
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

@kbd_origin = chrome_origin + 45
			ldx #0
			istore zp0, @kbd_origin
@1:			ldy #0
@2:			lda keyboard_pic, x
			sta (zp0), y
			inx
			iny
			cpy #6
			bne @2
			clc
			lda zp0
			adc #40
			sta zp0
			lda zp1
			adc #0
			sta zp1
			cpx #36
			bne @1					
					
			rts
.endproc

.rodata
keyboard_pic:	
			.byte 64, 65, 66, 67, 68, 69
			.byte 96, 97, 98, 99, 100, 101
			.byte 70, 71, 72, 73, 74, 75
			.byte 102, 103, 104, 105, 106, 107
			.byte 76, 77, 78, 79, 80, 81
			.byte 108, 109, 110, 111, 112, 113