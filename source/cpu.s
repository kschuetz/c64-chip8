.importzp reg_pc, reg_sp, ram_page
.import stack_low, stack_high

.export exec
	
.include "common.s"

.zeropage
op1:	.res 1


	;; converts high byte of logical RAM (in A) to physical RAM location
.macro map_to_physical
	and #63
	ora #ram_page
.endmacro
	
.code

	;;  op1 will contain first operand, X will contain second
.proc exec
        ldy #1
	lda (reg_pc), y
	tax
	dey
	lda (reg_pc), y
	sta op1
	lsr a
	lsr a
	lsr a
	and #$fe
	tay
	lda opcode_dispatch, y
	sta @jump
	lda opcode_dispatch + 1, y
	sta @jump + 1
@jump:  jmp $0000
.endproc	

.proc next
	clc
	lda reg_pc
	adc #2
	sta reg_pc
	lda reg_pc + 1
	adc #2
	map_to_physical
	sta reg_pc + 1
	rts
.endproc
	
.proc opcode_0
	cpx #$e0
	bne @1
	jmp clear_screen
@1:	cpx #$ee
	bne next	
	jmp return_from_subroutine
.endproc

;; 1NNN - jumps to address NNN
.proc opcode_1
	stx reg_pc
	lda op1
	map_to_physical
	sta reg_pc + 1
	rts
	
.endproc

	
;; 2NNN	- Calls subroutine at NNN.
.proc opcode_2
        clc
	lda reg_pc
	adc #2
	ldy reg_sp
	sta stack_low, Y
	lda reg_pc + 1
	adc #2
	map_to_physical
	sta stack_high, Y
	dey
	sty reg_sp
	jmp opcode_1
	
.endproc

.proc opcode_3

	rts
	
.endproc

.proc opcode_4

	rts
	
.endproc

.proc opcode_5

	rts
	
.endproc

.proc opcode_6

	rts
	
.endproc

.proc opcode_7

	rts
	
.endproc

.proc opcode_8

	rts
	
.endproc

.proc opcode_9

	rts
	
.endproc

.proc opcode_a

	rts
	
.endproc

.proc opcode_b

	rts
	
.endproc

.proc opcode_c

	rts
	
.endproc

.proc opcode_d

	rts
	
.endproc

.proc opcode_e

	rts
	
.endproc

.proc opcode_f

	rts
	
.endproc


.proc clear_screen
	jmp next
.endproc

.proc return_from_subroutine
	rts
.endproc
	
.rodata

opcode_dispatch:
	.addr opcode_0, opcode_1, opcode_2, opcode_3, opcode_4, opcode_5, opcode_6, opcode_7 
	.addr opcode_8, opcode_9, opcode_a, opcode_b, opcode_c, opcode_d, opcode_e, opcode_f 
