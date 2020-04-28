org 0x7e00                              ; offset to 512 bytes past stage 1 bootloader, 0x7c00

jmp main                                ; jump to main

%include './util/print.asm'
%include './util/read_sector.asm'
%include './util/init_gdt.asm'
;*************************************************;
;	Second-stage bootloader entry point
;*************************************************;
[bits 16]
main:

    mov [BOOT_DRIVE], dl                ; boot drive persisted in DL by stage 1 boot loader

    mov si, startmsg                    ; place string at stack pointer
    call Print
    
    call load_kernel
    
    call switch_pmode                   ; load gdt and enable pmode
    

BOOT_DRIVE: db 0
KERN_SECTORS: dw 0x0f
KERNEL_OFFSET equ 0x1000

[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET               ; load kernel at 0x1000 in memory
    mov dl, [BOOT_DRIVE]                ; read from boot drive
    mov dh, 0x00                        ; read from side 0
    mov cl, 0x03                        ; read from third sector (after second stage bootloader)
    mov ch, 0x00                        ; read from outmost cylinder
    mov al, [KERN_SECTORS]              ; read 15 sectors
    call ReadSectors

%include './util/pmode.asm'

[bits 32]
start_kern:
    mov ebx, pm
    call print_pmode

    call KERNEL_OFFSET                  ; call kernel (C) code, loaded at specified offset
    
    jmp $
    
;*************************************************;
;	Data section
;*************************************************;

startmsg db "ENTERING SECOND STAGE BOOTLOADER...", 0
pm db "ENTERED 32-BIT PMODE, JUMPING TO KERNEL", 0
