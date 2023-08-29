.segment "ZEROPAGE"
    nmi_ready: .res 1
    jsr_indirect_address: .res 1
    zp_maths_1: .res 1 ; for maths between registers - unfortunately, x and y can't be added to or subtracted from the accumulator
    scene_data: .res 1
    scene_tiles_address: .res 2 ; LSB, MSB
    scene_metatiles_address: .res 2 ; LSB, MSB
    scene_attribute_address: .res 2 ; LSB, MSB
    display_buffer_address: .res 2 ; LSB, MSB - pointer to display buffer, since our offset from the start of display buffer needs to be more than one byte
    metatile_pointer: .res 2 ; LSB, MSB - points to which metatile is being drawn
    metatile_screen_pointer: .res 1 ; points to where a tile from a metatile will go on the screen
    player_pos: .res 4 ; x1, x2, y1, y2
                       ;   Byte 1  |  Byte 2
                       ; 7654 3210 | 7654 3210
                       ; .... ||||   |||| ++++- Subpixels
                       ;      ++++---++++------ Pixels
    player_pos_real: .res 2 ; x, y (pixels)
    player_velocity: .res 2 ; x, y
                            ; 7654 3210
                            ; |||| ++++- Subpixels
                            ; |+++------ Pixels
                            ; +--------- Sign (+/-)
    player_last_velocity: .res 2 ; same as above
    player_flags: .res 1 ; 7654 3210
                         ; .... ..|+- Sprite update needed
                         ;        +-- Touching floor
    
    object_array: .res 0
    pos: .res 4 ; x1, x2, y1, y2
                ;   Byte 1  |  Byte 2
                ; 7654 3210 | 7654 3210
                ; .... ||||   |||| ++++- Subpixels
                ;      ++++---++++------ Pixels
    last_pos: .res 4 ; same as above
    velocity: .res 2 ; x, y
                     ; 7654 3210
                     ; |||| ++++- Subpixels
                     ; |+++------ Pixels
                     ; +--------- Sign (+/-)
    flags: .res 1 ; 7654 3210
                  ; .... ..|+- Sprite update needed
                  ;        +-- Touching floor
    ID: .res 1

.segment "VARS"
    display_buffer: .res 960 ; space for metatiles to become tiles