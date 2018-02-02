.exportzp reg_v, reg_pc, reg_i, reg_sp
.exportzp zp0, zp1, zp2, zp3, zp4, zp5, zp6, zp7
.export ram, stack_low, stack_high, program_start
.exportzp ram_page
.export physical_screen, chip8_screen_charset		
	
.include "common.s"

ram = $c000
ram_page = >ram
program_start = ram + $0200
stack_low = $af00		; low bytes of return addresses
stack_high = $ae00	        ; high bytes of return addresses
physical_screen = $b000
chip8_screen_charset = $b400	

.zeropage

zp0:	.res 1
zp1:	.res 1
zp2:	.res 1
zp3:	.res 1
	 
zp4:	.res 1			
zp5:	.res 1
zp6:	.res 1
zp7:	.res 1

reg_v:	.res 16
reg_pc:	.res 2
reg_i:	.res 2
reg_sp:	.res 1


	
	
	
	
	


	



	
	
