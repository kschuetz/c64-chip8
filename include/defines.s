;; Using = where possible; using .define where ca65 complains

.ifndef DEFINES_S

.define DEFINES_S 1

.include "c64.inc"

; ************** not configurable *************

.define guest_screen_physical_width 32
.define guest_screen_physical_height 16
.define guest_screen_offset_x 4
.define guest_screen_offset_y 0
.define chrome_height 8
vic_bank_base = $c000

; ************** configurable ****************

.define title_length 16
.define max_bundled_roms 100

default_rom_index = 0
default_pixel_style_index = 0

chrome_bgcolor = BLACK
default_screen_bgcolor = PURPLE
default_screen_fgcolor = LIGHT_GREEN
enabled_button_color = WHITE
disabled_button_color = DARK_GRAY
paused_indicator_color = YELLOW
indicator_on_color = GREEN
indicator_off_color = RED
pixel_style_indicator_color = LIGHT_GREEN
chrome_ui_key_color = LIGHT_GRAY
chrome_text_color = WHITE

key_delay_frame_count = 18          ; ~ 1/3 second

.endif
