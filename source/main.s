	
.include "common.s"

.importzp arg_move_to, arg_move_from, arg_move_size
.import move_up
.import RenderScreenLine, copy_double_buffer
.import program_start
.import build_chip8_screen_charset	
.import initialize, clear_screen, clear_ram
.import build_bundle_index, load_bundled_rom
	
.export bundle_end

	
.segment "LOADADDR"

; BASIC header with a SYS call

__LOADADDR__: .word head	    ; Load address

.segment "EXEHDR"
head:	      .word @next
	      .word 666		    ; Line number
	      .byte $9E,"2061"	    ; SYS 2061
	      .byte $00		    ; End of BASIC line
@next:	      .word 0		    ; BASIC end marker

	      jmp   start

.code

start:
	      jsr   init
	      jsr   inst_irq
	      lda   #65
	      jsr   $ffd2
:	      jmp :-
	
	
					
inst_irq:	
	      sei		    ;install IRQ/raster
	      lda   #<irq
	      ldx   #>irq
	      sta   $314
	      stx   $315
	      lda   #$1b
	      sta   $d011
	      lda   #$01
	      sta   $d01a
	      lda   #$7f
	      sta   $dc0d
	      cli
			
	      rts
		
.proc irq

	      lda   #$01
	      sta   $d019
	      lda   #$3c
	      sta   $d012
	      
	      lda   $d020
	      pha
	      lda   #0
	      sta   $d020
	
				;	jsr RenderScreenLine
	      jsr   copy_double_buffer
	      
	      pla
	      sta   $d020
	      
	      jmp   $ea31
.endproc

.proc init
	
			lda $1		    ; switch out BASIC ROM
			and #$fe
			sta $1
			jsr build_bundle_index
			
			jsr clear_ram
			ldy #7	; load space invaders for now
			jsr load_bundled_rom

			jsr build_chip8_screen_charset
			jsr initialize

			rts
    
.endproc

.segment "BUNDLEEND"
bundle_end:	
	      .word 0
	      
	      