.export bundle_count, bundle_index_low, bundle_index_high, build_bundle_index

.import bundle_start
.importzp zp0, zp1, zp2, zp3

.include "defines.s"
.include "common.s"

.bss

bundle_count: 		.res 1
bundle_index_low: 	.res max_bundled_roms				; points to title
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
			bne @not_null
		
			rts 				; next = null; exit
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
			
			rts				
.endproc