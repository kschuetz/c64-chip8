.export clear_ram

.import guest_ram, fill
.importzp zp0, zp1

.include "common.s"

.proc clear_ram
			istore zp0, guest_ram
			ldy #$ff
			ldx #$0f
			lda #0
			jmp fill
.endproc

