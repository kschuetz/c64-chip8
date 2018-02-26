.include "common.s"

.export buttons_sprite_set
.export chrome_charset
.export chrome_color_origin
.export chrome_origin
.export clear_ram
.export guest_ram
.export guest_screen_color_origin
.export guest_screen_origin
.export host_screen
.export program_start
.export screen_charset
.export sprite_pointers
.export stack_high
.export stack_low
.exportzp guest_ram_page

.import fill
.importzp zp0

guest_ram = $c000
guest_ram_page = >guest_ram
program_start = guest_ram + $0200
stack_low = $ef00		    ; low bytes of return addresses
stack_high = $ee00	        ; high bytes of return addresses
host_screen = $b000
screen_charset = $b800	
chrome_charset = $a800
buttons_sprite_set = $a000
sprite_pointers = host_screen + 1016

guest_screen_origin = host_screen + 40 * guest_screen_offset_y + guest_screen_offset_x

guest_screen_color_origin = COLOR_RAM + 40 * guest_screen_offset_y + guest_screen_offset_x

chrome_origin = host_screen + 40 * (guest_screen_offset_y + guest_screen_physical_height + 1)
chrome_color_origin = COLOR_RAM + 40 * (guest_screen_offset_y + guest_screen_physical_height + 1)

.proc clear_ram
			istore zp0, guest_ram
			ldy #$ff
			ldx #$0f
			lda #0
			jmp fill
.endproc
