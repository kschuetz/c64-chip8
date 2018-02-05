.export build_chrome, keyboard_debug
.import chrome_origin, chrome_color_origin, is_chip8_key_pressed, physical_screen
.importzp zp0, zp1, irq_zp0

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

@kbd_origin = chrome_origin + 45
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
			sta physical_screen + keyboard_debug_origin, y
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
			jsr is_chip8_key_pressed
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