.exportzp zp0, zp1, zp2, zp3, zp4, zp5, zp6, zp7
.exportzp irq_zp0, irq_zp1, irq_zp2, irq_zp3, irq_zp4, irq_zp5, irq_zp6, irq_zp7
		
.include "common.s"

.zeropage

zp0:	    .res 1
zp1:	    .res 1
zp2:	    .res 1
zp3:	    .res 1
	 
zp4:	    .res 1
zp5:	    .res 1
zp6:	    .res 1
zp7:	    .res 1

irq_zp0:	.res 1
irq_zp1:	.res 1
irq_zp2:	.res 1
irq_zp3:	.res 1
irq_zp4:	.res 1
irq_zp5:	.res 1
irq_zp6:	.res 1
irq_zp7:	.res 1
