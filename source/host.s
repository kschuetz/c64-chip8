.include "common.s"

.export check_host_model
.exportzp host_model

.zeropage

; $01: 262 rasterlines and 64 cycles per line [NTSC: 6567R56A VIC] (OLD NTSC)
; $02: 263 rasterlines and 65 cycles per line [NTSC: 6567R8 VIC]
; $03: 312 rasterlines and 63 cycles per line [PAL: 6569 VIC]
; $04: 312 rasterlines and 65 cycles per line [Drean PAL-N: 6572 VIC]
host_model:         .res 1

.code

;  http://codebase64.org/doku.php?id=base:detect_pal_ntsc
;  (Sokrates' variant)
.proc check_host_model
            ldx #$00
@0:         lda $d012
@1:         cmp $d012
            beq @1
            bmi @0
            and #$03
            cmp #$03
            bne @done ; done for ntsc
            tay
@count_cycles:
            inx
            lda $d012
            bpl @count_cycles
            cpx #$5e  ; vice values: pal-n=$6c pal=$50
                  ; so choose middle value $5e for check
            bcc @is_pal
            iny   ; is pal-n
@is_pal:
            tya
@done:
            sta host_model
            rts
.endproc
