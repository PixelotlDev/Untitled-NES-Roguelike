.segment "ZEROPAGE"
    nmi_ready: .res 1
    jsr_indirect_address: .res 1
    scene_data: .res 1
    scene_tiles_address: .res 2 ; LSB, MSB
    scene_attribute_address: .res 2 ; LSB, MSB
    player_pos: .res 4 ; x1, x2, y1, y2
                       ;   Byte 1  |  Byte 2
                       ; 7654 3210 | 7654 3210
                       ; .... ||||   |||| ++++------ Subpixels
                       ;      ++++---++++------------- Pixels
    player_pos_real: .res 2 ; x, y (pixels)
    player_flags: .res 1 ; 7654 3210
                         ; .... ...+- Sprite update needed
    