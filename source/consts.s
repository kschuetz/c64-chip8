.export ram, stack_low, stack_high, program_start
.exportzp ram_page
.export physical_screen, chip8_screen_origin, chip8_screen_color_origin
.export screen_charset, chrome_charset
.export chrome_origin, chrome_color_origin
.exportzp ram_page

.include "common.s"

ram = $c000
ram_page = >ram
program_start = ram + $0200
stack_low = $a700		    ; low bytes of return addresses
stack_high = $a600	        ; high bytes of return addresses
physical_screen = $b000
screen_charset = $b800	
chrome_charset = $a800

chip8_screen_origin = physical_screen + 40 * chip8_screen_offset_y + chip8_screen_offset_x

chip8_screen_color_origin = COLOR_RAM + 40 * chip8_screen_offset_y + chip8_screen_offset_x

chrome_origin = physical_screen + 40 * (chip8_screen_offset_y + chip8_screen_physical_height + 1)
chrome_color_origin = COLOR_RAM + 40 * (chip8_screen_offset_y + chip8_screen_physical_height + 1)