; player functions library

.segment "CODE"

; load x with desired x axis setting
; load y with desired y axis setting
; sets subpixels to 0
.proc set_player_pos
    ; set x
    ; byte 1
    txa
    lsr
    lsr
    lsr
    lsr
    sta player_pos

    ; byte 2
    txa
    asl
    asl
    asl
    asl
    sta player_pos+1

    ; set y
    ; byte 1
    tya
    lsr
    lsr
    lsr
    lsr
    sta player_pos+2

    ; byte 2
    tya
    asl
    asl
    asl
    asl
    sta player_pos+3

    ; set player_pos_real
    lda player_pos
    and #%00001111
    adc player_pos+1
    sta player_pos_real
    ror player_pos_real
    ror player_pos_real
    ror player_pos_real
    ror player_pos_real
    

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc

; load x with desired x axis pixel movement + subpixel movement (first bit = sign, next 3 bits = pixel, final 4 bits = subpixel)
.proc move_player_x
    txa
    ; if movement is 0, we can skip this
    beq @movement_eval_end
    ; determine if movement is positive or negative
    and #%10000000
    bne @movement_negative
        ; if movement is positive
        txa
        clc
        adc player_pos+1
        bcc :+
            ; if the carry is set, we've overflowed and we need to increment byte 1
            inc player_pos
        :

        sta player_pos+1

        jmp @movement_eval_end

    @movement_negative:
        ; if movement is negative
        txa
        ; make our number the positive equivalent
        eor #%11111111
        clc
        adc #$01
        ; see if that number is larger than the current byte 2 value (in which case we'd cause an underflow)
        ; we sbc an extra 1 so that we don't accidentally decrement player_pos when we reach 0, but when we haven't underflowed
        sec
        sbc #$01
        sec
        sbc player_pos+1
        bcc :+
            ; if the carry is set, we've underflowed and we need to decrement pixel pos
            dec player_pos
        :

        ; then we actually perform the addition of the negative and positive numbers and store the result
        txa
        clc
        adc player_pos+1

        sta player_pos+1

    @movement_eval_end:

    rts
.endproc

; load y with desired y axis pixel movement + subpixel movement (first bit = sign, next 3 bits = pixel, final 4 bits = subpixel)
.proc move_player_y
    tya
    ; if movement is 0, we can skip this
    beq @movement_eval_end
    ; determine if movement is positive or negative
    and #%10000000
    bne @movement_negative
        ; if movement is positive
        tya
        clc
        adc player_pos+3
        bcc :+
            ; if the carry is set, we've overflowed and we need to increment byte 1
            inc player_pos+2
        :

        sta player_pos+3

        jmp @movement_eval_end

    @movement_negative:
        ; if movement is negative
        tya
        ; make our number the positive equivalent
        eor #%11111111
        clc
        adc #$01
        ; see if that number is larger than the current byte 2 value (in which case we'd cause an underflow)
        ; we sbc an extra 1 so that we don't accidentally decrement player_pos when we reach 0, but when we haven't underflowed
        sec
        sbc #$01
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

    @movement_eval_end:

    rts
.endproc

; load x with desired x axis pixel movement + subpixel movement (first bit = sign, next 3 bits = pixel, final 4 bits = subpixel)
; load y with desired y axis pixel movement + subpixel movement (first bit = sign, next 3 bits = pixel, final 4 bits = subpixel)
.proc move_player
    jsr move_player_x
    jsr move_player_y

    ; set player_pos_real
    ; x pos
    ; add the two bytes together the wrong way round
    lda player_pos
    and #%00001111
    sta player_pos_real
    lda player_pos+1
    and #%11110000
    clc
    adc player_pos_real

    ; then rotate them until they're the right way round
    rotate_memory_right player_pos_real
    rotate_memory_right player_pos_real
    rotate_memory_right player_pos_real
    rotate_memory_right player_pos_real

    ; y pos
    ; add the two bytes together the wrong way round
    lda player_pos+2
    and #%00001111
    sta player_pos_real+1
    lda player_pos+3
    and #%11110000
    clc
    adc player_pos_real+1

    ; then rotate them until they're the right way round
    rotate_memory_right player_pos_real+1
    rotate_memory_right player_pos_real+1
    rotate_memory_right player_pos_real+1
    rotate_memory_right player_pos_real+1

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc