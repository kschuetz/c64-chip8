.export convert_to_bcd, get_digit_font_location
.export read_registers_from_ram, write_registers_to_ram

.import guest_ram, decimal_table_low, decimal_table_high, cpu_next
.importzp reg_v, reg_i, cpu_temp0, cpu_temp_addr0, guest_ram_page

.include "common.s"

;; These routines should only be called by CPU routines

;; Store BCD representation of Vx in memory locations I, I+1, and I+2.
;; Y: V register to read from.  Must be $0 - $f before calling.
.proc convert_to_bcd
            lda reg_i + 1
            map_to_host
            cmp #(guest_ram_page + $f)        ; check if I+2 is going to exceed RAM
            sta cpu_temp_addr0 + 1
            beq @handle_edge_cases      
      
            lda reg_i
@safe:      sta cpu_temp_addr0
            lda reg_v, y
            tax

            ; hundreds in *i           
            ldy #0
            lda decimal_table_high, x
            and #15
            sta (cpu_temp_addr0), y
            
            ; tens in *i + 1
            lda decimal_table_low, x
            tax                             ; don't need x anymore
            lsr a
            lsr a 
            lsr a
            lsr a
            iny
            sta (cpu_temp_addr0), y
            
            ; ones in *i + 2
            txa
            and #15
            iny
            sta (cpu_temp_addr0), y
            
            jmp cpu_next
            
@handle_edge_cases:
            ; edge cases are if I contains $ffe or $fff
            ; in those cases, we will only write 2 or 1 digits (respectively)
            lda reg_i
            cmp $fe
            beq @limit_to_two
            cmp $ff
            beq @limit_to_one
            bne @safe
@limit_to_two:
            lda reg_v, y
            tax
            ;; hundreds
            lda decimal_table_high, x
            and #15
            sta guest_ram + $ffe
            
            ;; tens
            lda decimal_table_low, x
            lsr a
            lsr a 
            lsr a
            lsr a
@done:      sta guest_ram + $fff
            jmp cpu_next
@limit_to_one:              
            lda reg_v, y
            tax
            ;; hundreds only
            lda decimal_table_high, x
            and #15       
            jmp @done
.endproc

; Y: V register to read from.  Must be $0 - $f before calling.
.proc get_digit_font_location
            ; base location of digit in fontset is digit * 5
            lda reg_v, y        
            and #15
            tay
            lda font_digit_ptrs, y
            sta reg_i
            lda #guest_ram_page
            sta reg_i + 1
            jmp cpu_next
.endproc

.macro ram_registers_setup
            tya
            and #15
            clc
            adc #1
            sta cpu_temp0

            lda reg_i + 1
            map_to_host
            cmp #(guest_ram_page + $f)        ; check if i+15 is going to exceed RAM boundary
            sta cpu_temp_addr0 + 1
            beq @check_boundary

            lda reg_i
            sta cpu_temp_addr0
@safe:      ldx cpu_temp0                     ; number of registers safe to read/write
            ldy #0
.endmacro

.macro ram_registers_check_boundary
@check_boundary:
            lda reg_i
            ; if a <= $f0, safe to read/write all
            cmp #$f1
            bcc @safe

            ; otherwise, safe to read/write $100 - a
            eor #$ff
            tax
            inx
            bne @loop1          ; unconditional
.endmacro

.proc read_registers_from_ram
            ram_registers_setup
@loop1:
            lda (cpu_temp_addr0), y
            sta reg_v, y
            iny
            dex
            bpl @loop1

            cpy cpu_temp0
            beq @done

            lda #0                      ; fill remaining with zeroes
@loop2:     sta reg_v, y
            iny
            cpy cpu_temp0
            bne @loop2
@done:      jmp cpu_next

            ram_registers_check_boundary
.endproc

.proc write_registers_to_ram
            ram_registers_setup
@loop1:
            lda reg_v, y
            sta (cpu_temp_addr0), y
            iny
            dex
            bpl @loop1
            jmp cpu_next
            
            ram_registers_check_boundary
.endproc

.rodata
font_digit_ptrs:
            .byte 0, 5, 10, 15, 20, 25, 30, 35
            .byte 40, 45, 50, 55, 60, 65, 70, 75