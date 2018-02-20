.export guest_ram, stack_low, stack_high, program_start
.exportzp guest_ram_page
.export host_screen, guest_screen_origin, guest_screen_color_origin, sprite_pointers
.export screen_charset, chrome_charset
.export chrome_origin, chrome_color_origin
.export buttons_sprite_set
.exportzp guest_ram_page

.include "common.s"

guest_ram = $c000
guest_ram_page = >guest_ram
program_start = guest_ram + $0200
stack_low = $9f00		    ; low bytes of return addresses
stack_high = $9e00	        ; high bytes of return addresses
host_screen = $b000
screen_charset = $b800	
chrome_charset = $a800
buttons_sprite_set = $a000
sprite_pointers = host_screen + 1016

guest_screen_origin = host_screen + 40 * guest_screen_offset_y + guest_screen_offset_x

guest_screen_color_origin = COLOR_RAM + 40 * guest_screen_offset_y + guest_screen_offset_x

chrome_origin = host_screen + 40 * (guest_screen_offset_y + guest_screen_physical_height + 1)
chrome_color_origin = COLOR_RAM + 40 * (guest_screen_offset_y + guest_screen_physical_height + 1)