.include "c64.inc"
.include "defines.s"

.macro istore m, value
		lda #<value
		sta m
		lda #>value
		sta m + 1
.endmacro

.macro switch_vic_mem screen, charset
		.local @screen
		.local @charset
		@screen = (screen - vic_bank_base) >> 10	
		@charset = ((charset - vic_bank_base) >> 10)
		
		lda #<((@screen << 4) | (@charset & 14))
		sta VMCSB
.endmacro 

	;; converts high byte of logical RAM (in A) to physical RAM location
.macro map_to_physical
	and #63
	ora #ram_page
.endmacro

.struct BundleNode
	next .addr
	title .byte title_length
	data .byte
.endstruct

.enum UIAction
		none
		reset
		load_next
		load_prev
		pause
		bgcolor_prev
		bgcolor_next
		fgcolor_prev
		fgcolor_next
.endenum


; UI Keys
; Function   	C64 Key		Row			Column
; ------------------------------------------
; 0: Reset			F1			0			4
; 1: Load Next		F3			0			5
; 2: Load Prev		F5			0		    6
; 3: Pause			P			5			1
; 4: BGColor -		J			4			2
; 5: BGColor +		K			4			5
; 6: FGColor -		N			4			7
; 7: FGColor +		M			4			4