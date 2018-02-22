.include "common.s"

.export clear_registers
.exportzp registers
.exportzp reg_v
.exportzp reg_pc
.exportzp reg_i
.exportzp reg_sp
.exportzp reg_v0
.exportzp reg_v1
.exportzp reg_v2
.exportzp reg_v3
.exportzp reg_v4
.exportzp reg_v5
.exportzp reg_v6
.exportzp reg_v7
.exportzp reg_v8
.exportzp reg_v9
.exportzp reg_va
.exportzp reg_vb
.exportzp reg_vc
.exportzp reg_vd
.exportzp reg_ve
.exportzp reg_vf

.import program_start

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
