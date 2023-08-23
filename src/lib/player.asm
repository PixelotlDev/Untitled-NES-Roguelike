; player functions library

.segment "CODE"

; load x with desired x axis setting
; load y with desired y axis setting
.proc set_player_pos
    ; set x
    ; byte 1
    txa
    sta player_pos

    ; byte 2
    lda #$0
    sta player_pos+1

    ; set y
    ; byte 1
    tya
    sta player_pos+2

    ; byte 2
    lda #$0
    sta player_pos+3

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc

; load x with desired x axis pixel movement
; load y with desired x axis subpixel movement (5 bits, )
.proc move_player_x
    ; subpixel movement
    tya
    ; if zero, skip to pixel movement
    beq @subpixel_eval_end
    ; else, determine if change is positive or negative
    and #%10000000
    bne @subpixel_negative
        ; if subpixel change is positive
        tya
        clc
        adc player_pos+1
        bcc :+
            ; if the carry is set, we've overflowed and we need to increment pixel pos
            inc player_pos
        :

        sta player_pos+1

        jmp @subpixel_eval_end

    @subpixel_negative:
        ; if subpixel change is negative
        tya
        ; make our number the positive equivalent
        sec
        sbc #$01
        eor #%10000000
        ; see if that number is larger than the current subpixel value (in which case we'd cause an underflow)
        sec
        sbc player_pos+1
        bcc :+
            ; if the carry is clear, we've underflowed and we need to decrement pixel pos
            dec player_pos
        :

        ; then we actually perform the addition of the negative and positive numbers and store the result
        tya
        clc
        adc player_pos+1

        sta player_pos+1

    @subpixel_eval_end:

    ; pixel movement
    txa
    clc
    adc player_pos

    sta player_pos
    
    rts
.endproc

; load x with desired y axis pixel movement
; load y with desired y axis subpixel movement
.proc move_player_y
    ; subpixel movement
    tya
    ; if zero, skip to pixel movement
    beq @subpixel_eval_end
    ; else, determine if change is positive or negative
    and #%10000000
    bne @subpixel_negative
        ; if subpixel change is positive
        tya
        clc
        adc player_pos+3
        bcc :+
            ; if the carry is set, we've overflowed and we need to increment pixel pos
            inc player_pos+2
        :

        sta player_pos+3

        jmp @subpixel_eval_end

    @subpixel_negative:
        ; if subpixel change is negative
        tya
        ; make our number the positive equivalent
        sec
        sbc #$01
        eor #%10000000
        ; see if that number is larger than the current subpixel value (in which case we'd cause an underflow)
        sec
        sbc player_pos+3
        bcc :+
            ; if the carry is clear, we've underflowed and we need to decrement pixel pos
            dec player_pos+2
        :

        ; then we actually perform the addition of the negative and positive numbers and store the result
        tya
        clc
        adc player_pos+3

        sta player_pos+3

    @subpixel_eval_end:

    ; pixel movement
    txa
    clc
    adc player_pos+2

    sta player_pos+2
    
    rts
.endproc