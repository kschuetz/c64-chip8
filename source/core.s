;; Contains the main loop that handles user actions and repeatedly calls the CPU to execute instructions.

.include "common.s"

.export init_core
.export main_loop
.export set_ui_action
.exportzp paused
.exportzp ui_action

.import active_bundle
.import bundle_count
.import cycle_pixel_style
.import exec
.import reset
.import sync_bgcolor_indicator
.import sync_fgcolor_indicator
.import sync_key_delay_indicator
.import sync_paused_indicator
.import sync_pixel_style_indicator
.import sync_sound_indicator
.import update_screen_color
.importzp frame_counter
.importzp key_delay_mode
.importzp screen_bgcolor
.importzp screen_fgcolor
.importzp sound_enabled
.importzp ui_key_events

.zeropage

ui_action:			.res 1
paused:             .res 1
ui_action_last_frame:
                    .res 1

.segment "INITCODE"

.proc init_core
			lda #0
			sta ui_action
			sta paused
			lda #$ff

			rts	
.endproc

.code

.proc main_loop
			nop
			nop
			nop
			; do not check ui actions more than once per frame
			lda frame_counter
			cmp ui_action_last_frame
			beq @ui_work_done
			sta ui_action_last_frame
			
			ldy #UIAction::none
			lda ui_action
			beq @ui_work_done
			sty ui_action
			asl a
			tay
			lda action_handlers, y
			sta @action_target + 1
			lda action_handlers + 1, y
			sta @action_target + 2			
@action_target:		
			jsr no_action				; self modified target
			
@ui_work_done:
            lda paused
            bne main_loop

            jsr exec                    ; execute a CPU instruction
			jmp main_loop
.endproc

.proc no_action
			rts
.endproc

.proc handle_bgcolor_next
			lda screen_bgcolor
			clc
			adc #1
			and #15
			sta screen_bgcolor
			cmp screen_fgcolor
			beq handle_bgcolor_next		; if same as fgcolor, increment again
			jmp sync_bgcolor_indicator
.endproc

.proc handle_fgcolor_next
			lda screen_fgcolor
			clc
			adc #1
			and #15
			sta screen_fgcolor
			cmp screen_bgcolor
			beq handle_fgcolor_next		; if same as bgcolor, increment again
            jsr sync_fgcolor_indicator
			jmp update_screen_color
.endproc

.proc handle_load_next
			lda active_bundle
			clc
			adc #01
			cmp bundle_count
			bmi @ok
			lda #0				; wrap around to zero
@ok:		jmp reset
.endproc

.proc handle_load_prev
			lda active_bundle
			sec
			sbc #01
			bpl @ok
			sec
			lda bundle_count
			sbc #01
@ok:		jmp reset
.endproc

.proc handle_reset
			lda active_bundle
			jmp reset
.endproc

.proc handle_pause
            lda paused
            eor #$ff
            sta paused
            jmp sync_paused_indicator
.endproc

.proc handle_toggle_key_repeat
            lda key_delay_mode
            eor #$ff
            sta key_delay_mode
            jmp sync_key_delay_indicator
.endproc

.proc handle_toggle_sound
            lda sound_enabled
            eor #$ff
            sta sound_enabled
            jmp sync_sound_indicator
.endproc

.proc handle_cycle_pixel_style
            jsr cycle_pixel_style
            jmp sync_pixel_style_indicator
.endproc

.proc set_ui_action
			lda ui_key_events
			beq @bit8
			lsr a
			bcc @bit1
@bit0:		lda #UIAction::reset
			bcs @done
@bit1:		lsr a
			bcc @bit2
			lda #UIAction::load_prev
			bcs @done
@bit2:		lsr a
			bcc @bit3
			lda #UIAction::load_next
			bcs @done
@bit3:		lsr a
			bcc @bit4
			lda #UIAction::pause
			bcs @done	
@bit4:		lsr a
			bcc @bit5
			lda #UIAction::bgcolor_next
			bcs @done	
@bit5:		lsr a
			bcc @bit6
			lda #UIAction::fgcolor_next
			bcs @done	
@bit6:		lsr a
			bcc @bit7
			lda #UIAction::pixel_style_next
			bcs @done	
@bit7:		lsr a
			bcc @bit8
			lda #UIAction::toggle_key_repeat
			bcs @done
@bit8:      lda ui_key_events + 1
            lsr a
            bcc @none
            lda #UIAction::toggle_sound
            bcs @done
			
@none:		lda #UIAction::none
@done:		sta ui_action
			rts				 			
.endproc

.rodata

action_handlers:
			.addr no_action 		; none
			.addr handle_reset
			.addr handle_load_prev
			.addr handle_load_next
			.addr handle_pause			
			.addr handle_bgcolor_next
			.addr handle_fgcolor_next
			.addr handle_cycle_pixel_style
			.addr handle_toggle_key_repeat
			.addr handle_toggle_sound
