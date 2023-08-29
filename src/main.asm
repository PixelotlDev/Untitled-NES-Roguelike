; TODO: Finish implementing metatiles
;       Finish implementing objects
;       Remove player as a distinct thing, replacing it with an object referenced by the player controller

; lots of this code (and some of the comments) isn't mine, mostly because i didn't want to spend half a year learning the 6502 architecture and nes mapping before i could even
; start writing a game - i learn better by actually trying to code something :3
; The base 'engine' code comes from: https://github.com/battlelinegames/nes-starter-kit

.linecont       +               ; Allow line continuations

.segment "SAVE"

.segment "IMG"
    .incbin "../assets/tiles/game_tiles.chr"

    ; include scene assets
    .include "../assets/menu/main/tiles.asm"
    .include "../assets/menu/main/attribute.asm"
    .include "../assets/scenes/test_level/metatiles.asm"
    .include "../assets/scenes/test_level/attribute.asm"
    .include "../assets/tiles/metatiles/metatiles.asm"

    .include "define/header.asm"
    .include "define/palette.asm"
    .include "define/variables.asm"

    .include "lib/utils.asm"
    .include "lib/player.asm"
    .include "lib/gamepad.asm"
    .include "lib/ppu.asm"
    .include "lib/graphics.asm"

    .include "interrupt/irq.asm"              ; not currently using irq code, but it must be defined
    .include "interrupt/reset.asm"            ; code and macros related to pressing the reset button
    .include "interrupt/nmi.asm"

.segment "CODE"

initialize_main:
    lda #<display_buffer
    sta display_buffer_address
    lda #>display_buffer
    sta display_buffer_address+1

load_menu:
    lda #$0
    jsr wait_for_vblank

    jsr disable_rendering

    lda #<menu_tiles
    sta scene_tiles_address
    lda #>menu_tiles
    sta scene_tiles_address+1
    jsr load_scene_tiles ; load menu tiles

    lda #<menu_attribute
    sta scene_attribute_address
    lda #>menu_attribute
    sta scene_attribute_address+1
    jsr load_initial_scene_attribute ; load menu attribute table

    jsr enable_rendering

menu_loop:
    lda nmi_ready
    bne menu_loop ; if nmi_ready equals anything but 0, this will send us back up to game_loop - nmi_ready will be set to 0 when an NMI has occurred
                  ; when we're not waiting for a non-maskable interrupt (NMI), we can proceed, to give us the most program time possible before the next one
    lda #$01
    sta nmi_ready

    ; MENU LOGIC START

    jsr check_gamepad ; this basically reads the gamepad inputs and sets a bunch of things - more info in gamepad.asm

    lda gamepad_new_press
    and #%00001000      ; loop unless start button is being pressed
    beq menu_loop

    ; MENU LOGIC END

load_test_level:
    lda #$0 ; zero the accumulator so it's empty for future use
    jsr wait_for_vblank

    jsr disable_rendering

    ; METATILES TEST
    lda #<test_level_metatiles
    sta scene_metatiles_address
    lda #>test_level_metatiles
    sta scene_metatiles_address+1
    jsr load_scene_metatiles ; load test level tiles

    jsr load_scene_tiles ; load test level tiles

    lda #<test_level_attribute
    sta scene_attribute_address
    lda #>test_level_attribute
    sta scene_attribute_address+1
    jsr load_initial_scene_attribute ; load test level attribute table

    ; TEST PLAYER SPRITE
    lda #$01 ; sprite ID
    sta $0205 ; store in sprite memory location
    lda #%00000001
    sta $0206
    lda #$20
    tax
    jsr set_player_pos_x
    lda #$40
    tay
    jsr set_player_pos_y

    set_player_velocity_x #$00
    set_player_velocity_y #$00
    lda #$00
    sta player_last_velocity
    sta player_last_velocity+1

    jsr enable_rendering

game_loop:
    lda nmi_ready
    bne game_loop ; if nmi_ready equals anything but 0, this will send us back up to game_loop - nmi_ready will be set to 0 when an NMI has occurred
                  ; when we're not waiting for a non-maskable interrupt (NMI), we can proceed, to give us the most program time possible before the next one
    lda #$01
    sta nmi_ready

    ; GAME LOGIC START

    jsr check_gamepad

    jsr button_logic

    ; TEST VELOCITY
    change_player_velocity #$00, #$03

    ; DRAG
    lda player_velocity
    beq @drag_end
    and #%10000000
    bne @velocity_negative
        lda player_velocity
        sec
        sbc #$04
        bcs :+
            ; if subtracting 4 put us past 0
            lda #$0
        :

        jmp @drag_end

    @velocity_negative:
        lda player_velocity
        clc
        adc #$04
        bcc :+
            ; if adding 4 put us past 0
            lda #$0
        :

    @drag_end:
    sta player_velocity

    jsr cap_player_velocity

    ; TEST MOVEMENT
    lda player_velocity ; x velocity
    tax
    lda player_velocity+1 ; y velocity
    tay
    jsr move_player

    jsr set_player_pos_real

    ; TEST COLLISION
    clear_flags player_flags, #%00000010 ; clear on floor flag
    lda player_pos_real+1
    sec
    sbc #$c5
    bcc :+
        ldy #$c5
        jsr set_player_pos_y
        set_player_velocity_y #$0
        set_flags player_flags, #%00000010 ; set on floor flag
    :

    ; TEST SPRITE UPDATE
    jsr set_player_pos_real

    lda #$01 ; sprite ID
    tax
    lda player_pos_real+1 ; y pos
    tay
    lda player_pos_real ; x pos
    jsr move_sprite

    clear_flags player_flags, #%00000001 ; clear draw sprite flag

    ; CLEANUP
    lda player_velocity
    sta player_last_velocity
    lda player_velocity+1
    sta player_last_velocity+1

    ; GAME LOGIC END
    
    jmp game_loop
