.include "common.s"

.export cpu_next
.export exec
.exportzp cpu_temp0
.exportzp cpu_temp_addr0

.import clear_screen
.import convert_to_bcd
.import draw_sprite
.import get_digit_font_location
.import get_guest_keypress
.import get_random
.import is_guest_key_pressed
.import ram
.import read_registers_from_ram
.import set_delay_timer
.import set_sound_timer
.import stack_high
.import stack_low
.import write_registers_to_ram
.importzp collision_flag
.importzp delay_timer
.importzp guest_ram_page
.importzp reg_i
.importzp reg_pc
.importzp reg_sp
.importzp reg_v
.importzp reg_vf

.zeropage

op1:             .res 1
cpu_temp0:          .res 1
cpu_temp1:          .res 1
cpu_temp_addr0:     .res 2
 
.code

.macro op1_to_y
            lda op1
            and #15
            tay
.endmacro  

.macro x_shr_4_to_a 
            txa
            lsr a
            lsr a
            lsr a
            lsr a
.endmacro  

.macro x_shr_4_to_y 
            x_shr_4_to_a
            tay
.endmacro        

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
            lsr a
            tay
            lda opcode_dispatch_low, y
            sta @jump + 1
            lda opcode_dispatch_high, y
            sta @jump + 2
@jump:      jmp $0000
.endproc

.macro skip_if_eq
            beq skip
            bne next
.endmacro 

.macro skip_if_ne
            beq next
            bne skip
.endmacro   

;; Implementations of opcodes are in macros so we can define them in order,
;; and rearrange them later in memory to optimize use of branching instructions

;; 0nnn - SYS addr
;; No-op
;;
;; 00E0 - CLS
;; Clear the display
;;
;; 00EE - RET
;; Return from subroutine
.macro opcode_0_impl
            cpx #$e0
            bne @1
            jsr clear_screen
            jmp next
@1:         cpx #$ee
            bne next

return_from_subroutine:
            dec reg_sp
            ldy reg_sp
            lda stack_low, y
            sta reg_pc
            lda stack_high, y
            map_to_host
            sta reg_pc + 1

            rts
.endmacro

;; 1nnn - JP addr
;; Jump to location nnn
.macro opcode_1_impl
            txa
            sta reg_pc
            lda op1
            map_to_host
            sta reg_pc + 1
            rts
.endmacro
 
;; 2nnn - CALL addr
;; Call subroutine at nnn
.macro opcode_2_impl
            clc
            lda reg_pc
            adc #2
            ldy reg_sp
            sta stack_low, Y
            lda reg_pc + 1
            adc #0
            map_to_host
            sta stack_high, Y
            iny                             ; stack grows upwards
            sty reg_sp
            jmp opcode_1
.endmacro

;; 3xkk - SE Vx, byte
;; Skip next instruction if Vx = kk
.macro opcode_3_impl
            op1_to_y
            txa
            cmp reg_v, y
         skip_if_eq
.endmacro

;; 4xkk - SNE Vx, byte
;; Skip next instruction if Vx != kk
.macro opcode_4_impl
            op1_to_y
            txa
            cmp reg_v, y
         skip_if_ne
.endmacro

;; 5xy0 - SE Vx, Vy
;; Skip next instruction if Vx = Vy
.macro opcode_5_impl
            op1_to_y             
            lda reg_v, y
            sta cpu_temp0
            x_shr_4_to_a
            tay
            lda reg_v, y
            cmp cpu_temp0
            skip_if_eq
.endmacro

;; 6xkk - LD Vx, byte
;; Set Vx = kk
.macro opcode_6_impl
            op1_to_y
            stx reg_v, y
         jmp next
.endmacro

;; 7xkk - ADD Vx, byte
;; Set Vx = Vx + kk.
.macro opcode_7_impl
            op1_to_y
            lda reg_v, y
            sta cpu_temp0
            txa
            clc
            adc cpu_temp0
            sta reg_v, y           
         jmp next
.endmacro

.macro opcode_8_impl
            txa
            and #15
            tay
            lda opcode_8_dispatch_low, y
            sta @jump + 1
            lda opcode_8_dispatch_high, y
            sta @jump + 2
            x_shr_4_to_y
            lda op1
            and #15
            tax
@jump:      jmp $0000
.endmacro

;; for the '8' opcodes:
;;      X contains x
;;      Y contains y   

;; 8xy0 - LD Vx, Vy
;; Set Vx = Vy.
.macro opcode_8_0_impl
            lda reg_v, y
            sta reg_v, x
            jmp next           
.endmacro

;; 8xy1 - OR Vx, Vy
;; Set Vx = Vx OR Vy.
.macro opcode_8_1_impl
            lda reg_v, y
            ora reg_v, x
            sta reg_v, x
            jmp next
