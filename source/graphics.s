.export clear_screen, build_screen_margins, update_screen_color, init_graphics_tables, draw_sprite
.exportzp screen_bgcolor, screen_fgcolor

; temp - for debugging:
.export draw_even_sprite, draw_odd_sprite, blit_proc
.exportzp sprite_buffer, collision_flag, draw_ptr, sprite_source_ptr

.import chip8_screen_origin, chip8_screen_color_origin, physical_screen

.importzp zp0, zp1, zp2, zp3, zp4, zp5, zp6, zp7, reg_i, ram_page

.include "common.s"

.zeropage

screen_bgcolor:     .res 1
screen_fgcolor:     .res 1
collision_flag:     .res 1
sprite_buffer:      .res 5          ; staging area for drawing a row for a sprite
draw_ptr:           .res 2          ; physical screen address of upper left corner of sprite to be drawn
sprite_source_ptr:  .res 2          ; physical address of source for sprite bitmap data

; temporary registers
gt0:                .res 1
gt1:                .res 1

.code

.proc clear_screen
			lda #0
			ldy #chip8_screen_physical_width - 1
@loop:		.repeat chip8_screen_physical_height, i
				sta chip8_screen_origin + 40 * i, y
			.endrepeat
			dey
			bpl @loop
			rts
.endproc

.proc update_screen_color
			ldy #chip8_screen_physical_width - 1
@loop:		.repeat chip8_screen_physical_height, i
				sta chip8_screen_color_origin + 40 * i, y
			.endrepeat
			dey
			bpl @loop
			rts						
.endproc


.proc build_screen_margins
				; set character of margins to 15
			istore zp0, (physical_screen + 40 * chip8_screen_offset_y)		
			lda #15
			sta zp2
			jsr @go
				; set color ram of margins to 0
			istore zp0, (COLOR_RAM + 40 * chip8_screen_offset_y)
			lda #chrome_bgcolor
			sta zp2
@go:		ldx #chip8_screen_physical_height
@loop:		lda zp2
			ldy #chip8_screen_offset_x - 1
@1:			sta (zp0), y
			dey
			bpl @1
			ldy #39
@2:			sta (zp0), y
			dey
			cpy #(chip8_screen_physical_width + chip8_screen_offset_x)
			bpl @2
			clc
			lda #40
			adc zp0
			sta zp0
			lda #0
			adc zp1
			sta zp1
			dex
			bne @loop
			rts
.endproc


.macro top_even
			tax
			lsr a
			lsr a
			lsr a
			lsr a
			and #12
			sta sprite_buffer + 0
			txa
			lsr a
			lsr a
			and #12
			sta sprite_buffer + 1
			txa
			and #12
			sta sprite_buffer + 2
			txa
			asl a
			asl a
			and #12
			sta sprite_buffer + 3
.endmacro

.macro bottom_even
			tax
			rol a
			rol a
			rol a
			and #3
			ora sprite_buffer + 0
			sta sprite_buffer + 0
			txa
			lsr a
			lsr a
			lsr a
			lsr a
			and #3
			ora sprite_buffer + 1
			sta sprite_buffer + 1
			txa
			lsr a
			lsr a
			and #3
			ora sprite_buffer + 2
			sta sprite_buffer + 2
			txa
			and #3
			ora sprite_buffer + 3
			sta sprite_buffer + 3
.endmacro

.macro clear_even
			lda #0
			sta sprite_buffer + 0
			sta sprite_buffer + 1
			sta sprite_buffer + 2
			sta sprite_buffer + 3
.endmacro

.macro clear_odd
			clear_even
			sta sprite_buffer + 4
.endmacro

.macro top_odd
			tax
			rol a
			rol a
			rol a
			rol a
			and #4
			sta sprite_buffer + 0
			txa
			lsr a
			lsr a
			lsr a
			and #12
			sta sprite_buffer + 1
			txa
			lsr a
			and #12
			sta sprite_buffer + 2
			txa
			asl a
			and #12
			sta sprite_buffer + 3
			txa
			asl a
			asl a
			asl a
			and #8
			sta sprite_buffer + 4
