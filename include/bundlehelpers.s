.macpack cbm

.macro rom_title title
            scrcode title
            .if (.strlen(title) > title_length)
                .error "Title too long"
            .endif
            .repeat (title_length - .strlen(title))
                .byte 0
            .endrep
.endmacro

.macro bundle filename, title, enabled_key_mask, keymap_addr, key_delay_enabled
            .local @end
            .word @end
            rom_title title
            .ifnblank enabled_key_mask
                .word enabled_key_mask
            .else
                .word $ffff ; all keys enabled
            .endif
            .ifnblank keymap_addr
                .addr keymap_addr
            .else
                .addr default_keymap
            .endif
            .ifblank key_delay_enabled
                .byte true
            .else
                .byte key_delay_enabled
            .endif

            .incbin filename
@end:
.endmacro
