;******************************************
;
;   Boot1.asm
;   - simple bootloader, created 4/3/2020
;
;******************************************

bits    16                           ; indicates we are still in 16-bit real mode

org     0x7c00                       ; BIOS will load bootloader at 0x7c00
                                     ; this ensures all addresses are relative to this

start: jmp main

; include FAT12 configs
%include './util/bpb.asm'

; include utilities
%include './util/print.asm'
%include './util/read_sector.asm'
;%include './util/conv_addr.asm'

;*************************************************;
;	Bootloader entry point
;*************************************************;

 main:
    mov [BOOT_DRIVE], dl                    ; BIOS sets boot drive in dl
            
    ;*************************************************;
    ;	nullify segment registers
    ;   
    ;*************************************************;
    .SET_REG:
        cli                                 ; disable interrupts
        xor ax, ax                          ; setup registers to ensure they are 0
        mov ds, ax                          ; we use effective address 0x7c00 (org)
        mov es, ax
        mov fs, ax
        mov gs, ax
    ;*************************************************;
    ;	Initialize stack
    ;   
    ;*************************************************;
    .SET_STACK:
        mov ss, ax                          ; null stack segment register
        mov bp, 0x7c00                      ; set stack bottom right below bootloader
        mov sp, bp                          ; set stack top at stack bottom to start
        sti                                 ; restore interruptst
    ;*************************************************;
    ;	Read 2nd stage BL and load into memory
    ;   
    ;*************************************************;
    .ENTER:     
        mov si, enter_msg                   ; we are in danger of reading to 
        call Print                          ; wrong address if we don't null ds first
    .LOAD_SECOND_BL:
        mov bx, [SSBLADD]                   ; read to memory immediately after boot loader
        mov dl, [BOOT_DRIVE]                ; read from boot drive
        mov dh, 0x00                        ; read from side 0
        mov cl, 0x02                        ; read from second sector (after bootloader)
        mov ch, 0x00                        ; read from outmost cylinder
        mov al, [SSBLSIZE]                  ; read 1 sector
        call ReadSectors
    
    .EXIT:
        mov si, exit_msg
        call Print
    
    jmp [SSBLADD]                           ; jump to second stage bl

    SSBLADD: dw 0x7e00                      ; address to load second stage bootloader at
    SSBLSIZE: dw 0x01
    enter_msg: db "Entering BL 1...", 0
    exit_msg: db "Exiting BL 1...", 0
    
    BOOT_DRIVE: db 0                        ; drive to boot from
    times 510 - ($ - $$) db 0               ; pad bootloader to 510 bytes (512 with magic number)
    dw 0xAA55                               ; bootloader magic number
