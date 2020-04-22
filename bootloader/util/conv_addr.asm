;*************************************************;
;	Convert CHS to LBA
;   LBA = (Cluster - 2) * sectors_per_cluster
;*************************************************;

ClusterLBA:
    
    sub ax, 0x0002                   ; cluster in ax
    xor cx, cx                       ; reset cx
    mov cl, BYTE [bpbSectorsPerCluster]
    mul cx                           ; multiply by number of sectors per cluster
    add ax, [datasector]             ; add base data sector to block index, to get overall disk index
    ret
    
;*************************************************;
;	convert LBA to CHS
;   abs. sector = (LBA % sectors per track) + 1
;   abs. head = (LBA / sectors per track) % num heads
;   abs. track = LBA / (sectors per track * num. heads);
;*************************************************;

LBACHS:

    xor dx, dx                       ; prepare dx:ax
    div WORD [bpbSectorsPerTrack]    ; divide ax by sectors per track
    inc dl                           ; increment dx (remainder) low 8 bits
    mov BYTE [absoluteSector], dl    ; store as abs. sector
    
    xor dx, dx                       ; prepare dx:ax for operation
    div WORD [bpbHeadsPerCylinder]   ; divide ax by heads per cylinder
    mov BYTE [absoluteHead], dl      ; remained is abs. head
    mov BYTE [absoluteTrack], al     ; dividen is abs. track
    ret
