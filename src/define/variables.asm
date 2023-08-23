.segment "ZEROPAGE"
    nmi_ready: .res 1
    jsr_indirect_address: .res 1
    scene_data: .res 1
    scene_tiles_address: .res 2 ; LSB, MSB
    scene_attribute_address: .res 2 ; LSB, MSB
    player_pos: .res 4 ; X1, X2, Y1, Y2
                       ;   Bit 1   |   Bit 2
                       ; 7654 3210 | 7654 3210
                       ; .... ...+- Sprite update needed
    player_flags: .res 1 ; 7654 3210
                         ; .... ...+- Sprite update needed
    