.export main_loop, init_core, set_ui_action
.exportzp ui_action

.import update_screen_color
.importzp screen_bgcolor, screen_fgcolor, ui_key_events

.include "common.s"

.zeropage
ui_action:			.res 0

.code

.proc init_core
			lda #UIAction::none
			sta ui_action
			rts	
.endproc

.proc main_loop
			nop
			nop
			nop
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
			rts
.endproc

.proc handle_bgcolor_prev
			lda screen_bgcolor
			sec
			sbc #1
			and #15
			sta screen_bgcolor
			cmp screen_fgcolor
			beq handle_bgcolor_prev		; if same as fgcolor, decrement again
			rts
.endproc

.proc handle_fgcolor_next
			lda screen_fgcolor
			clc
			adc #1
			and #15
			sta screen_fgcolor
			cmp screen_bgcolor
			beq handle_fgcolor_next		; if same as bgcolor, increment again
			jmp update_screen_color
.endproc

.proc handle_fgcolor_prev
			lda screen_fgcolor
			sec
			sbc #1
			and #15
			sta screen_fgcolor
			cmp screen_bgcolor
			beq handle_fgcolor_prev		; if same as bgcolor, decrement again
			jmp update_screen_color
.endproc

.proc set_ui_action
			lda ui_key_events
			beq @done
			lsr a
			bcc @bit1
@bit0:		lda #UIAction::reset
			bcs @done
@bit1:		lsr a
			bcc @bit2
			lda #UIAction::load_next
			bcs @done
@bit2:		lsr a
			bcc @bit3
			lda #UIAction::load_prev
			bcs @done
@bit3:		lsr a
			bcc @bit4
			lda #UIAction::pause
			bcs @done	
@bit4:		lsr a
			bcc @bit5
			lda #UIAction::bgcolor_prev
			bcs @done	
@bit5:		lsr a
			bcc @bit6
			lda #UIAction::bgcolor_next
			bcs @done	
@bit6:		lsr a
			bcc @bit7
			lda #UIAction::fgcolor_prev
			bcs @done	
@bit7:		lsr a
			bcc @none
			lda #UIAction::fgcolor_next
			bcs @done
			
@none:		lda #UIAction::none
@done:		sta ui_action
			rts				 			
.endproc


.rodata 
action_handlers:
			.addr no_action 		; none
			.addr no_action			; reset
			.addr no_action			; load_next
			.addr no_action			; load_prev
			.addr no_action			; pause
			.addr handle_bgcolor_prev
			.addr handle_bgcolor_next
			.addr handle_fgcolor_prev	
			.addr handle_fgcolor_next	