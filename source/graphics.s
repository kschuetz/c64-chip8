.export clear_screen, build_screen_margins, update_screen_color

.import chip8_screen_origin, chip8_screen_color_origin, physical_screen
.exportzp screen_bgcolor, screen_fgcolor

.importzp zp0, zp1, zp2, zp3, zp4, zp5, zp6, zp7

.include "common.s"

.zeropage

screen_bgcolor:     .res 1
screen_fgcolor:     .res 1
collision_flag:     .res 1
sprite_buffer:      .res 5          ; staging area for drawing a row for a sprite
draw_ptr:           .res 2          ; physical screen address of upper left corner of sprite to be drawn
sprite_source_ptr:  .res 2          ; physical address of source for sprite bitmap data

.code

.proc clear_screen
			lda #6
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


; blit - copies from sprite_buffer to screen
; Input:
;   Y - number of bytes to copy from sprite_buffer;  must be > 0  
;   draw_ptr - target screen address
;   requires normalized data in sprite_buffer (i.e., upper 4 bits 0)
; Output:
;   collision_flag will contain nonzero if collision

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

.macro top_even
      tax
      rol a
      rol a
      rol a
      and #12
      sta sprite_buffer + 0
      txa
      and #48
      lsr a
      lsr a
      lsr a
      lsr a
      sta sprite_buffer + 1
      txa
      and #12
      lsr a
      lsr a
      sta sprite_buffer + 2
      txa
      and #3
      sta sprite_buffer + 3
.endmacro

.macro bottom_even
      tax
      rol a
      rol a
      rol a
      and #12
      ora sprite_buffer + 0
      sta sprite_buffer + 0
      txa
      and #48
      lsr a
      lsr a
      lsr a
      lsr a
      ora sprite_buffer + 1
      sta sprite_buffer + 1
      txa
      and #12
      lsr a
      lsr a
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
      lda #0
      sta sprite_buffer + 0
      sta sprite_buffer + 1
      sta sprite_buffer + 2
      sta sprite_buffer + 3
      sta sprite_buffer + 4
.endmacro

.macro top_odd
      tax
      rol a
      rol a
      rol a
      and #2
      sta sprite_buffer + 0
      txa
      and #96
      lsr a
      lsr a
      lsr a
      sta sprite_buffer + 1
      txa
      and #24
      lsr a
      sta sprite_buffer + 2
      txa
      and #6
      asl a
      sta sprite_buffer + 3
      txa
      and #1
      asl a
      asl a
      asl a
      sta sprite_buffer + 4
.endmacro

.macro bottom_odd
      tax
      rol a
      rol a
      rol a
      and #2
      ora sprite_buffer + 0
      sta sprite_buffer + 0
      txa
      and #96
      lsr a
      lsr a
      lsr a
      ora sprite_buffer + 1
      sta sprite_buffer + 1
      txa
      and #24
      lsr a
      ora sprite_buffer + 2
      sta sprite_buffer + 2
      txa
      and #6
      asl a
      ora sprite_buffer + 3
      sta sprite_buffer + 3
      txa
      and #1
      asl a
      asl a
      asl a
      ora sprite_buffer + 4
      sta sprite_buffer + 4
.endmacro

.macro make_draw_sprite is_odd 

@is_bottom_half = zp4
@rows_left = zp5
@sprite_width = zp6
@src_ptr = zp7

      lda @is_bottom_half
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
      
      dec @rows_left
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
      
      ldy @sprite_width
      jsr blit
      dec @rows_left
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
      ldy @sprite_width
      jmp blit                              

@no_rows_left:
      rts

.endmacro



; draw_ptr:  target_address of upper-left corner of sprite
; sprite_source_ptr:  source data for sprite
; zp4:       zero if drawing top half, non-zero if bottom half
; zp5:       number of logical rows to draw
; zp6:       width of sprite buffer to blit
.proc draw_even_sprite
      make_draw_sprite 0
.endproc

.proc draw_odd_sprite
      make_draw_sprite 1
.endproc
