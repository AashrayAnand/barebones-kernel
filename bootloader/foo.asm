/*
;*************************************************;
;	Load Root Directory
;   
;*************************************************;

mov si, loading
call Print

LOAD_ROOT:
                                        ; 1. get root directory size, store in cx
    xor cx, cx                       ; clear register for storing root dir.
    xor dx, dx
    mov ax, 0x0020                   ; 32 byte directory entries
    mul WORD [bpbRootEntries]        ; root dir. size in bytes
    div WORD [bpbBytesPerSector]     ; root dir. size in sectors
    xchg ax, cx
                                        ; 2. get start of root directory, store in ax
    mov al, BYTE [bpbNumberOfFATs]   ; store number of FAT tables
    mul WORD [bpbSectorsPerFAT]      ; get total sectors in FAT tables
    add ax, WORD [bpbReservedSectors]; add reserved sectors
    mov WORD [datasector], ax        ; get data sector location from root
    add WORD [datasector], cx        ; dir. base + root dir size
                
                                        ; 3. load root directory into memory
    mov bx, 0x0200                   ; load root dir. at 0x7c00:0x0200
    call ReadSectors                 ; right above boot loader

;*************************************************;
;	Find second stage bootloader
;   
;*************************************************;

    mov cx, WORD [bpbRootEntries]   ; should loop over # of root entries
    mov di, 0x0200                  ; 0x0200 is head of root dir. in memory
.LOOP:
    push cx                         ; store cx on stack
    mov cx, 0x000B                  ; cx is # of bytes compared by compsb (11)
    mov si, ImageName               ; image name to find
    push di                         ; store root dir. current addr. on stack
rep cmpsb                           ; test current file name (di) matches expected (si)
    pop di                          ; restore address of current entry
    je LOAD_FAT                     ; load FAT if found file
    add di, 0x20                    ; add 32 bytes to current root entry address
    pop cx                          ; restore remaining number of entries
    loop .LOOP                      ; loop again (decrement cx) if cx > 0
    jmp FAILURE                     ; jump to failure if file not found

;*************************************************;
;	Load FAT
;   
;*************************************************;

mov si, loading
call Print

LOAD_FAT:
                                        ; 1. get/store first cluster of boot image
    mov dx, WORD [di + 0x001A]       ; get first cluster of file from 26th byte of entry
    mov WORD [cluster], dx           ; store first cluster of file
    
                                        ; 2. compute FAT size and store in cx
    xor ax, ax                       ; clear ax
    mov al, BYTE [bpbNumberOfFATs]   ; get number of FATs
    mul WORD [bpbSectorsPerFAT]      ; get FAT size in sectors
    mov cx, ax                       ; load FAT at 0x0200 in memory
        
                                        ; 3. store FAT location in ax
    mov ax, WORD [bpbReservedSectors]; FAT follows reserved sectors
    
                                        ; 4. set location in memory to load FAT in mem.
    mov bx, 0x0200                   ; (bx) and load into memory), should be at 512th
    call ReadSectors                 ; byte so it is above boot loader (0x7c00:0x0000)
    
                                        ; 5. read image file into memory
    mov ax, 0x0050
    mov es, ax                       ; destination for image
    mov bx, 0x0000                   ; destination for image
    push bx

mov si, loading
call Print

LOAD_IMAGE:
    
    mov ax, WORD [cluster]           ; cluster to read
    pop bx                           ; buffer to read to
    call ClusterLBA                  ; convert cluster to LBA
    xor cx, cx
    mov cl, BYTE [bpbSectorsPerCluster]; # of sectors to read
    call ReadSectors
    push bx

FAILURE:
    mov si, failed
    call Print

hlt
    
;*************************************************;
;	Data
;   
;*************************************************;

failed db "Failed to load second stage bootloader"
loading db "loading ..."

absoluteHead   db 0
absoluteSector db 0
absoluteTrack  db 0

datasector     dw 0x0000             ; data sector head, will derive from head of root dir.
cluster        dw 0x0000             ; second stage bootloader file cluster head (defined using LBA)
ImageName      db "STAGE2  SYS"      ; pad string with spaces for name (if < 8 bytes) and extension (if < 3 bytes)
msg            db "Welcome to Aashray's OS!", 0
msgFail        db "Failed to load...", 0

times 510 - ($ - $$) db 0            ; bootloader must be one sector (512 bytes)
                                        ; in size, clear rest of bytes with 0
                                        ; $ is address of current line
                                        ; $$ is address of first instruction
                                        ; $ - $$ returns bytes from start to
                                        ; the current instructions
                                        ; only fill up to 510th byte to leave
                                        ; 2 bytes of space for boot signatures
                        
dw 0xAA55                            ; boot signature, BIOS knows disk is bootable if
                                        ; 511th and 512th bytes of boot sector are AA and 55*/
