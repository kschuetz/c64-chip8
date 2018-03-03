.include "common.s"

.exportzp irq_zp0
.exportzp irq_zp1
.exportzp irq_zp2
.exportzp irq_zp3
.exportzp irq_zp4
.exportzp irq_zp5
.exportzp irq_zp6
.exportzp irq_zp7
.exportzp zp0
.exportzp zp1
.exportzp zp2
.exportzp zp3
.exportzp zp4
.exportzp zp5
.exportzp zp6
.exportzp zp7

.zeropage

;; zp0..7:  Temporary utility registers in zeropage.  Do not use in routines called by IRQ handlers.

zp0:	    .res 1
zp1:	    .res 1
zp2:	    .res 1
zp3:	    .res 1
zp4:	    .res 1
zp5:	    .res 1
zp6:	    .res 1
zp7:	    .res 1

;; irq_zp0..7:  Temporary utility registers in zeropage.  Only use in routines called by IRQ handlers.

irq_zp0:	.res 1
irq_zp1:	.res 1
irq_zp2:	.res 1
irq_zp3:	.res 1
irq_zp4:	.res 1
irq_zp5:	.res 1
irq_zp6:	.res 1
irq_zp7:	.res 1
