.export ram, program_start, stack_low, stack_high, physical_screen, chip8_screen_charset, chip8_physical_screen_origin
.exportzp ram_page

.include "defines.s"

ram = $c000
ram_page = >ram
program_start = ram + $0200
stack_low = $af00		; low bytes of return addresses
stack_high = $ae00	        ; high bytes of return addresses
physical_screen = $b000
chip8_screen_charset = $b800	
chip8_physical_screen_origin = physical_screen + 40 * chip8_screen_offset_y + chip8_screen_offset_x
