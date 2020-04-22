GDT_START:                                  ; use this directive to get size of gdt

NULL_GDT:
    dd 0x00                                 ; mandatory null segment descriptor at head
    dd 0x00                                 ; two dd = define 2 double words = 8 zeroed out bytes
                                            ; each segment descriptor is 8 bytes exactly
CODE_SEGMENT:
    ; code segment has base addresss of 0x0000, limit of 0xfffff
    ; descriptor type = 1b (code), type flags = 1 (code), 0 
    ; (not conforming), 1 (readable), 0 (not accessed yet) = 1010b
    ; present = 1 (present in memory), privilege = 0 (highest privilege)
    ; order of segment descriptor is bits 0-15 -> segment limit, bits 15-31 -> base address 0:15
    ; bits 32-39 -> base address 16:23, bits 40-43 -> type flags, bits 44 -> segment type (code/data)
    ; bits 45-46 -> ring privilege level, bits 47 -> segment present in memory
    ; (for VM), bits 48-51 -> segment limit 16-19, bits 52 -> AVL, bits 53 -> 64-bit
    ; segment (unused), bits 54 -> default operation size (0 -> 16 bit, 1 -> 32 bit), bits 55 ->
    ; granularity, bits 56-63 -> base address 24-31
    dw 0xffff                               ; segment limit (bits 0-15)
    dw 0x0                                  ; first word of base address (bits 16-31)
    db 0x0                                  ; next byte of base address (bits 32-39)
    db 10011010b                            ; type flags (1010) and present + privilege + segment type (1001) (bits 40-47)
    db 11001111b                            ; last byte of segment limit (1111b = 0x0f) plus other flags (bits 48-55)
    db 0x0                                  ; last byte of base address (bits 56-63)
    
DATA_SEGMENT:
    ; this segment descriptor is mostly the same as the code segment, with some exceptions
    ; base address = , segment type = 0 (data), type flags = 0 (data), 0 (expand down), 1 (writable), 0 (accessed)
    dw 0xffff                               ; segment limit (bits 0-15)
    dw 0x0                                  ; first word of base address (biiits 16-31)
    db 0x0                                  ; next byte of base address (bits 32-39)
    db 10010010b                            ; type flags (0010) and present plus other flags
    db 11001111b                            ; last byte of segment limit (1111b = 0xf) plus other flags (bits 48-55)
    db 0x0                                  ; last byte of base address

GDT_END:
    
gdt_descriptor:
    dw GDT_END - GDT_START - 1              ; first 2 bytes of gdt descriptor is size of gdt
    dd GDT_START                            ; last 4 bytes of gdt descriptor is start address
    
CODE_SEG equ CODE_SEGMENT - GDT_START
DATA_SEG equ DATA_SEGMENT - GDT_START
