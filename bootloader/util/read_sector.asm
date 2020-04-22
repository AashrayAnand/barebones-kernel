; helper function to read from disk
; dl -> drive #
; ch -> cylinder #
; dh -> floppy side
; cl -> start sector on track
; al -> number of sectors
; es:bx -> where sectors are written to
ReadSectors:
    mov ah, 0x02                            ; BIOS read disk sectors function
    push ax                                 ; store ax, al contains # of sectors to read
    int 0x13                                ; disk read/write interrupt
    jc disk_error                           ; jump to disk_error on failure
    mov dl, al                              ; move actual # of sectors read to dl
    pop ax                                  ; restore ax, al = expected # of sectors read
    cmp al, dl                              ; compare actual vs. expected sectors read
    jne disk_error
    call disk_success
    ret
    
disk_success:
    mov si, DISK_SUCC_MSG
    call Print
    ret

; error function, for failed disk reads
disk_error:
    mov si, DISK_ERR_MSG
    call Print
    jmp $ ; return to latest instruction
    
read_error:
    mov si, READ_ERR_MSG
    call Print
    jmp $
    
READ_ERR_MSG: db "ERR: WRONG NUM. SECTORS READ...", 0
DISK_ERR_MSG: db "ERR: DISK READ...", 0
DISK_SUCC_MSG: db "READ DISK SUCCESSFULLY...", 0
