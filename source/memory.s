.include "common.s"

.export clear_ram

.import fill
.import guest_ram
.importzp zp0

.proc clear_ram
			istore zp0, guest_ram
			ldy #$ff
			ldx #$0f
			lda #0
			jmp fill
.endproc