.endmacro

.macro bottom_odd
			tax
			rol a
			rol a
			and #1
			ora sprite_buffer + 0
			sta sprite_buffer + 0
			txa
			rol a
			rol a
			rol a
			rol a
			and #3
			ora sprite_buffer + 1
			sta sprite_buffer + 1
			txa
			lsr a
			lsr a
			lsr a
			and #3
			ora sprite_buffer + 2
			sta sprite_buffer + 2
			txa
			lsr a
			and #3
			ora sprite_buffer + 3
			sta sprite_buffer + 3
			txa
			asl a
			and #2
			ora sprite_buffer + 4
			sta sprite_buffer + 4
.endmacro

param_physical_row = zp2
param_right_column = zp3
param_is_bottom_half = zp4
param_rows_left = zp5
param_sprite_width = zp6

USE_OLD_GRAPHICS = 0

.if USE_OLD_GRAPHICS

; blit - copies from sprite_buffer to screen
; Input:
;   Y - number of bytes to copy from sprite_buffer;  must be > 0
;   draw_ptr - target screen address
;   requires normalized data in sprite_buffer (i.e., upper 4 bits 0)
; Output:
;   collision_flag will contain nonzero if collision

blit_proc:
.proc blit
			dey
@loop:
			lda (draw_ptr), y
			tax
			and sprite_buffer, y
			beq @no_collision
			sta collision_flag
@no_collision:
			txa
			eor sprite_buffer, y
			sta (draw_ptr), y
			dey
			bpl @loop
  			rts
.endproc

.macro make_draw_sprite is_odd 

@src_ptr = zp7

			lda #0
			sta @src_ptr
			
			lda param_is_bottom_half
			beq @top_half
      
@initial_bottom_half:
      
			.if is_odd 
				clear_odd 
			.else 
				clear_even 
			.endif   

			jmp @bottom_half
      
@top_half:
			ldy @src_ptr
			lda (sprite_source_ptr), y
			inc @src_ptr 
      
			.if is_odd 
				top_odd
			.else
				top_even
			.endif   

			dec param_rows_left
			beq @no_bottom_half  
            
@bottom_half:
			ldy @src_ptr
			lda (sprite_source_ptr), y
			inc @src_ptr

			.if is_odd 
				bottom_odd
			.else
				bottom_even
			.endif 

			ldy param_sprite_width
			jsr blit
			dec param_rows_left
			beq @no_rows_left

			; draw_ptr += 40
			clc
			lda draw_ptr
			adc #40
			sta draw_ptr
			lda draw_ptr + 1
			adc #0
			sta draw_ptr + 1 

			jmp @top_half
      
@no_bottom_half:
			ldy param_sprite_width
			jmp blit                              

@no_rows_left:
			rts

.endmacro



; draw_ptr:  target_address of upper-left corner of sprite
; sprite_source_ptr:  source data for sprite
; param_is_bottom_half:         zero if drawing top half, non-zero if bottom half
; param_rows_left:              number of logical rows to draw
; param_sprite_width:           width of sprite buffer to blit
.proc draw_even_sprite
			make_draw_sprite 0
.endproc

.proc draw_odd_sprite
			make_draw_sprite 1
.endproc

; x:  		X coordinate
; y:  		Y coordinate
; a:  		height
; reg_i:	points to sprite
.proc draw_sprite
			sta zp5                     ; temporary stash
			lda #0
			sta collision_flag
			
			; check 0 <= x < 64
			txa
			and #192		
			bne @invalid
			
			; check 0 <= y < 32
			tya
			and #224	
			bne @invalid
			
			; a = a & 15
			lda zp5                     
			and #15
			
			; check a > 0
			beq @invalid		; 0 height
			
			; end_row = min(y + a, 32)
            sty param_rows_left
            clc
            adc param_rows_left
            cmp #32
            bmi @height_in_bounds
            lda #32

