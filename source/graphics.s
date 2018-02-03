.export clear_screen

.import chip8_screen_origin

.include "defines.s"

.proc clear_screen
		lda #6
		ldy #chip8_screen_physical_width
@loop:	.repeat chip8_screen_physical_height, i
			sta chip8_screen_origin + 40 * i, y
		.endrepeat
		dey
		bpl @loop
		rts
.endproc
