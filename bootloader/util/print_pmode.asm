[bits 32]
print_pmode:
    pusha
    mov edx, VID_MEM
    print:
        mov al, [ebx]                       ; get next char
        mov ah, WHITE_BLACK                 ; white on black mode
        cmp al, 0
        je done                             ; jump on null terminator
        mov [edx], ax   
        inc ebx                             ; increment to next char address
        add edx, 2                          ; increment vid memory map by 2 bytes (1 for char, 1 for mode)
        jmp print                       
    done:
        popa
        ret
    
VID_MEM equ 0xb8000                         ; base address of memory mapped display
WHITE_BLACK equ 0x0f                        ; video mode for white text on black bg
