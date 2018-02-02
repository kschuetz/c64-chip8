.include "c64.inc"

.macro istore m, value
	lda #<value
	sta m
	lda #>value
	sta m + 1
.endmacro
