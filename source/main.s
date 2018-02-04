	
.include "common.s"

.export start, bundle_end
.import initialize, setup_irq
	
.segment "LOADADDR"

; BASIC header with a SYS call

__LOADADDR__: .word head	    ; Load address

.segment "EXEHDR"
head:	    .word @next
			.word 666		    ; Line number
			.byte $9E,"2061"	    ; SYS 2061
			.byte $00		    ; End of BASIC line
@next:	    .word 0		    ; BASIC end marker
	      	jmp   start

.code

.proc start
			jsr   initialize
			jsr   setup_irq
:			jmp :-
.endproc

.segment "BUNDLEEND"
bundle_end:	
	      .word 0
	      
