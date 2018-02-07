.exportzp registers, reg_v, reg_pc, reg_i, reg_sp
.exportzp reg_v0, reg_v1, reg_v2, reg_v3, reg_v4, reg_v5, reg_v6, reg_v7
.exportzp reg_v8, reg_v9, reg_va, reg_vb, reg_vc, reg_vd, reg_ve, reg_vf
.export clear_registers

.import program_start

.include "common.s"

.zeropage

registers:
reg_v:
reg_v0:         .res 1
reg_v1:         .res 1
reg_v2:         .res 1
reg_v3:         .res 1
reg_v4:         .res 1
reg_v5:         .res 1
reg_v6:         .res 1
reg_v7:         .res 1
reg_v8:         .res 1
reg_v9:         .res 1
reg_va:         .res 1
reg_vb:         .res 1
reg_vc:         .res 1
reg_vd:         .res 1
reg_ve:         .res 1
reg_vf:         .res 1
reg_pc:	        .res 2
reg_i:	        .res 2
reg_sp:	        .res 1
registers_end:

.code

.proc clear_registers
                lda #0
                ldy #(registers_end - registers - 1)
@loop:          sta registers, y
                dey
                bpl @loop

                istore reg_pc, program_start
                rts
.endproc
