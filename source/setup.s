.export initialize

.import clear_screen, physical_screen, chip8_screen_charset

.include "common.s"

.proc initialize
		lda C2DDRA	;change VIC to bank 2
		ora #3
		sta C2DDRA
		lda CI2PRA
		and #$fc
		ora #1
		sta CI2PRA	
		
@screen = (physical_screen - $8000) >> 10	
@charset = ((chip8_screen_charset - $8000) >> 10)
		
		lda #<((@screen << 4) | (@charset & 14))
		sta VMCSB

		jsr clear_screen
		rts
.endproc