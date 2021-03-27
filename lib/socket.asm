;   ================================================
;   NOTE:
;       IP_PROTO    0x0
;       SOCK_STREAM 0x1
;       AF_INET     0x2

;   ================================================
;   @func       socket      create socket
;   @return     esi         file descriptor or -1 (ERRNO)
socket:
    ; save registers
    push    ecx
    push    ebx

    ; push bytes for socket specification on stack
    ; in reverse order
    push    DWORD 0x00000000
    push    DWORD 0x00000001
    push    DWORD 0x00000002

    mov     ecx, esp        ; address arguments using esp in ecx
    mov     ebx, 1          ; subroutine socket(2) (https://man7.org/linux/man-pages/man2/socketcall.2.html)
    mov     eax, 102        ; 

    int     0x80
    mov     esi, eax

    lea esp, [esp + 12]     ; pop off 3 DWORDS (3x4B)

    ;   restore ecx and ebx
    pop     ebx
    pop     ecx
    ret

;   ================================================
;   /* Structure describing an Internet (IP) socket address. */
;   #if  __UAPI_DEF_SOCKADDR_IN
;   #define __SOCK_SIZE__	16		/* sizeof(struct sockaddr)	*/
;   struct sockaddr_in {
;       __kernel_sa_family_t	sin_family;	/* Address family		*/
;       __be16		sin_port;	/* Port number			*/
;       struct in_addr	sin_addr;	/* Internet address		*/
;
;   /* Pad to size of `struct sockaddr'. */
;   unsigned char		__pad[__SOCK_SIZE__ - sizeof(short int) -
;	    sizeof(unsigned short int) - sizeof(struct in_addr)];
;   };
;   ================================================
;   @func       bind        bind socket to address
;   @param      eax         port
;   @param      esi         socket descriptor
;   @return     void
bind:
    ;   save registers
    push    ecx
    push    ebx

    ;   push padding 2x 4B
    push    DWORD 0x00000000
    push    DWORD 0x00000000

    ;   push in_addr sin_addr (4B)
    push    DWORD 0x00000000

    ;   push __be16 sin_port (2B)
    push    ax                  ;   port (word) stored in eax 

    ;   push __kernel_sa_family_t sin_family (2B)
    push    WORD 0x0002         ;   address family AF_INET

    ;   arguments to bind
    mov     ecx, esp
    push    DWORD 0x00000010    ;   size of the sockaddr_in
    push    ecx                 ;   address of arguments
    push    esi                 ;   socket descriptor


    ;   call bind
    mov     ebx, 2              ;   subroutine bind(2)
    mov     eax, 102            ;   socketcall()
    int     0x80

    ;   restore stack
    lea     esp, [esp + 28]     ; 16B for struct + 4B size + 2*4B for address and socket descriptor

    ;   restore registers
    pop     ebx
    pop     ecx
    ret

;   ================================================
;   @func       listen      listen for incoming connections 
;   @param      esi         socket descriptor
;   @return     void
listen:

    push    ecx
    push    ebx
    push    eax

    ;   push arguments for listen
    push    DWORD 0x00000000    ;   backlog
    push    esi                 ;   socket descriptor

    mov     ecx, esp            ;   address of arguments

    ;   call listen
    mov     ebx, 4              ;   subroutine listen()
    mov     eax, 102            ;   socketcall()
    int     0x80

    lea     esp, [esp + 8]       ;   realign stack

    pop     eax
    pop     ebx
    pop     ecx
    
    ret

;   ================================================
;   @func       connect     connect to address
;   @param      eax         address (WORD)
;   @param      ebx         port (WORD)
;   @paran      esi         socket descriptor
;   @return
connect:

    push    ecx

    ;   push padding of 2*DWORD onto stack (8B)
    push    DWORD 0x00000000
    push    WORD 0x0000

    ;   push in_addr sin_addrs (2B)
    push    ax

    ;   push __be16 sin_port (4B)
    push    ebx

    ;   push __kernel_sa_family_t sin_family (4B)
    push    DWORD 0x00000001

    mov     ecx, esp                    ;   save address of arguments

    push    DWORD 0x000000010           ;   push size of arguments (4B)
    push    ecx                         ;   push address of arguments (4B)
    push    esi                         ;   push socket descriptor (4B)
    
    ;   connect(2)
    mov     ebx, 3
    mov     eax, 102
    int     0x80

    lea     esp, [esp + 28]

    pop     ecx

    ret

;   ================================================
;   ssize_t send(int sockfd, const void *buf, size_t len, int flags);
;   ================================================
;   @func       send        send via socket
;   @param      eax         address of message
;   @param      esi         socket descriptor
;   @return
send:

    push    edx
    push    ecx
    push    ebx

    mov     ebx, eax            ;   save eax for later use as address

    call    slen

    push    DWORD 0x00000000    ;   push flags                      (4B)
    push    eax                 ;   push size of string from slen   (4B)
    push    ebx                 ;   push address of string          (4B)
    push    esi                 ;   push socket descriptor          (4B)

    mov     ebx, 9
    mov     eax, 102
    int     0x80

    lea     esp, [esp + 16]

    pop     ebx
    pop     ecx
    pop     eax
    ret