.endmacro

;; 8xy2 - AND Vx, Vy
;; Set Vx = Vx AND Vy.
.macro opcode_8_2_impl
            lda reg_v, y
            and reg_v, x
            sta reg_v, x
            jmp next
.endmacro

;; 8xy3 - XOR Vx, Vy
;; Set Vx = Vx XOR Vy.
.macro opcode_8_3_impl
            lda reg_v, y
            eor reg_v, x
            sta reg_v, x
            jmp next
.endmacro

;; 8xy4 - ADD Vx, Vy
;; Set Vx = Vx + Vy, set VF = carry.
.macro opcode_8_4_impl
            clc
            lda reg_v, y
            adc reg_v, x
            sta reg_v, x
            bcc clear_carry_and_exit
            ; fall through to set_carry_and_exit
.endmacro

;; 8xy5 - SUB Vx, Vy
;; Set Vx = Vx - Vy, set VF = NOT borrow.
.macro opcode_8_5_impl
            sec
            lda reg_v, x
            sbc reg_v, y
            sta reg_v, x
            bcc clear_carry_and_exit
            bcs set_carry_and_exit
.endmacro

;; 8xy6 - SHR Vx {, Vy}
;; Set Vx = Vx SHR 1.   (y is ignored)
.macro opcode_8_6_impl
            lsr reg_v, x
            bcc clear_carry_and_exit
            bcs set_carry_and_exit
.endmacro

;; 8xy7 - SUBN Vx, Vy
;; Set Vx = Vy - Vx, set VF = NOT borrow.
.macro opcode_8_7_impl
            sec
            lda reg_v, y
            sbc reg_v, x
            sta reg_v, x
            bcc clear_carry_and_exit
            bcs set_carry_and_exit
.endmacro

;; 8xyE - SHL Vx {, Vy}
;; Set Vx = Vx SHL 1.  (y is ignored)
.macro opcode_8_e_impl
            asl reg_v, x
            bcc clear_carry_and_exit
            bcs set_carry_and_exit
.endmacro

;; 9xy0 - SNE Vx, Vy
;; Skip next instruction if Vx != Vy.
.macro opcode_9_impl
         op1_to_y             
            lda reg_v, y
            sta cpu_temp0
            x_shr_4_to_a
            tay
            lda reg_v, y
            cmp cpu_temp0
            skip_if_ne
.endmacro

;; Annn - LD I, addr
;; Set I = nnn.
.macro opcode_a_impl
            stx reg_i
            lda op1
            map_to_host
            sta reg_i + 1               
         jmp next
.endmacro

; Bnnn - JP V0, addr
; Jump to location nnn + V0.
.macro opcode_b_impl
            txa
            clc
            adc reg_v
            sta reg_pc
            lda op1
            adc #0
            map_to_host
            sta reg_pc + 1
            rts
.endmacro

;; Cxkk - RND Vx, byte
;; Set Vx = random byte AND kk
.macro opcode_c_impl
            stx @stash_mask + 1
            lda op1
            and #15
            sta @stash_y + 1
            jsr get_random
@stash_mask:
            and #0
@stash_y:
            ldy #0
            sta reg_v, y
            jmp next
.endmacro

;; Cxkk - RND Vx, byte
;; Set Vx = random byte AND kk
.macro opcode_c_impl_old
            op1_to_y
            sty cpu_temp0
            lda reg_v, y
            sta cpu_temp1
            jsr get_random
            and cpu_temp1
            ldy cpu_temp0
            sta reg_v, y
            jmp next
.endmacro

;; Dxyn - DRW Vx, Vy, nibble
;; Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.
.macro opcode_d_impl
            op1_to_y
            lda reg_v, y
            sta @stash_x + 1
            txa
            sta @stash_a + 1
            lsr a
            lsr a
            lsr a
            lsr a
            tay
            lda reg_v, y
            tay
@stash_a:   lda #0
@stash_x:   ldx #0
            jsr draw_sprite
            lda collision_flag
            beq @no_collision
            lda #1
            .byte $2c   ; BIT instruction
@no_collision:
            lda #0
            sta reg_vf
            jmp next
.endmacro

;; Ex9E - SKP Vx
;; Skip next instruction if key with the value of Vx is pressed.
;;
;; ExA1 - SKNP Vx
;; Skip next instruction if key with the value of Vx is not pressed.
.macro opcode_e_impl
            op1_to_y
            lda reg_v, y
            cpx #$9e
            beq @skp
            cpx #$a1
            beq @sknp
            jmp next
@skp:       jsr is_guest_key_pressed
            skip_if_ne
@sknp:      jsr is_guest_key_pressed
            skip_if_eq
.endmacro

