;.export init_pixel_styles, next_pixel_frame
;
;.import load_pixel_set, load_partial_pixel_set
;
;.zeropage
;
;active_style:
;            .res 1
;
;current_frame:
;            .res 2
;
;current_char_index:
;            .res 1
;
;.bss
;active_pixel_set:
;            .res 1
;
;.code
;
;.proc init_pixel_styles
;            lda #15
;            sta current_char_index
;            ldy #4
;            sty active_style
;            lda pixel_styles_low, y
;            sta current_frame
;            lda pixel_styles_high, y
;            sta current_frame + 1
;            lda #$ff
;            sta active_pixel_set
;            ; fall through to next_pixel_frame
;.endproc
;
;.proc next_pixel_frame
;            inc $d020
;            ldy #0
;            lda (current_frame), y
;            sta active_pixel_set
;            ldx current_char_index
;            jsr load_partial_pixel_set
;            dec current_char_index
;            bpl @done
;@update_frame:
;            lda #15
;            sta current_char_index
;            ldy #1
;            lda (current_frame), y
;            tax
;            iny
;            lda (current_frame), y
;            stx current_frame
;            sta current_frame + 1
;@done:      dec $d020
;            rts
;.endproc
;
;.proc next_pixel_frame_old
;            inc $d020
;            ldy #0
;            lda (current_frame), y
;            cmp active_pixel_set
;            beq @no_change
;            tay
;            sta active_pixel_set
;            jsr load_pixel_set
;@no_change:
;            ldy #1
;            lda (current_frame), y
;            tax
;            iny
;            lda (current_frame), y
;            stx current_frame
;            sta current_frame + 1
;            dec $d020
;            rts
;.endproc
;
;.proc activate_pixel_style
;.endproc
;
;.rodata
;
;; a frame is 3 bytes:  1 byte for pixel_set index, 2 bytes for next frame address
;
;.macro frame n, jump_to
;    .if .paramcount < 2
;        .local @next
;        .byte n
;        .addr @next
;    @next:
;    .else
;        .byte n
;        .addr jump_to
;    .endif
;.endmacro
;
;
;
;pixel_style0:
;            frame 0, pixel_style0
;
;pixel_style1:
;            frame 1, pixel_style1
;
;pixel_style2:
;            frame 2, pixel_style2
;
;pixel_style3:
;            frame 3, pixel_style3
;
;pixel_style4:
;            frame 4
;            frame 5
;            frame 6
;            frame 7, pixel_style4
;
;
;.define all_styles pixel_style0, pixel_style1, pixel_style2, pixel_style3, pixel_style4
;
;pixel_styles_low:
;        .lobytes all_styles
;
;pixel_styles_high:
;        .hibytes all_styles
;