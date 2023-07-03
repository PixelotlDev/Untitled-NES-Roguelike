.segment "HEADER"

; this header is to set up a TxSROM MMC3 mapper
  .byte 'N', 'E', 'S', $1A    ; these bytes always start off an NES 2.0 file
  .byte $02                   ; PRG size in 16k units
  .byte $01                   ; CHR size in 8k units

;============================================================================================
; Flag 6
; 7654 3210
; |||| ||||
; |||| |||+- Mirroring: 0: horizontal (vertical arrangement) (CIRAM A10 = PPU A11)
; |||| |||              1: vertical (horizontal arrangement) (CIRAM A10 = PPU A10)
; |||| ||+-- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
; |||| |+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
; |||| +---- 1: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
; ||||
; ++++----- Mapper Number D0..D3
;============================================================================================
  .byte %01100010

;============================================================================================
; Flag 7
; 7654 3210
; |||| ||||
; |||| ||++- Console type: 0: Nintendo Entertainment System/Family Computer
; |||| |||                 1: Nintendo Vs. System
; |||| |||                 2: Nintendo Playchoice 10
; |||| |||                 3: Extended Console Type
; |||| ++--- NES 2.0 identifier (%10)
; ||||
; ++++----- Mapper Number D4..D7
;============================================================================================
  .byte %01111000

;============================================================================================
; Flag 8
; 7654 3210
; |||| ||||
; |||| ++++- Mapper number D8..D11
; ||||
; ++++------ Submapper number
;============================================================================================
  .byte %00000000

;============================================================================================
; Flag 9
; 7654 3210
; |||| ||||
; |||| ++++- PRG-ROM size MSB
; ||||
; ++++------ CHR-ROM size MSB
;============================================================================================
  .byte %00000000

;============================================================================================
; Flag 10
; 7654 3210
; |||| ||||
; |||| ++++- PRG-RAM (volatile) shift count
; ||||
; ++++------ PRG-NVRAM/EEPROM (non-volatile) shift count
;
;If the shift count is non-zero, the actual size is "64 << shift count" bytes
;============================================================================================
  .byte %00000111

;============================================================================================
; Flag 11
; 7654 3210
; |||| ||||
; |||| ++++- CHR-RAM size (volatile) shift count
; ||||
; ++++------ CHR-NVRAM size (non-volatile) shift count
;
;If the shift count is non-zero, the actual size is "64 << shift count" bytes
;============================================================================================
  .byte %00000000

;============================================================================================
; Flag 12
; 7654 3210
; |||| ||||
; .... ..++- CPU/PPU timing mode: 0: RP2C02 ("NTSC NES")
;                                 1: RP2C07 ("Licensed PAL NES")
;                                 2: Multiple-region
;                                 3: UA6538 ("Dendy")
;============================================================================================
  .byte %00000000

.segment "VECTORS" ; THIS IS THE LAST 6 BYTES OF THE FILE, USED AS ADDRESSES FOR INTERRUPTS
.word nmi
.word reset
.word irq
