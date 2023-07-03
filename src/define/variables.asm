.segment "ZEROPAGE"
    nmi_ready: .res 1
    jsr_indirect_address: .res 1
    scene_data: .res 1
    scene_tiles_address: .res 2 ; LSB, MSB
    scene_attribute_address: .res 2 ; LSB, MSB