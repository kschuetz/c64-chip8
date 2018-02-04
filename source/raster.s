.export setup_irq
.import physical_screen, screen_charset, chrome_charset
.importzp screen_bgcolor

.include "common.s"

irq_vector = $fffe


.zeropage
raster_index: .res 1


.rodata

next_raster_index:
			.byte 1, 2, 0
next_raster_line:
			.byte 50, 178, 0
			
irq_service:
			.byte 0, 1, 2
			
.code


.proc setup_irq
			sei
			ldy #0
			sty raster_index
			lda #<irq1
			ldx #>irq1
			sta irq_vector
			stx irq_vector + 1
			lda $d011
			and #$7f
			sta $d011
			lda #0
			sta $d012
			lda #1
			sta $d01a
			lda #$7f
			sta $dc0d
			cli
			rts
.endproc

.proc irq1
			pha
			txa
			pha
			tya
			pha

			asl $d019
			cli
			cld
			
			ldx raster_index
			lda next_raster_line, x
			sta $d012

			ldy next_raster_index, x
			sty raster_index
			
			lda irq_service, x
			
			beq top_irq
			cmp #1
			beq screen_top_irq
			jmp screen_end_irq	
.endproc

.proc top_irq
			lda #chrome_bgcolor
			sta $d020
			lda screen_bgcolor
			sta $d021
			jmp exit_irq
.endproc

.proc screen_top_irq
			switch_vic_mem physical_screen, screen_charset
			jmp exit_irq
.endproc

.proc screen_end_irq
			lda #chrome_bgcolor
			sta $d020
			sta $d021
			switch_vic_mem physical_screen, chrome_charset
.endproc

.proc exit_irq
			pla
			tay
			pla
			tax
			pla
			rti
.endproc