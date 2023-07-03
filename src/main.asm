; TODO: fix screen flicker bug when evaluating/searching tiles
;       impliment in-game timer

; lots of this code (and some of the comments) isn't mine, mostly because i didn't want to spend half a year learning the 6502 architecture and nes mapping before i could even
; start writing a game - i learn better by actually trying to code something :3
; The base 'engine' code comes from: https://github.com/battlelinegames/nes-starter-kit

.linecont       +               ; Allow line continuations
.feature        c_comments      /* allow this style of comment */

; after we load the sprites, we know that this one should always point to the player cursor's y and x position respectively, unless something has gone horribly wrong
.define CursorY $0200
.define CursorX $0203

.segment "VARS"

.segment "IMG"
    .incbin "../assets/tiles/game_tiles.chr"

    ; include scene assets
    .include "../assets/scenes/menu/menu_tiles.asm"
    .include "../assets/scenes/menu/menu_attribute.asm"

    .include "./define/header.asm"
    .include "./define/palette.asm"
    .include "./define/variables.asm"

    .include "./lib/utils.asm"
    .include "./lib/gamepad.asm"
    .include "./lib/ppu.asm"

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

game_loop:
    lda nmi_ready
    bne game_loop ; if nmi_ready equals anything but 0, this will send us back up to game_loop - nmi_ready will be set to 0 when an NMI has occurred
                  ; when we're not waiting for a non-maskable interrupt (NMI), we can proceed, to give us the most program time possible before the next one
    lda #$01
    sta nmi_ready

    ; GAME LOGIC START

    jsr check_gamepad

    jsr button_logic

    ; GAME LOGIC END
    
    jmp game_loop
