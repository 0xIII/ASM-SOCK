;   =================================================================
;   @func       printf          print string stored in eax
;   @param      eax             the address of the string to be printed
;   @return     eax             string register
printf:

    ;   save registers
    push    edx
    push    ecx
    push    ebx
    push    eax

    call    slen
    mov     edx, eax    ; string length

    pop     eax         ; restore string address
    mov     ecx, eax    ; string address

    mov     ebx, 1      ; file descriptor

    mov     eax, 4      ; syscall
    int     0x80

    pop     ebx
    pop     ecx
    pop     edx

    ret

;   =================================================================
;   @func       strlen          print a message using sys_write
;   @param      eax             string address 
;   @return     eax             return string length ain eax
slen:
    push    ebx
    mov     ebx, eax        ; create copy of eax inside ebx
 
nextchar:
    cmp     byte [eax], 0   ; check for nullbyte
    jz      finished
    inc     eax
    jmp     nextchar
 
finished:
    sub     eax, ebx
    pop     ebx             ; restore ebx
    ret

;   ================================================================
;   just exit
exit:
    mov 	ebx, 0
    mov     eax, 1
    int     0x80