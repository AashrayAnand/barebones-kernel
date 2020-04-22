org 0x7e00                                  ; offset to 512 bytes past stage 1 bootloader, 0x7c00

bits 16                                     ; still in 16 bit real mode

jmp main                                    ; jump to main

%include './util/print.asm'
%include './util/init_gdt.asm'
;*************************************************;
;	Second-stage bootloader entry point
;*************************************************;
main:
    mov si, startmsg                             ; place string at stack pointer
    call Print
    
    SWITCH_PMODE:
        cli                                 ; no BIOS interrupts in pmode
        lgdt [gdt_descriptor]               ; load global descriptor table
        mov eax, cr0                        ; store control register in eax
        or eax, 0x1                         ; set first bit of eax
        mov cr0, eax                        ; move eax to control register to set first bit and enter pmode
        jmp CODE_SEG:init_pmode             ; execute far jump to flush pipeline before entering pmode
    
[bits 32]
init_pmode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov ebp, 0x90000                          
    mov esp, ebp                            ; place stack pointer at top of free space
    
    call start_pmode

%include './util/print_pmode.asm'

[bits 32]
start_pmode:
    mov ebx, pm
    call print_pmode
    jmp $
    
;*************************************************;
;	Data section
;*************************************************;

startmsg db "ENTERING SECOND STAGE BOOTLOADER...", 0
pm db "ENTERING 32-BIT PMODE", 0
