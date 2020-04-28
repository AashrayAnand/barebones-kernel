switch_pmode:
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
    mov esp, ebp                            ; place base of stack at end of free space
    
    call start_kern

%include './util/print_pmode.asm'
