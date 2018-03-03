.include "common.s"

.export start

.import initialize
.import main_loop
.import setup_irq
	
.segment "LOADADDR"

;; BASIC header with a SYS call

__LOADADDR__: .word head	    ; Load address

.segment "EXEHDR"

head:	    .word @next
			.word 2018		    ; Line number
			.byte $9e, "2061"	; SYS 2061
			.byte 0		        ; End of BASIC line
@next:	    .word 0		        ; BASIC end marker
	      	jmp start

.code

.proc start
			jsr initialize
			jsr setup_irq
			jmp main_loop
.endproc
