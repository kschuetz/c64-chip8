.importzp zp0, zp1, zp2, zp3, zp4, zp5
.exportzp arg_move_from, arg_move_to, arg_move_size

.export move_up, fill

; arg_move_from = source start address
; arg_move_to = destination start address
; arg_move_size = number of bytes to move

arg_move_from = zp0
arg_move_to = zp2
arg_move_size = zp4

.code
	
	;;  Move memory up
				
.proc move_up
		    ldx arg_move_size+1    ; the last byte must be moved first
			clc               ; start at the final pages of FROM and TO
		    txa
		    adc arg_move_from+1
		    sta arg_move_from+1
		    clc
		    txa
		    adc arg_move_to+1
		    sta arg_move_to+1
		    inx          ; allows the use of BNE after the DEX below
		    ldy arg_move_size
		    beq @3
		    dey          ; move bytes on the last page first
		    beq @2
@1: 	    lda (arg_move_from),Y
		    sta (arg_move_to),Y
		    dey
		    bne @1
@2:		    lda (arg_move_from),Y ; handle Y = 0 separately
		    sta (arg_move_to),Y
@3:			dey
		    dec arg_move_from+1   ; move the next page (if any)
		    dec arg_move_to+1
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