@height_in_bounds:
			; height = end_row - y
			sec
			sbc param_rows_left
			sta param_rows_left         ; param_rows_left now contains height
			
			; draw_ptr = screen_row_table[y]
			lda screen_row_table_low, y
			sta draw_ptr
			lda screen_row_table_high, y
			sta draw_ptr + 1
			
			; physical_col = x / 2
			txa
			lsr a
			
			; draw_ptr += physical_col
			clc
			adc draw_ptr
			sta draw_ptr
			lda draw_ptr + 1
			adc #0
			sta draw_ptr + 1  
			
			; source_ptr = *reg_i 
			lda reg_i
			sta sprite_source_ptr
			lda reg_i + 1
			map_to_physical
			sta sprite_source_ptr + 1
			
			; will source_ptr overflow ram?  
			cmp #(ram_page + $f)
			bne @source_ptr_ok
			
			clc
			lda sprite_source_ptr
			adc param_rows_left
			bcc @source_ptr_ok
			
			; if so, height exceeds ram by a bytes
			; height -= a
			clc
			sbc param_rows_left
			eor #$ff
			sta param_rows_left
			
@source_ptr_ok:
			
			; is y even?
			tya
			and #1
			sta param_is_bottom_half

			; determine strategy depending on if x is even or odd
			txa
			lsr a
			bcc @x_even
			bcs @x_odd
@invalid:
			rts

@x_odd:
            ; a contains physical_col 0..31
            tax
            lda sprite_widths_odd_table, x
            sta param_sprite_width

			; ready - draw the sprite
			jmp draw_odd_sprite
									
@x_even:
            ; a contains physical_col 0..31
            tax
            lda sprite_widths_even_table, x
            sta param_sprite_width

            ; ready - draw the sprite
            jmp draw_even_sprite

.endproc

.proc init_graphics_tables
			istore zp0, chip8_screen_origin
			
			ldx #0
@1:			clc
			lda zp0
			sta screen_row_table_low, x
			sta screen_row_table_low + 1, x
			adc #40
			sta zp0
			lda zp1
			sta screen_row_table_high, x
			sta screen_row_table_high + 1, x
			adc #0
			sta zp1
			inx
			inx
			cpx #32
			bne @1

			rts		
.endproc

.rodata
sprite_widths_even_table:
            .repeat 29
                .byte 4
            .endrepeat
            .byte 3, 2, 1

sprite_widths_odd_table:
            .repeat 28
                .byte 5
            .endrepeat
            .byte 4, 3, 2, 1

.bss
screen_row_table_low:		.res 32
screen_row_table_high:		.res 32

.else

;; new graphics


; **************** new sprite functions that wrap around screen correctly ***************


; blit - copies from sprite_buffer to screen
; Input:
;
;   draw_ptr - physical screen address of column 0 of row
;   param_right_column - physical column offset of _right-most_  pixel to copy; must be 0 <= y < 32
;   requires normalized data in sprite_buffer (i.e., only values from $0 - $f)
; Output:
;   collision_flag will contain nonzero if collision

.macro blit sprite_width
            .local @loop, @no_collision, @no_wrap

            ldx #(sprite_width - 1)
			dex
			ldy param_right_column
@loop:
			lda (draw_ptr), y
			sta gt0
			and sprite_buffer, x
			beq @no_collision
			sta collision_flag
@no_collision:
			lda gt0
			eor sprite_buffer, x
			sta (draw_ptr), y
			dey
			bpl @no_wrap
			ldy #31             ; wrap around to the right side of the screen
@no_wrap:   dex
			bpl @loop
.endmacro


; temp
blit_proc:      rts

; sprite_source_ptr:            source data for sprite
; param_physical_row:           physical row (0 - 15); used as index into screen_row_table
; param_right_column:           physical column offset of _right-most_  pixel to copy; must be 0 <= y < 32
; param_is_bottom_half:         zero if drawing top half, non-zero if bottom half
; param_rows_left:              number of logical rows to draw
.macro make_draw_sprite is_odd, sprite_width

