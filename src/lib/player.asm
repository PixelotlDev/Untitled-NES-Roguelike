; player functions library

.segment "CODE"

; load x with desired x axis setting
; load y with desired y axis setting
.proc set_player_pos
    ; set x
    txa
    sta player_pos

    ; set y
    tya
    sta player_pos

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

.endproc

; load x with desired x axis movement
; load y with desired y axis movement
.proc move_player
    ; x movement
    txa
    adc player_pos
    sta player_pos

    ; y movement
    tya
    adc player_pos+1
    sta player_pos+1

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc