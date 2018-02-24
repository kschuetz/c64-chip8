.include "common.s"

.export button_sprite_pointer
.export button_sprites_1
.export button_sprites_2
.export button_sprites_3
.export init_buttons
.export init_button_sprites
.export set_button_sprite_frames
.export set_button_colors

.import buttons_sprite_set
.import chip8_key_port_a
.import chip8_key_port_b
.import fill
.import sprite_pointers
.import update_timers
.importzp kbd_col0
.importzp zp0
.importzp zp1
.importzp zp2

.proc init_buttons
@current = zp2

            istore zp0, buttons_sprite_set
            lda #0
            ldx #$07
            ldy #$ff
            jsr fill
            lda #32
            sta @current

@outer:
            ldx #15
@inner:
            ldy cs_to_sprite, x
@tops_source:
            lda buttons_sprite_data, x
@tops_dest:
            sta buttons_sprite_set, y
@bottoms_source:
            lda buttons_sprite_data + 512, x
@bottoms_dest:
            sta buttons_sprite_set + 24, y
            dex
            bpl @inner

            dec @current
            beq @done

            clc
            lda @tops_source + 1
            adc #16
            sta @tops_source + 1
            bcc :+
            inc @tops_source + 2
            clc
:           lda @tops_dest + 1
            adc #64
            sta @tops_dest + 1
            bcc :+
            inc @tops_dest + 2

            clc
:           lda @bottoms_source + 1
            adc #16
            sta @bottoms_source + 1
            bcc :+
            inc @bottoms_source + 2
            clc
:           lda @bottoms_dest + 1
            adc #64
            sta @bottoms_dest + 1
            bcc :+
            inc @bottoms_dest + 2
:           jmp @outer

@done:
.endproc

button_sprites_left_edge = 54
button_sprites_spacing = 12
button_sprites_top = 206
button_sprites_vertical_spacing = 11


; call once before setup_irq
.proc init_button_sprites
            .repeat 4, i
                lda #button_sprites_left_edge + (i * button_sprites_spacing)
                sta $d000 + (2 * i)
                sta $d008 + (2 * i)
            .endrepeat

            lda #button_sprites_top
            sta $d001
            sta $d003
            sta $d005
            sta $d007

            lda #button_sprites_top + button_sprites_vertical_spacing
            sta $d009
            sta $d00b
            sta $d00d
            sta $d00f

            lda #$ff
            sta zp0
            sta zp1
            jsr set_button_colors

            jsr set_button_sprite_frames

            lda #0
            sta $d017       ; y expand off
            sta $d01d       ; x expand off
            sta $d01c       ; multicolor off
            sta $d010       ; msb x position
            lda #255        ; enable
            sta $d015
            rts
.endproc

.proc button_sprites_1
            ldy #7
:           lda button_sprite_pointer, y
            sta sprite_pointers, y
            lda button_color, y
            sta $d027, y
            dey
            bpl :-

            lda #button_sprites_top
            sta $d001
            sta $d003
            sta $d005
            sta $d007

            lda #button_sprites_top + button_sprites_vertical_spacing
            sta $d009
            sta $d00b
            sta $d00d
            sta $d00f

            rts
.endproc

.proc button_sprites_2
            .repeat 4, i
                lda button_sprite_pointer + 8 + i
                sta sprite_pointers + i
                lda button_color + 8 + i
                sta $d027 + i
            .endrepeat

            lda #button_sprites_top + 2 * button_sprites_vertical_spacing
            sta $d001
            sta $d003
            sta $d005
            sta $d007

            rts
.endproc

.proc button_sprites_3
            .repeat 4, i
                lda button_sprite_pointer + 12 + i
                sta sprite_pointers + 4 + i
                lda button_color + 12 + i
                sta $d027 + 4 + i
            .endrepeat

            lda #button_sprites_top + 3 * button_sprites_vertical_spacing
            sta $d009
            sta $d00b
            sta $d00d
            sta $d00f
            jmp update_timers
.endproc

.proc set_button_sprite_frames
            ldy #15
@loop:
            ldx chip8_key_port_a, y
            lda kbd_col0, x
            and chip8_key_port_b, y
            beq @not_pressed
            lda button_down_frame, y
            bne @next
@not_pressed:
            lda button_up_frame, y
@next:      sta button_sprite_pointer, y
            dey
            bpl @loop
            rts
.endproc

; zp0 - buttons 0..7 enabled
; zp1 - buttons 8..F enabled
.proc set_button_colors
            ldy #0
@loop1:     lsr zp0
            bcc @off1
            lda #enabled_button_color
            .byte $2c  ; BIT
@off1:      lda #disabled_button_color
            sta button_color, y
            iny
            cpy #8
            bne @loop1
@loop2:     lsr zp1
            bcc @off2
            lda #enabled_button_color
            .byte $2c  ; BIT
@off2:      lda #disabled_button_color
            sta button_color, y
            iny
            cpy #16
            bne @loop2
            rts
.endproc

.bss
button_sprite_pointer:
            .res 16

button_color:
            .res 16

.rodata
cs_to_sprite:
            .byte 0, 3, 6, 9, 12, 15, 18, 21
            .byte 1, 4, 7, 10, 13, 16, 19, 22

button_up_frame:
            .byte $80, $81, $82, $83, $84, $85, $86, $87
            .byte $88, $89, $8a, $8b, $8c, $8d, $8e, $8f
            
button_down_frame:
            .byte $90, $91, $92, $93, $94, $95, $96, $97
            .byte $98, $99, $9a, $9b, $9c, $9d, $9e, $9f

buttons_sprite_data:
           .incbin "data/buttons.bin", 0, $0400
