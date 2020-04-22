Print:
    lodsb                                   ; load byte from si to al and increment address at si
    or al, al                               ; al = current character
    jz PrintDone                            ; found null terminator, we are done
    mov ah, 0x0e                            ; BIOS video teletype output function
    int 0x10                                ; interrupt to print to screen
    jmp Print                               ; loop to print next byte

PrintDone:
    ret
