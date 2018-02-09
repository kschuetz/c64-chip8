.import draw_sprite
.import move_up
.importzp reg_i, zp0, zp2, zp4, zp5, zp6
.import draw_even_sprite, draw_odd_sprite, blit_proc, chip8_screen_origin, debug_output_hex
.importzp sprite_buffer, collision_flag, draw_ptr, sprite_source_ptr

.export test_draw

.include "common.s"

test_sprite_1 = $c050


.proc test_draw
			jmp test_draw_0
.endproc


.proc test_draw_0
			istore zp0, test_data_1
			istore zp2, test_sprite_1
			istore zp4, 8
			jsr move_up
			
			istore reg_i, test_sprite_1
			ldx #1
			ldy #1
			lda #8
			;jsr draw_sprite
			lda collision_flag
			jsr debug_output_hex

			istore reg_i, test_sprite_1
            ldx #49
            ldy #15
            lda #15
            jsr draw_sprite
            lda collision_flag
            jsr debug_output_hex

			rts
.endproc


; blit - copies from sprite_buffer to screen
; Input:
;   Y - number of bytes to copy from sprite_buffer;  must be > 0  
;   draw_ptr - target screen address
;   requires normalized data in sprite_buffer (i.e., upper 4 bits 0)
; Output:
;   collision_flag will contain nonzero if collision
.proc test_blit
			istore draw_ptr, chip8_screen_origin 
			ldy #4
:			lda sprite_buffer_data, y
			sta sprite_buffer, y
			dey
			bpl :-
			
			ldy #5
			jmp blit_proc
.endproc

; param_is_bottom_half = zp4
; param_rows_left = zp5
; param_sprite_width = zp6

; draw_ptr:  target_address of upper-left corner of sprite
; sprite_source_ptr:  source data for sprite
; param_is_bottom_half:         zero if drawing top half, non-zero if bottom half
; param_rows_left:              number of logical rows to draw
; param_sprite_width:           width of sprite buffer to blit
.proc testdraw_even_sprite
			istore sprite_source_ptr, test_data_1
			istore draw_ptr, chip8_screen_origin
			
			lda #1
			sta zp4
			lda #8
			sta zp5
			lda #4 
			sta zp6
			jsr draw_even_sprite

			istore sprite_source_ptr, test_data_1
            istore draw_ptr, (chip8_screen_origin + 121)

            lda #0
            sta zp4
            lda #8
            sta zp5
            lda #4
            sta zp6
            jmp draw_even_sprite
.endproc

.proc testdraw_odd_sprite
			istore sprite_source_ptr, test_data_1
			istore draw_ptr, chip8_screen_origin
			
			lda #0
			sta zp4
			lda #8
			sta zp5
			lda #5 
			sta zp6
			jmp draw_odd_sprite
.endproc


;; x:  		X coordinate
; y:  		Y coordinate
; a:  		height
; reg_i:	points to sprite	
;.proc draw_sprite

.rodata 
test_data_1:
            .byte 255, 127, 63, 31, 15, 7, 3, 1
            .byte 128, 129, 131, 135, 143, 159, 193, 255

sprite_buffer_data: .byte 15, 13, 8, 0, 1