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
program_start = guest_ram + $0200               ; location where ROMs are loaded and execution starts
host_screen = $f800
screen_charset = $e800
chrome_charset = $f000
buttons_sprite_set = $e000
sprite_pointers = host_screen + 1016

guest_screen_origin = host_screen + 40 * guest_screen_offset_y + guest_screen_offset_x

guest_screen_color_origin = COLOR_RAM + 40 * guest_screen_offset_y + guest_screen_offset_x

chrome_origin = host_screen + 40 * (guest_screen_offset_y + guest_screen_physical_height + 1)
chrome_color_origin = COLOR_RAM + 40 * (guest_screen_offset_y + guest_screen_physical_height + 1)

.proc clear_ram
            store16 zp0, guest_ram
            ldy #$ff
            ldx #$0f
            lda #0
            jmp fill
.endproc

.segment "HIGH"

; The stack contains 256 levels and grows upwards.
; This is much more than the 16 levels CHIP-8 calls for, but removes the need to validate the stack pointer,
; while adding some safety from rogue programs.

stack_low:  .res 256    ; low bytes of return addresses
stack_high: .res 256    ; high bytes of return addresses
