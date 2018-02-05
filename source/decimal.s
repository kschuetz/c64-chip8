.export decimal_table_high, decimal_table_low, build_decimal_table
.importzp zp0, zp1

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

.bss
decimal_table_low:		.res 256
decimal_table_high:		.res 256