@src_ptr = zp7

			lda #0
			sta @src_ptr

			lda param_is_bottom_half
			beq @top_half

@initial_bottom_half:

			.if is_odd
				clear_odd
			.else
				clear_even
			.endif

			jmp @bottom_half

@top_half:
			ldy @src_ptr
			lda (sprite_source_ptr), y
			inc @src_ptr

			.if is_odd
				top_odd
			.else
				top_even
			.endif

			dec param_rows_left
			beq @no_bottom_half

@bottom_half:
			ldy @src_ptr
			lda (sprite_source_ptr), y
			inc @src_ptr

			.if is_odd
				bottom_odd
			.else
				bottom_even
			.endif

			ldy param_physical_row
			lda screen_row_table_low, y
			sta draw_ptr
			lda screen_row_table_high + 1
			sta draw_ptr + 1
			iny
			tya
			and #31                             ; wrap around to the top
			sty param_physical_row

			blit sprite_width
			dec param_rows_left
			beq @no_rows_left

			jmp @top_half

@no_bottom_half:
			ldy param_physical_row
            lda screen_row_table_low, y
            sta draw_ptr
            lda screen_row_table_high + 1
            sta draw_ptr + 1
			blit sprite_width

@no_rows_left:
			rts

.endmacro

; sprite_source_ptr:            source data for sprite
; param_physical_row:           physical row (0 - 15); used as index into screen_row_table
; param_right_column:           physical column offset of _right-most_  pixel to copy; must be 0 <= y < 32
; param_is_bottom_half:         zero if drawing top half, non-zero if bottom half
; param_rows_left:              number of logical rows to draw
.proc draw_even_sprite
			make_draw_sprite 0, 4
.endproc

.proc draw_odd_sprite
			make_draw_sprite 1, 5
.endproc

; x:  		X coordinate
; y:  		Y coordinate
; a:  		height
; reg_i:	points to sprite
.proc draw_sprite
			sta gt0                     ; temporary stash
			lda #0
			sta collision_flag

			; x = x % 64
			txa
			and #63
			tax

			; y = y % 32
			tya
			and #31
			tay

			; a = a & 15
			lda gt0
			and #15

			; check a > 0
			beq @invalid		; 0 height

			; param_rows_left = height
			sta param_rows_left

			; source_ptr = *reg_i
			lda reg_i
			sta sprite_source_ptr
			lda reg_i + 1
			map_to_physical
			sta sprite_source_ptr + 1

			; will source_ptr overflow ram?
			cmp #(ram_page + $f)
			bne @source_ptr_ok

			clc
			lda sprite_source_ptr
			adc param_rows_left
			bcc @source_ptr_ok

			; if so, height exceeds ram by a bytes
			; height -= a
			clc
			sbc param_rows_left
			eor #$ff
			sta param_rows_left

@source_ptr_ok:

			; is y even?
			tya
			and #1
            sta param_is_bottom_half
            tya
			lsr a
			sta param_physical_row

			; determine strategy depending on if x is even or odd
			txa
			lsr a
			bcc @x_even
			bcs @x_odd
@invalid:
			rts

@x_odd:
            ; a contains physical_col 0..31
            adc #3          ; right-most physical column = a + 4  (adding 3 since carry is set)
            and #31         ; wrap
            sta param_right_column

			; ready - draw the sprite
			jmp draw_odd_sprite

@x_even:
            ; a contains physical_col 0..31
            adc #3          ; right-most physical column = a + 3  (carry is clear)
            and #31         ; wrap
            sta param_right_column

            ; ready - draw the sprite
            jmp draw_even_sprite

.endproc

.proc init_graphics_tables
			istore zp0, chip8_screen_origin

			ldx #0
@1:			clc
			lda zp0
			sta screen_row_table_low, x
			adc #40
			sta zp0
			lda zp1
			sta screen_row_table_high, x
			adc #0
			sta zp1
			inx
			cpx #16
			bne @1

			rts
.endproc


.bss
screen_row_table_low:		.res 16
screen_row_table_high:		.res 16

.endif

