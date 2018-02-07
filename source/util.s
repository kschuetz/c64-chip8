.importzp zp0, zp1, zp2, zp3, zp4, zp5

.export move_up, fill

; arg_move_from = source start address
; arg_move_to = destination start address
; arg_move_size = number of bytes to move


.code
	
	;;  Move memory up
				
.proc move_up

move_from = zp0
move_to = zp2
move_size = zp4

		    ldx move_size+1     ; the last byte must be moved first
			clc                 ; start at the final pages of FROM and TO
		    txa
		    adc move_from+1
		    sta move_from+1
		    clc
		    txa
		    adc move_to+1
		    sta move_to+1
		    inx                 ; allows the use of BNE after the DEX below
		    ldy move_size
		    beq @3
		    dey                 ; move bytes on the last page first
		    beq @2
@1: 	    lda (move_from), y
		    sta (move_to), y
		    dey
		    bne @1
@2:		    lda (move_from), y  ; handle Y = 0 separately
		    sta (move_to), y
@3:			dey
		    dec move_from + 1   ; move the next page (if any)
		    dec move_to + 1
		    dex
		    bne @1
		    rts
.endproc

	;; length must be > 0
	;; zp0:zp1 = dest address
	;; x = (length - 1) high
	;; y = (length - 1) low
	;; a = fill value
	
.proc fill
			cpx #0
			beq @last_page
			sty zp2
			ldy #0
@1:			sta (zp0), y
			iny
			bne @1
			inc zp1 
			dex
			bne @1
@2:			ldy zp2
@last_page:
			sta (zp0), y
			dey
			cpy #$ff
			bne @last_page
			rts
.endproc
