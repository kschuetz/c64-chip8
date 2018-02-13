; temporary debugging routines

.export init_debug

.proc init_debug
         rts
.endproc

;.export init_pc_history, pc_to_history
;.importzp reg_pc
;
;.include "common.s"
;
;pc_history = $5000
;
;.zeropage
;
;pc_history_ptr: .res 2
;
;.code
;
;.proc init_pc_history
;        lda #0
;        ldy #0
;@loop:  .repeat 48, i
;            sta pc_history + i * $100, y
;        .endrepeat
;        dey
;        beq @done
;        jmp @loop
;@done:  istore pc_history_ptr, pc_history
;.endproc
;
;
;.proc pc_to_history
;        rts
;
;        ldy #0
;        lda reg_pc
;        sta (pc_history_ptr), y
;        iny
;        lda reg_pc + 1
;        sta (pc_history_ptr), y
;
;        clc
;        lda pc_history_ptr
;        adc #2
;        sta pc_history_ptr
;        lda pc_history_ptr + 1
;        adc #0
;        sta pc_history_ptr + 1
;
;        lda #pc_history_ptr + 1
;        bpl @done
;        lda #<pc_history
;        sta pc_history_ptr
;        lda #>pc_history
;        sta pc_history_ptr + 1
;@done:
;        rts
;
;.endproc