;; Fx07 - LD Vx, DT
;; Set Vx = delay timer value.
;; 
;; Fx0A - LD Vx, K
;; Wait for a key press, store the value of the key in Vx.
;; 
;; Fx15 - LD DT, Vx
;; Set delay timer = Vx.
;; 
;; Fx18 - LD ST, Vx
;; Set sound timer = Vx.
;; 
;; Fx1E - ADD I, Vx
;; Set I = I + Vx.
;; 
;; Fx29 - LD F, Vx
;; Set I = location of sprite for digit Vx.
;; 
;; Fx33 - LD B, Vx
;; Store BCD representation of Vx in memory locations I, I+1, and I+2.
;; 
;; Fx55 - LD [I], Vx
;; Store registers V0 through Vx in memory starting at location I.
;; 
;; Fx65 - LD Vx, [I]
;; Read registers V0 through Vx from memory starting at location I.
.macro opcode_f_impl
            op1_to_y
            cpx #$07
            beq @read_delay
            cpx #$0a
            beq wait_key
            cpx #$15
            beq @write_delay
            cpx #$18
            beq @write_sound
            cpx #$1e
            beq @add_to_i
            cpx #$29
            bne :+
            jmp get_digit_font_location
:           cpx #$33
            bne :+
            jmp convert_to_bcd
:           cpx #$55
            bne :+
            jmp write_registers_to_ram
:           cpx #$65
            bne :+
            jmp read_registers_from_ram
:           jmp next

@add_to_i:
            clc
            lda reg_v, y
            adc reg_i
            sta reg_i
            lda reg_i + 1
            adc #0
            map_to_host
            sta reg_i + 1
            jmp next

@read_delay:
            lda delay_timer
            sta reg_v, y
            jmp next

@write_delay:
            lda reg_v, y
            jsr set_delay_timer
            jmp next

@write_sound:
            lda reg_v, y
            jsr set_sound_timer
            jmp next

wait_key:
            sty stash1 + 1
            jsr get_guest_keypress
            bpl key_pressed
no_key_pressed:
            ; no key pressed - don't update PC
            rts
key_pressed:
stash1:     ldy #0
            sta reg_v, y
            jmp next
.endmacro

;; The following are laid out so all of their branches are in range.
;; -----------------------------------------------------------------

.macro def_opcode s
    .proc .ident(.concat("opcode_", s))
        .ident(.concat("opcode_", s, "_impl"))   
    .endproc
.endmacro

def_opcode "0"
def_opcode "1"
def_opcode "2"
def_opcode "3"
def_opcode "4"

;; pc = pc + 2
cpu_next:               ; exported name of next
.proc next
            clc
            lda reg_pc
            adc #2
next1:      sta reg_pc
            lda reg_pc + 1
            adc #0
            map_to_host
            sta reg_pc + 1
            rts
.endproc

;; pc = pc + 4
.proc skip
            clc
            lda reg_pc
            adc #4
            jmp next::next1
.endproc 

def_opcode "5"
def_opcode "9"
def_opcode "6"
def_opcode "e"
def_opcode "7"
def_opcode "8"
def_opcode "8_0"
def_opcode "8_1"
def_opcode "8_2"
def_opcode "8_3"
def_opcode "8_4"

;; must immediately follow def_opcode_8_4
.proc set_carry_and_exit
            lda #1
            sta reg_vf
            jmp next
.endproc

.proc clear_carry_and_exit
            lda #0
            sta reg_vf
            jmp next
.endproc

def_opcode "8_5"
def_opcode "8_6"
def_opcode "8_7"
def_opcode "8_e"
def_opcode "a"
def_opcode "b"
def_opcode "c"
def_opcode "d"
def_opcode "f"

.rodata

.define opcodes_0_thru_7 opcode_0, opcode_1, opcode_2, opcode_3, opcode_4, opcode_5, opcode_6, opcode_7
.define opcodes_8_thru_f opcode_8, opcode_9, opcode_a, opcode_b, opcode_c, opcode_d, opcode_e, opcode_f

opcode_dispatch_low:
            .lobytes opcodes_0_thru_7
            .lobytes opcodes_8_thru_f

opcode_dispatch_high:
            .hibytes opcodes_0_thru_7
            .hibytes opcodes_8_thru_f

.define opcodes_8_0_thru_8_7 opcode_8_0, opcode_8_1, opcode_8_2, opcode_8_3, opcode_8_4, opcode_8_5, opcode_8_6, opcode_8_7
.define opcodes_8_8_thru_8_f next, next, next, next, next, next, opcode_8_e, next

opcode_8_dispatch_low:
            .lobytes opcodes_8_0_thru_8_7
            .lobytes opcodes_8_8_thru_8_f

opcode_8_dispatch_high:
            .hibytes opcodes_8_0_thru_8_7
            .hibytes opcodes_8_8_thru_8_f
