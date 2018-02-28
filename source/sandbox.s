;.import draw_sprite
;.import move_up
;.importzp reg_i, zp0, zp2, zp3, zp4, zp5, zp6
;.import draw_even_sprite, draw_odd_sprite, guest_screen_origin
;.importzp sprite_buffer, collision_flag, sprite_source_ptr
;
;.export test_draw
;
;.include "common.s"
;
;test_sprite_1 = $c050
;
;
;.proc test_draw
;			jmp test_draw_0
;.endproc
;
;
;.proc debug_output_hex
;            rts
;.endproc
;
;.proc test_draw_0
;			istore zp0, test_data_1
;			istore zp2, test_sprite_1
;			istore zp4, 16
;			jsr move_up
;
;			istore reg_i, test_sprite_1
;			ldx #0
;			ldy #31
;			lda #15
;			jsr draw_sprite
;			lda collision_flag
;			jsr debug_output_hex
;
;;			istore reg_i, test_sprite_1
;;            ldx #1
;;            ldy #1
;;            lda #13
;;            jsr draw_sprite
;;            lda collision_flag
;;            jsr debug_output_hex
;
;			rts
;.endproc
;
;param_physical_row = zp2
;param_right_column = zp3
;param_is_bottom_half = zp4
;param_rows_left = zp5
;param_sprite_width = zp6
;; sprite_source_ptr:            source data for sprite
;; param_physical_row:           physical row (0 - 15); used as index into screen_row_table
;; param_right_column:           physical column offset of _right-most_  pixel to copy; must be 0 <= y < 32
;; param_is_bottom_half:         zero if drawing top half, non-zero if bottom half
;; param_rows_left:              number of logical rows to draw
;.proc testdraw_even_sprite
;            istore sprite_source_ptr, test_data_1
;            lda #13
;            sta param_physical_row
;            lda #1
;            sta param_right_column
;            lda #0
;            sta param_is_bottom_half
;            lda #15
;            sta param_rows_left
;            jmp draw_even_sprite
;.endproc
;
;;; x:  		X coordinate
;; y:  		Y coordinate
;; a:  		height
;; reg_i:	points to sprite
;;.proc draw_sprite
;
;.rodata
;test_data_1:
;            .byte 255, 127, 63, 31, 15, 7, 3, 1
;            .byte 3, 7, 15, 31, 63, 127, 255
;
;test_data_2:
;            .byte 255, 255, 255, 255, 255, 255, 255, 255
;            .byte 255, 255, 255, 255, 255, 255, 255, 255
;
;sprite_buffer_data: .byte 15, 13, 8, 0, 1
