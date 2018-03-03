.include "common.s"

.export reset

.import active_bundle
.import clear_ram
.import clear_registers
.import clear_screen
.import default_keymap
.import display_rom_title
.import load_bundled_rom
.import load_font_set
.import sync_key_delay_indicator
.import sync_paused_indicator
.import test_draw
.importzp active_keymap
.importzp paused

;; Loads a ROM and resets the guest machine state.
;; Once this is called, code and data in the INITCODE and INITDATA segments are no longer usable.
;;
;; A - index of ROM to load
.proc reset
            pha
            jsr clear_ram
            jsr load_font_set
            jsr clear_screen
            lda #0
            sta paused

            pla
            tay
            jsr load_bundled_rom
            lda active_bundle
            jsr display_rom_title
            jsr sync_key_delay_indicator
            jsr sync_paused_indicator

            jmp clear_registers
.endproc
