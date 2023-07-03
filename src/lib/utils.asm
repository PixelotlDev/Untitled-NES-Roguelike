.segment "CODE"

; this procedure will loop until the next vblank
.proc wait_for_vblank
  	bit PPU_STATUS      ; $2002
        vblank_wait:
    		bit PPU_STATUS  ; $2002
    		bpl vblank_wait

        rts
.endproc

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

; copies everything from whatever is loaded from scene_data onwards to ppu memory
; clobbers x ($00) and y ($c0)
.proc load_initial_scene_tiles
    ; bytes 0-255
    ldy #$20
    ldx #$00

    lda PPU_STATUS        ; PPU_STATUS = $2002

    sty PPU_ADDR          ; High byte
    stx PPU_ADDR          ; Low byte

    ldy #$0

    load_initial_scene_tiles_loop_1:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        bne load_initial_scene_tiles_loop_1

    inc scene_tiles_address+1

    load_initial_scene_tiles_loop_2:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        bne load_initial_scene_tiles_loop_2

    inc scene_tiles_address+1

    load_initial_scene_tiles_loop_3:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        bne load_initial_scene_tiles_loop_3
    
    inc scene_tiles_address+1

    ; the final loop has a few less bytes to load
    load_initial_scene_tiles_loop_4:
        lda (scene_tiles_address), y
        sta PPU_DATA

        iny
        cpy #$c0
        bne load_initial_scene_tiles_loop_4
    rts
.endproc

; like load_initial_scene_tiles, but for the attribute table - much shorter, cos there's a lot less data to transfer
.proc load_initial_scene_attribute
    lda PPU_STATUS        ; PPU_STATUS = $2002

    lda #$23
    sta PPU_ADDR          ; High byte
    lda #$c0
    sta PPU_ADDR          ; Low byte

    ldy #$00

    attribute_loop_1:
        lda (scene_attribute_address), y
        sta PPU_DATA

        iny
        cpy #$40
        bne attribute_loop_1
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

.proc button_logic
    lda gamepad_new_press
    and #%01000000      ; if left button is being pressed...
    bne left_press      ; do stuff at the left_press label
left_done:
    lda gamepad_new_press
    and #%10000000      ; above, but right
    bne right_press
right_done:
    lda gamepad_new_press
    and #%00010000      ; above, but up
    bne up_press
up_done:
    lda gamepad_new_press
    and #%00100000      ; above, but down
    bne down_press
down_done:
    lda gamepad_new_press
    and #%00000001      ; above, but a
    bne a_press
a_done:
    lda gamepad_new_press
    and #%00000010      ; above, but b
    bne b_press
b_done:
    rts                 ; if nothing's being pressed, go back to the program

left_press:
    ; button logic goes here
    jmp left_done

right_press:
    ; button logic goes here
    jmp right_done

up_press:
    ; button logic goes here
    jmp up_done

down_press:
    ; button logic goes here
    jmp down_done

a_press:
    ; button logic goes here
    jmp a_done

b_press:
    ; button logic goes here
    jmp b_done
.endproc
