.include "common.s"

.export active_bundle
.export build_bundle_index
.export bundle_count
.export bundle_index_high
.export bundle_index_low
.export load_bundled_rom

.import bundle_start
.import decimal_table_high
.import decimal_table_low
.import move_up
.import program_start
.import set_button_colors
.importzp active_keymap
.importzp zp0
.importzp zp1
.importzp zp2
.importzp zp3
.importzp zp4
.importzp zp5

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
			jsr move_up

			; enabled_keys
			ldy active_bundle
			clc
            lda bundle_index_low, y
            adc #<BundleNode::enabled_keys
            sta zp2
            lda bundle_index_high, y
            adc #>BundleNode::enabled_keys
            sta zp3
            ldy #0
            lda (zp2), y
            sta zp0
            iny
            lda (zp2), y
            sta zp1
            jsr set_button_colors

            ldy #2
            lda (zp2), y
            sta active_keymap
            iny
            lda (zp2), y
            sta active_keymap + 1
			rts
.endproc
