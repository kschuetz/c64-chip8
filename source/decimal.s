.include "common.s"

.export build_decimal_table
.export decimal_table_high
.export decimal_table_low

.importzp zp0
.importzp zp1

.segment "INITCODE"

.proc build_decimal_table
			ldx #0
			sed
			lda #0
			sta zp0
			sta zp1
			
@loop:		clc
			lda zp0
			sta decimal_table_low, x
			adc #1
			sta zp0
			lda zp1
			sta decimal_table_high, x
			adc #0
			sta zp1
			inx
			bne @loop
			cld
			rts
.endproc

.segment "LOW"

decimal_table_low:		.res 256
decimal_table_high:		.res 256
