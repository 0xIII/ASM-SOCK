%include "lib/util.asm"
%include "lib/socket.asm"

SECTION .data
msg     db      "This is a test", 0x0A, 0x00

SECTION .text
global _start

_start:
    jmp     _bindSocket

_bindSocket:
    xor     eax, eax
    call    socket
    
    mov     eax, 0xBEEF
    mov     ebx, 0x0100007F
    call    connect

    mov     eax, msg
    call    printf

    mov     eax, msg
    call    send

    call    exit