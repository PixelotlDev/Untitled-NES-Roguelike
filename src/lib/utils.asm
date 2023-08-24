; commonly used procedures library

.segment "CODE"

; MACROS START

; clear out all the ram - used in reset.asm
.macro clear_ram
  	lda #0
  	ldx #0
  	clear_ram_loop:
    		sta $0000, X
    		sta $0100, X
    		sta $0200, X
    		sta $0300, X
    		sta $0400, X
    		sta $0500, X
    		sta $0600, X
    		sta $0700, X
    		inx
    		bne clear_ram_loop
.endmacro

; store addr, shift right to fill the carry with what should be wrapped around, load player_pos_real again, then rotate through, giving us an 8-bit rotate
; load addr into accumulator on first rotate
.macro rotate_memory_right addr
    sta addr
    lsr
    lda addr
    ror
.endmacro

.macro set_flags addr, flags
	lda addr
	ora flags
	sta addr
.endmacro

.macro clear_flags addr, flags
	lda flags
	eor #%11111111 ; invert flags
	and addr ; and with addr flags, turning off any flags that were selected and leaving other flags untouched
	sta addr
.endmacro

; MACROS END

; PROCEDURES START

; this procedure will loop until the next vblank
.proc wait_for_vblank
  	bit PPU_STATUS      ; $2002
        vblank_wait:
    		bit PPU_STATUS  ; $2002
    		bpl vblank_wait

        rts
.endproc

; simulated jsr to a location specified in code
; set jsr_indirect_address before using
.proc jsr_indirect
    ; we perform some magic and trick the processor into thinking we came from the place we want to go "back" to
    lda jsr_indirect_address
    pha
    lda jsr_indirect_address+1
    pha
    rts
.endproc

; PROCEDURES END
