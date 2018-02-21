.export check_keyboard, is_guest_key_pressed, get_guest_keypress, init_keyboard, check_ui_keys
.export chip8_key_port_a, chip8_key_port_b
.exportzp ui_key_events, kbd_col0

.import debug_output_hex
.importzp active_keymap

.zeropage
kbd_col0:		.res 1
kbd_col1:		.res 1
kbd_col2:		.res 1
kbd_col3:		.res 1
kbd_col4:		.res 1
kbd_col5:		.res 1
kbd_col6:		.res 1
kbd_col7:		.res 1

.code

.proc init_keyboard
			lda #0
			sta ui_key_state
			ldy #7
@loop:      sta kbd_col0, y
            dey
            bpl @loop
			rts
.endproc

.macro test_column col
			lda #<(~(1 << col))
			sta $dc00
			lda $dc01
			eor #$ff
			sta kbd_col0 + col
.endmacro

.proc check_keyboard
			lda #%11111111  ; CIA#1 port A = outputs 
         	sta $dc02     
         	
         	lda #%00000000  ; CIA#1 port B = inputs
         	sta $dc03	
         	
         	.repeat 8, col
         		test_column col
         	.endrep
         	rts
.endproc   

; A - logical chip8 key to check
; returns nonzero in A is key is pressed
.proc is_guest_key_pressed
			and #$0f
			tay 
			lda (active_keymap), y
			bmi @no                     ; keymap contains $ff, so no key is mapped to this one
			tay
			ldx chip8_key_port_a, y
			lda kbd_col0, x
			and chip8_key_port_b, y
			rts
@no:        lda #0
            rts
.endproc

; returns pressed key in A, or $ff if no key pressed
.proc get_guest_keypress
			ldy #0
@loop:      sty @stash + 1
            lda (active_keymap), y
            bmi @no
            sty @found + 1
            tay
            ldx chip8_key_port_a, y
            lda kbd_col0, x
            and chip8_key_port_b, y
            bne @found                  ; key pressed;  Y contains logical key
@no:
@stash:     ldy #0
            iny
            cpy #16
            bne @loop
@not_found:
            lda #$ff                    ; return $ff if not found
            rts
@found:     lda #0
            rts
.endproc

;; returns pressed key in A, or $ff if no key pressed
;.proc get_guest_keypress
;			ldy #0
;@loop:      ldx chip8_key_port_a, y
;            lda kbd_col0, x
;            and chip8_key_port_b, y
;            bne @found                  ; key pressed;  Y contains logical key
;            iny
;            cpy #16
;            bne @loop
;@not_found:
;            lda #$ff                    ; return $ff if not found
;            rts
;@found:     tya
;            rts
;.endproc

.zeropage
ui_key_state:	    .res 1
ui_key_events:	    .res 1
ui_key_new_state:   .res 1

.code

.proc check_ui_keys
			lda #0
			sta ui_key_new_state
			ldy #7
@loop:		ldx ui_key_port_a, y
			lda kbd_col0, x
			and ui_key_port_b, y
			beq @off
@on:		sec
			rol ui_key_new_state
			bcc @next					; unconditional
@off:		clc
			rol ui_key_new_state
@next:		dey
			bpl @loop
			
			; events = ui_key_new_state & ~ui_key_state
			lda ui_key_state
			eor #$ff
			and ui_key_new_state
			sta ui_key_events
			
			; ui_key_state = ui_key_new_state
			lda ui_key_new_state
			sta ui_key_state

			rts
.endproc

.rodata

; Keyboard tables

; Physical key indices
;
; 0	1 2	3
; 4 5 6 7
; 8 9 A C
; C D E F

; C64 keys
;
; 1 2 3 4
; Q W E R
; A S D F
; Z X C V



; Mapping to CIA Ports A (row) and B (column)
; Key index   	C64 Key		Row			Column
; ------------------------------------------
; 0				1			7			0
; 1				2			7			3
; 2				3			1           0
; 3				4			1           3
; 4				Q			7           6
; 5				W			1           1
; 6				E			1           6
; 7				R			2           1
; 8				A			1           2
; 9				S		    1           5
; A				D		    2           2
; B				F		    2           5
; C				Z			1           4
; D				X			2           7
; E				C			2           4
; F				V			3           7

chip8_key_port_a:
			.byte 7, 7, 1, 1
			.byte 7, 1, 1, 2
			.byte 1, 1, 2, 2
			.byte 1, 2, 2, 3

chip8_key_port_b:
			.byte 1 << 0, 1 << 3, 1 << 0, 1 << 3
			.byte 1 << 6, 1 << 1, 1 << 6, 1 << 1
			.byte 1 << 2, 1 << 5, 1 << 2, 1 << 5
			.byte 1 << 4, 1 << 7, 1 << 4, 1 << 7

; UI Keys
; Function   	    C64 Key		Row			Column
; ------------------------------------------
; 0: Reset			F1			0			4
; 1: Load Prev		F3			0			5
; 2: Load Next		F5			0		    6
; 3: Pause			P			5			1
; 4: BGColor 		K			4			5
; 5: FGColor 		J           4           2
; 6: Pixel Style    M           4           4
; 7: Toggle sound   O           4           6

ui_key_port_a:
			.byte 0, 0, 0, 5, 4, 4, 4, 4
			
ui_key_port_b:
			.byte 1 << 4, 1 << 5, 1 << 6, 1 << 1
			.byte 1 << 5, 1 << 2, 1 << 4, 1 << 6
