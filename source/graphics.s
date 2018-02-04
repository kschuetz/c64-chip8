.export clear_screen, build_screen_margins, update_screen_color

.import chip8_screen_origin, chip8_screen_color_origin, physical_screen
.exportzp screen_bgcolor, screen_fgcolor

.importzp zp0, zp1, zp2

.include "common.s"

.zeropage
screen_bgcolor: .res 1
screen_fgcolor: .res 1

.code

.proc clear_screen
			lda #6
			ldy #chip8_screen_physical_width - 1
@loop:		.repeat chip8_screen_physical_height, i
				sta chip8_screen_origin + 40 * i, y
			.endrepeat
			dey
			bpl @loop
			rts
.endproc

.proc update_screen_color
			ldy #chip8_screen_physical_width - 1
@loop:		.repeat chip8_screen_physical_height, i
				sta chip8_screen_color_origin + 40 * i, y
			.endrepeat
			dey
			bpl @loop
			rts						
.endproc


.proc build_screen_margins
				; set character of margins to 15
			istore zp0, (physical_screen + 40 * chip8_screen_offset_y)		
			lda #15
			sta zp2
			jsr @go
				; set color ram of margins to 0
			istore zp0, (COLORRAM + 40 * chip8_screen_offset_y)
			lda #0
			sta zp2
@go:		ldx #chip8_screen_physical_height
@loop:		lda zp2
			ldy #chip8_screen_offset_x
@1:			sta (zp0), y
			dey
			bpl @1
			ldy #39
@2:			sta (zp0), y
			dey
			cpy #(chip8_screen_physical_width + chip8_screen_offset_x)
			bpl @2
			clc
			lda #40
			adc zp0
			sta zp0
			lda #0
			adc zp1
			sta zp1
			dex
			bne @loop
			rts
.endproc