.include "common.s"

.export check_keyboard
.export check_ui_keys
.export chip8_key_port_a
.export chip8_key_port_b
.export get_guest_keypress
.export init_keyboard
.export is_guest_key_pressed
.exportzp kbd_col0
.exportzp key_delay_mode
.exportzp ui_key_events

.import debug_output_hex
.importzp active_keymap
.importzp irq_zp0

.zeropage

kbd_col0:		    .res 16
key_delay_mode:     .res 1

.segment "LOW"

key_states:         .res 16
key_delay_timer:    .res 16

.code

.enum KeyState
            up = 0
            down = 1
            waiting_for_delay = 2
            delay_expired = 3
.endenum

;; key states (in key delay mode):
;; -------------------------------
;;
;; 0: up.  Transitions to 1 when key is down.
;; 1: down.  Yields true on first query, then immediayely transitions to state 2.
;; 2: waiting for delay.  Yields false for queries.  Transitions to 3 when delay timer expires.
;; 3. delay expired.  Always yields true.
;;
;; If key_delay_mode is off, all states except 0 yield true.

.proc init_keyboard
            lda #true
            sta key_delay_mode
.endproc

.proc reset_keyboard
			lda #0
			sta ui_key_state
			sta ui_key_state + 1
			ldy #7
@loop:      sta kbd_col0, y
            sta key_states, y
            sta key_states + 8, y
            sta key_delay_timer, y
            sta key_delay_timer + 8, y
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
            ; continue to update_key_states
.endproc

.proc update_key_states
         	ldy #15
@loop:     	sty irq_zp0
         	lda (active_keymap), y
         	bmi @up                 ; keymap contains $ff, so no key is mapped to this one
         	tay
         	ldx chip8_key_port_a, y
            lda kbd_col0, x
            and chip8_key_port_b, y
            beq @up
@down:      ldy irq_zp0
            lda key_states, y
            bne @already_down       ; key is already down, or event has been fired
            lda #KeyState::down
            sta key_states, y
            bne @next_key           ; unconditional
@already_down:
            cmp #KeyState::waiting_for_delay
            bne @next_key
            tya
            tax
            dec key_delay_timer, x
            bpl @next_key           ; delay hasn't run out

@delay_expired:
            lda #KeyState::delay_expired
            sta key_states, y
            bne @next_key           ; unconditional

@up:        ldy irq_zp0
            lda #0
            sta key_states, y
@next_key:  dey
            bpl @loop

         	rts
.endproc


; A - logical chip8 key to check
; Returns:  Z = 0: key pressed
;           Z = 1: key not pressed
.proc is_guest_key_pressed
			ldy key_delay_mode
			bne is_guest_key_pressed_delay_mode
			; continue to is_guest_key_pressed_repeat_mode
.endproc

.proc is_guest_key_pressed_repeat_mode
            and #$0f
            tay
            lda key_states, y
            rts
.endproc

.proc is_guest_key_pressed_delay_mode
            and #$0f
            tay
            lda key_states, y
            bne @down
            rts             ; a = 0
@down:      cmp #KeyState::down
            beq @transition_to_delay
            cmp #KeyState::delay_expired
            bne @no
@delay_expired:
            lda #true
            rts             
@transition_to_delay:
            lda #key_delay_frame_count - 1
            sta key_delay_timer, y
            lda #KeyState::waiting_for_delay
            sta key_states, y
                            ; state was 1, return true (a = 2)
            rts
@no:        lda #0          ; state was 2, return false (a = 0)
            rts
.endproc

; returns pressed key in A, or $ff if no key pressed
.proc get_guest_keypress
			ldy key_delay_mode
            bne get_guest_keypress_delay_mode
            ; continue to get_guest_keypress_repeat_mode
.endproc

.proc get_guest_keypress_repeat_mode
            ldy #0
@loop:      lda key_states, y
            beq @next_key
            ;found
            tya
            rts
@next_key:  iny
            cpy #16
            bne @loop
            lda #$ff        ; nothing found
            rts
.endproc

.proc get_guest_keypress_delay_mode
            ldy #0
@loop:      lda key_states, y
            beq @next_key
            cmp #KeyState::down
            beq @found
            cmp #KeyState::delay_expired
            bne @next_key   ; key is either not down, or waiting for delay
            tya             ; state is delay_expired, so return true
            rts
@found:     lda #2          ; event fired state
            sta key_states, y
            lda #key_delay_frame_count - 1
            sta key_delay_timer, y
            tya
            rts
@next_key:  iny
            cpy #16
            bne @loop
            lda #$ff        ; nothing found
            rts
.endproc

.zeropage

ui_key_state:	    .res 2
ui_key_events:	    .res 2
ui_key_new_state:   .res 2

.code

;; sets ui_key_events
;; ui_key_events:       bits 0..7 are events 0..7,
;; ui_key_events + 1:   bit 0 is event 8
.proc check_ui_keys
			lda #0
			sta ui_key_new_state

			; events 0..7
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

		    ; event 8
		    ldx ui_key_port_a + 8
		    lda kbd_col0, x
            and ui_key_port_b, y
            beq :+
            lda #1
            .byte $2c  ; BIT instruction
:           lda #0
            sta ui_key_new_state + 1

			; events = ui_key_new_state & ~ui_key_state
			lda ui_key_state
			eor #$ff
			and ui_key_new_state
			sta ui_key_events

			lda ui_key_state + 1
            eor #$ff
            and ui_key_new_state + 1
            sta ui_key_events + 1

			; ui_key_state = ui_key_new_state
			lda ui_key_new_state
			sta ui_key_state
			lda ui_key_new_state + 1
            sta ui_key_state + 1

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
; 3: Pause			F7			0			3
; 4: BGColor 		N           4           7
; 5: FGColor 		M           4           4
; 6: Pixel Style    P           5           1
; 7: Key Delay      K           4           5
; 8: Toggle Sound   U           3           6

ui_key_port_a:
			.byte 0, 0, 0, 0, 4, 4, 5, 4, 3

ui_key_port_b:
			.byte 1 << 4, 1 << 5, 1 << 6, 1 << 3
			.byte 1 << 7, 1 << 4, 1 << 1, 1 << 5, 1 << 6
