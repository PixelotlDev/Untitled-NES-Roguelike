; TODO: BIG CHANGE
;       Player pos format changed to a workable format, the rest of the movement and sprite setting code needs to be redone

; lots of this code (and some of the comments) isn't mine, mostly because i didn't want to spend half a year learning the 6502 architecture and nes mapping before i could even
; start writing a game - i learn better by actually trying to code something :3
; The base 'engine' code comes from: https://github.com/battlelinegames/nes-starter-kit

.linecont       +               ; Allow line continuations

.segment "VARS"

.segment "IMG"
    .incbin "../assets/tiles/game_tiles.chr"

    ; include scene assets
    .include "../assets/menu/main/tiles.asm"
    .include "../assets/menu/main/attribute.asm"
    .include "../assets/scenes/test_level/tiles.asm"
    .include "../assets/scenes/test_level/attribute.asm"

    .include "./define/header.asm"
    .include "./define/palette.asm"
    .include "./define/variables.asm"

    .include "./lib/gamepad.asm"
    .include "./lib/ppu.asm"
    .include "./lib/utils.asm"
    .include "./lib/graphics.asm"
    .include "./lib/player.asm"

    .include "./interrupt/irq.asm"              ; not currently using irq code, but it must be defined
    .include "./interrupt/reset.asm"            ; code and macros related to pressing the reset button
    .include "./interrupt/nmi.asm"

.segment "CODE"

load_menu:
    lda #$0 ; zero the accumulator so it's empty for future use
    jsr wait_for_vblank

    jsr disable_rendering

    lda #<menu_tiles
    sta scene_tiles_address
    lda #>menu_tiles
    sta scene_tiles_address+1
    jsr load_initial_scene_tiles ; load menu tiles

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

    lda #<test_level_tiles
    sta scene_tiles_address
    lda #>test_level_tiles
    sta scene_tiles_address+1
    jsr load_initial_scene_tiles ; load menu tiles

    lda #<test_level_attribute
    sta scene_attribute_address
    lda #>test_level_attribute
    sta scene_attribute_address+1
    jsr load_initial_scene_attribute ; load menu attribute table

    lda #$20
    sta player_pos
    lda #$0
    sta player_pos+1

    ; TEST PLAYER SPRITE
    lda #$01 ; sprite ID
    sta $0205 ; store in sprite memory location
    lda #%00000001
    sta $0206
    lda #$0
    tax
    lda #$40
    tay
    jsr set_player_pos

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

    ; TEST MOVEMENT
    lda #$f0 ; -1pps
    tax
    lda #$f0 ; -1pps
    tay
    jsr move_player

    ; TEST SPRITE UPDATE
    lda #$01 ; sprite ID
    tax
    lda player_pos_real+1 ; y pos
    tay
    lda player_pos_real ; x pos
    jsr move_sprite

    ; GAME LOGIC END
    
    jmp game_loop
