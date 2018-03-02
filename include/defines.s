.ifndef DEFINES_S

.define DEFINES_S 1

; ************** not configurable *************
.define guest_screen_physical_width 32
.define guest_screen_physical_height 16
.define guest_screen_offset_x 4
.define guest_screen_offset_y 0
.define chrome_height 8
vic_bank_base = $c000

; ************** configurable ****************

.define default_rom_index 49
.define title_length 16

.define max_bundled_roms 100

.define chrome_bgcolor 0

default_pixel_style_index = 0
default_screen_bgcolor = 4
default_screen_fgcolor = 13

enabled_button_color = 1
disabled_button_color = 11

key_delay_frame_count = 18

.endif
