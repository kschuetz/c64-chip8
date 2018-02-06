.export bundle_count, bundle_index_low, bundle_index_high, build_bundle_index, load_bundled_rom
.export active_bundle

.import bundle_start, program_start, move_up
.import decimal_table_low, decimal_table_high
.importzp zp0, zp1, zp2, zp3, zp4, zp5

.include "common.s"

.bss

bundle_count: 		.res 1
active_bundle:		.res 1
bundle_index_low: 	.res max_bundled_roms				
bundle_index_high: 	.res max_bundled_roms


.code

.proc build_bundle_index
			lda #0
			sta bundle_count
			lda #<bundle_start
			sta zp0
			sta bundle_index_low
			lda #>bundle_start
			sta zp1
			sta bundle_index_high

@loop:		
			ldy #0
			lda (zp0), y
			tax					; x = next low
			iny
			lda (zp0), y		; a = next high
			bne @not_null
			cpx #0
			beq @done			; next = null; exit
			
@not_null:
			ldy bundle_count
			iny
			sty bundle_count
			sta bundle_index_high, y
			sta zp1
			txa
			sta bundle_index_low, y
			sta zp0
			cpy #max_bundled_roms
			bmi @loop	

@done:				
			rts				
.endproc


; y - index of bundle to load
.proc load_bundled_rom
			sty active_bundle
			clc
			lda bundle_index_low, y
			sta zp2
			adc #<BundleNode::data
			sta zp0
			lda bundle_index_high, y
			sta zp3
			adc #>BundleNode::data
			sta zp1
									; zp2:zp3 contains pointer to BundleNode
									; zp0:zp1 contains pointer to start of rom data
									; now we need the size
			ldy #0
			sec
			lda (zp2), y
			sbc zp0
			sta zp4
			iny
			lda (zp2), y
			sbc zp1
			sta zp5
									; zp4:zp5 contains size
			istore zp2, program_start						
			jmp move_up							 
.endproc