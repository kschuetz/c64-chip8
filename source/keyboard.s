.export check_keyboard, is_chip8_key_pressed, get_chip8_keypress, init_keyboard, check_ui_keys
.exportzp ui_key_events

.import debug_output_hex


.zeropage
kbd_col0:		.res 1
kbd_col1:		.res 1
kbd_col2:		.res 1
kbd_col3:		.res 1
kbd_col4:		.res 1
kbd_col5:		.res 1
kbd_col6:		.res 1
kbd_col7:		.res 1
kbd_temp:		.res 1

.code

.proc init_keyboard
			lda #0
			sta ui_key_state
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

; A - chip8 key to check
; returns nonzero in A is key is pressed
.proc is_chip8_key_pressed
			and #$0f
			tay 
			ldx chip8_key_port_a, y
			lda kbd_col0, x
			and chip8_key_port_b, y
			rts
.endproc 

; returns pressed key in A, or $ff if no key pressed
.proc get_chip8_keypress
			ldx #0
@loop:		stx kbd_temp
			txa
			jsr is_chip8_key_pressed
			bne @found
			ldx kbd_temp
			inx
			cpx #$10
			bne @loop
			lda #$ff		; not found; return $ff
@found:		rts
.endproc    


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
; 
; Chip8 Key   	C64 Key		Row			Column
; ------------------------------------------
; 0				1			7			0
; 1				2			7			3
; 2				3			1			0
; 3				4			1			3
; 4				Q			7			6
; 5				W			1			1
; 6				E			1			6
; 7				R			2			1
; 8				A			1			2
; 9				S			1			5
; A				D			2			2
; B				F			2			5
; C				Z			1			4
; D				X			2			7
; E				C			2			4
; F				V			3			7

ui_key_port_a:
			.byte 0, 0, 0, 5, 4, 4, 4, 4
			
ui_key_port_b:
			.byte 1 << 4, 1 << 5, 1 << 6, 1 << 1
			.byte 1 << 2, 1 << 5, 1 << 7, 1 << 4

; UI Keys
; Function   	C64 Key		Row			Column
; ------------------------------------------
; 0: Reset			F1			0			4
; 1: Load Next		F3			0			5
; 2: Load Prev		F5			0		    6
; 3: Pause			P			5			1
; 4: BGColor -		J			4			2
; 5: BGColor +		K			4			5
; 6: FGColor -		N			4			7
; 7: FGColor +		M			4			4