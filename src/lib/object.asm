; object functions library

.segment "CODE"

; MACROS START

.macro set_velocity_x VEL
    lda VEL
    sta player_velocity
.endmacro

.macro set_player_velocity_y VEL
    lda VEL
    sta player_velocity+1
.endmacro

.macro change_player_velocity DELTA_X, DELTA_Y
    lda DELTA_X
    clc
    adc player_velocity
    sta player_velocity
    lda DELTA_Y
    clc
    adc player_velocity+1
    sta player_velocity+1
.endmacro

; MACROS END

; PROCEDURES START

; load x with desired x axis setting
; sets subpixels to 0
.proc set_player_pos_x
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

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc

; load y with desired y axis setting
; sets subpixels to 0
.proc set_player_pos_y
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

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc

.proc set_player_pos_real
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
    rotate_memory_right player_pos_real+1

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

    lda player_flags
    ora #%00000001 ; set sprite update flag
    sta player_flags

    rts
.endproc

.proc cap_player_velocity
    ; cap x
    lda player_velocity

    ; determine if velocity is positive or negative
    and #%10000000
    bne @x_vel_negative
        ; if velocity is positive
        lda player_velocity
        sec
        sbc #$2d ; 4 pixels per frame limit
        bcc :+
            ; if carry is set, then we're above the limit
            lda #$2c
            sta player_velocity
        :
        jmp @x_vel_cap_end

    @x_vel_negative:
        ; if velocity is negative
        lda player_velocity
        sec
        sbc #$d4 ; -4 pixels per frame limit
        bcs :+
            ; if carry is set, then we're above the limit
            lda #$d4
            sta player_velocity
        :
    @x_vel_cap_end:

    ; cap y
    lda player_velocity+1

    ; determine if velocity is positive or negative
    and #%10000000
    bne @y_vel_negative
        ; if velocity is positive
        lda player_velocity+1
        sec
        sbc #$61 ; 6 pixels per frame limit
        bcc :+
            ; if carry is set, then we're above the limit
            lda #$60
            sta player_velocity+1
        :
        jmp @y_vel_cap_end

    @y_vel_negative:
        ; if velocity is negative
        lda player_velocity+1
        sec
        sbc #$A0 ; -6 pixels per frame limit
        bcs :+
            ; if carry is set, then we're above the limit
            lda #$A0
            sta player_velocity+1
        :
    @y_vel_cap_end:
    rts
.endproc

; PROCEDURES END