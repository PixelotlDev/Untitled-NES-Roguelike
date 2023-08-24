; gamepad control library

;======================================================================================
; GAMEPAD DATA FLAGS
; 76543210
; ||||||||
; |||||||+--> A Button
; ||||||+---> B Button
; |||||+----> SELECT Button
; ||||+-----> START Button
; |||+------> UP Direction
; ||+-------> DOWN Direction
; |+--------> LEFT Direction
; +---------> RIGHT Direction
;======================================================================================

; These are the bit flags the are used by the vars
.define PRESS_A        #%00000001
.define PRESS_B        #%00000010
.define PRESS_SELECT   #%00000100
.define PRESS_START    #%00001000
.define PRESS_UP       #%00010000
.define PRESS_DOWN     #%00100000
.define PRESS_LEFT     #%01000000
.define PRESS_RIGHT    #%10000000

.segment "ZEROPAGE"
    gamepad_press: .res 1
    gamepad_last_press: .res 1
    gamepad_new_press: .res 1
    gamepad_release: .res 1

.segment "CODE"

GAMEPAD_REGISTER = $4016

; Initialize the gamepad. This is called from check_gamepad
.proc gamepad_init
    lda gamepad_press
    sta gamepad_last_press ; set gamepad_last_press to gamepad_press

    ; Setup the gamepad register so we can start pulling gamepad data
    lda #$01
    sta GAMEPAD_REGISTER
    lda #$0
    sta GAMEPAD_REGISTER

    sta gamepad_press ; clear out our gamepad press byte

    rts
.endproc

; use this macro to figure out if a specific button was pressed
.macro button_press_check button
    .local @not_pressed
    lda GAMEPAD_REGISTER
    and #%00000001
    beq @not_pressed    ; beq key not pressed
        lda button
        ora gamepad_press
        sta gamepad_press
    @not_pressed:   ; key not pressed
.endmacro

; initialize and set the gamepad values
.proc check_gamepad

    jsr gamepad_init ; prepare the gamepad register to pull data serially

    gamepad_a:
        button_press_check PRESS_A

    gamepad_b:
        button_press_check PRESS_B

    gamepad_select:
        button_press_check PRESS_SELECT

    gamepad_start:
        button_press_check PRESS_START

    gamepad_up:
        button_press_check PRESS_UP

    gamepad_down:
        button_press_check PRESS_DOWN

    gamepad_left:
        button_press_check PRESS_LEFT

    gamepad_right:
        button_press_check PRESS_RIGHT

    ; to find out if this is a newly pressed button, load the last buttons pressed, and
    ; flip all the bits with an eor #$ff.  Then you can AND the results with current
    ; gamepad pressed.  This will give you what wasn't pressed previously, but what is
    ; pressed now.  Then store that value in the gamepad_new_press
    lda gamepad_last_press
    eor #$ff
    and gamepad_press

    sta gamepad_new_press ; all these buttons are new presses and not existing presses

    ; in order to find what buttons were just released, we load and flip the buttons that
    ; are currently pressed  and and it with what was pressed the last time.
    ; that will give us a button that is not pressed now, but was pressed previously
    lda gamepad_press       ; reload original gamepad_press flags
    eor #$ff                ; flip the bits so we have 1 everywhere a button is released

    ; anding with last press shows buttons that were pressed previously and not pressed now
    and gamepad_last_press

    ; then store the results in gamepad_release
    sta gamepad_release  ; a 1 flag in a button position means a button was just released
    rts
.endproc

.proc button_logic
    ; LEFT
        lda gamepad_new_press
        and #%01000000      ; if left button is being pressed...
        bne left_press      ; do stuff at the left_press label
    left_press_done:
        lda gamepad_press
        and #%01000000      ; if left button is being pressed...
        bne left_held      ; do stuff at the left_press label
    left_held_done:
    ; RIGHT
        lda gamepad_new_press
        and #%10000000      ; above, but right
        bne right_press
    right_press_done:
        lda gamepad_press
        and #%10000000      ; if left button is being pressed...
        bne right_held      ; do stuff at the left_press label
    right_held_done:
    ; UP
        lda gamepad_new_press
        and #%00010000      ; above, but up
        bne up_press
    up_press_done:
        lda gamepad_press
        and #%00010000      ; if left button is being pressed...
        bne up_held      ; do stuff at the left_press label
    up_held_done:
    ; DOWN
        lda gamepad_new_press
        and #%00100000      ; above, but down
        bne down_press
    down_press_done:
    ; A
        lda gamepad_new_press
        and #%00000001      ; above, but a
        bne a_press
    a_press_done:
    ; B
        lda gamepad_new_press
        and #%00000010      ; above, but b
        bne b_press
    b_press_done:
        rts                 ; if nothing's being pressed, go back to the program

    ; LEFT
    left_press:
        ; button logic goes here
        jmp left_press_done

    left_held:
        change_player_velocity #$f4, #$00
        jmp left_held_done

    ; RIGHT
    right_press:
        ; button logic goes here
        jmp right_press_done

    right_held:
        change_player_velocity #$0c, #$00
        jmp right_held_done

    ; UP
    up_press:
        ; button logic goes here

    up_held:
        ; button logic goes here
        lda player_flags
        and #%00000010
        beq @no_jump
            set_player_velocity_y #$b8
        @no_jump:
        jmp up_held_done

    ; DOWN
    down_press:
        ; button logic goes here
        set_player_velocity_x #$00
        set_player_velocity_y #$00
        jmp down_press_done

    ; A
    a_press:
        ; button logic goes here
        jmp a_press_done

    ; B
    b_press:
        ; button logic goes here
        jmp b_press_done
.endproc
