.export setup_irq, exit_irq
.import host_screen, screen_charset, chrome_charset, check_keyboard, get_guest_keypress, keyboard_debug
.import update_timers
.import check_ui_keys, set_ui_action
.importzp screen_bgcolor, ui_key_events, ui_action

.include "common.s"

.enum services
    top
    chip8_top
    chip8_end
    timer_only
.endenum

.zeropage
raster_index: .res 1

.rodata

next_raster_index:
			.byte 1, 2, 3, 4, 5, 0
next_raster_line:
			.byte 50        ; start of chip8 screen
			.byte 64        ; timer update
			.byte 128       ; timer update
			.byte 178       ; end of chip8 screen
			.byte 200       ; timer update
			.byte 0         ; top of screen.  includes timer update
			
irq_service:
			.byte services::top
			.byte services::chip8_top
			.byte services::timer_only
			.byte services::timer_only
			.byte services::chip8_end
			.byte services::timer_only
.code


.proc setup_irq
			sei
			ldy #0
			sty raster_index
			lda #<irq1
			ldx #>irq1
			sta IRQ_VECTOR
			stx IRQ_VECTOR + 1
			lda $d011
			and #$7f
			sta $d011
			lda #0
			sta $d012
			lda #1
			sta $d01a
			lda #$7f
			sta $dc0d
			cli
			rts
.endproc

.proc irq1
			pha
			txa
			pha
			tya
			pha

			asl $d019
			cli
			cld
			
			ldx raster_index
			lda next_raster_line, x
			sta $d012

			ldy next_raster_index, x
			sty raster_index
			
			lda irq_service, x
			
			beq top_irq
			cmp #2
			beq screen_end_irq
			cmp #1
			beq screen_top_irq
			jmp update_timers
.endproc

.proc top_irq
			lda #chrome_bgcolor
			sta $d020
			lda screen_bgcolor
			sta $d021
			jmp update_timers
.endproc

.proc screen_top_irq
			switch_vic_mem host_screen, screen_charset
			jsr check_keyboard
			jmp exit_irq
.endproc



.proc screen_end_irq
			lda #chrome_bgcolor
			sta $d020
			sta $d021
			switch_vic_mem host_screen, chrome_charset

			; temp
			jsr keyboard_debug

			jsr check_ui_keys
			jsr set_ui_action
.endproc

.proc exit_irq
			pla
			tay
			pla
			tax
			pla
			rti
.endproc


