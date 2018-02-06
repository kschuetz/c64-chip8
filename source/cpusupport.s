.export convert_to_bcd, get_digit_font_location

.import ram, decimal_table_low, decimal_table_high, cpu_next
.importzp reg_v, reg_i, cpu_temp_addr0, ram_page

.include "common.s"

;; These routines should only be called by CPU routines

;; Store BCD representation of Vx in memory locations I, I+1, and I+2.
;; Y: V register to read from.  Must be $0 - $f before calling.
.proc convert_to_bcd
            lda reg_i + 1
            map_to_physical
            cmp #(ram_page + $f)        ; check if I+2 is going to exceed RAM
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
            sta ram + $ffe
            
            ;; tens
            lda decimal_table_low, x
            lsr a
            lsr a 
            lsr a
            lsr a
@done:      sta ram + $fff
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
            sta reg_i
            asl a           ; a = a * 4
            asl a  	
            clc 
            adc reg_i
            sta reg_i
            adc #0
            map_to_physical
            sta reg_i + 1
            jmp cpu_next
.endproc