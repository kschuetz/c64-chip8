.importzp zp0, zp1
.import physical_screen
	.export RenderScreenLine
	.export copy_double_buffer
	
logical0 = $9000
logical1 = $9008
scrn = $0400

.zeropage

log0:	.res 1
log1:	.res 1
tmp:	.res 1
	
.code

	;; RenderScreenLine is too slow; it takes about 24 raster lines for every physical row
	
.proc RenderScreenLine
	ldx #0	
loop:
	txa
	stx zp0
	asl a
	asl a
	sta zp1
	
	lda logical0, x
	sta log0
	and #192
	sta tmp
	lda logical1, x
	sta log1
	lsr a
	lsr a
	and #48
	ora tmp
	ldx zp1
	sta scrn, x

	lda log0
	asl a
	asl a
	and #192
	sta tmp
	lda log1
	and #48
	ora tmp
	sta scrn + 1, x

	lda log0
	asl a
	asl a
	asl a
	asl a
	and #192
	sta tmp
	lda log1
	asl a
	asl a
	and #48
	ora tmp
	sta scrn + 2, x

	lda log0
	asl a
	asl a
	asl a
	asl a
	asl a
	asl a
	and #192
	sta tmp
	lda log1
	asl a
	asl a
	asl a
	asl a
	and #48
	ora tmp
	sta scrn + 3, x

	ldx zp0
	inx
	cpx #8
	bne loop

	rts
.endproc


double_buffer = $c000
screen_xoffset = 4
screen_yoffset = 0
screen_width = 32
screen_height = 16
screen_base = physical_screen + 40 * screen_height + screen_xoffset
	
.proc copy_double_buffer
	
	ldy #screen_width
@loop:
	.repeat 8, i
		lda double_buffer + i * screen_width, y
		sta screen_base + i * 40, y
	.endrep
	dey
	bpl @loop
	rts
	
.endproc
