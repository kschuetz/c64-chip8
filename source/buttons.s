.export init_buttons, button_sprite_pointer, set_button_sprite_frames, init_button_sprites
.import buttons_sprite_set, fill, chip8_key_port_a, chip8_key_port_b
.importzp zp0, zp2, kbd_col0

.include "common.s"

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

; call once before setup_irq
.proc init_button_sprites
            lda #32
            sta $d000
            sta $d008
            lda #48
            sta $d002
            sta $d00a
            lda #64
            sta $d004
            sta $d00c
            lda #80
            sta $d006
            sta $d00e

            lda #204
            sta $d001
            sta $d003
            sta $d005
            sta $d007

            lda #220
            sta $d009
            sta $d00b
            sta $d00d
            sta $d00f

            lda #1          ; color
            .repeat 8, i
               sta $d027 + i
            .endrepeat

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

.bss
button_sprite_pointer:
            .res 16

.rodata
cs_to_sprite:
            .byte 0, 3, 6, 9, 12, 15, 18, 21
            .byte 1, 4, 7, 10, 13, 16, 19, 22

button_down_frame:
            .byte $80, $81, $82, $83, $84, $85, $86, $87
            .byte $88, $89, $8a, $8b, $8c, $8d, $8e, $8f
            
button_up_frame:
            .byte $90, $91, $92, $93, $94, $95, $96, $97
            .byte $98, $99, $9a, $9b, $9c, $9d, $9e, $9f

buttons_sprite_data:
           .incbin "data/buttons.bin", 0, $0400
