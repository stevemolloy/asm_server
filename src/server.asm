%include "src/linux.inc"

%define BACKLOG 16

global _start

section .text
_start:
    ; Create the socket
    WRITE STDOUT, socket_msg, socket_msg_len
    SOCKET AF_INET, SOCK_STREAM, 0
    cmp rax, 0
    jl .exit_fail
    mov [sock], rax

    ; Bind it to port 8080
    WRITE STDOUT, bind_msg, bind_msg_len
    BIND [sock], addr.sin_family, addr_len
    cmp rax, 0
    jne .exit_fail

    ; Start listening for incoming connections
    WRITE STDOUT, listen_msg, listen_msg_len
    LISTEN [sock], BACKLOG
    cmp rax, 0
    jne .exit_fail

.server_loop:
    ; Accept incoming connections
    WRITE STDOUT, accept_msg, accept_msg_len
    ACCEPT [sock], 0, 0
    cmp rax, 0
    jl .exit_fail
    mov [client_fd], rax

    ; Read the request. Close if the request is for the favicon
    READ [client_fd], buffer, 2047
    cmp byte [buffer+5], 102    ; f
    je .close
    WRITE STDOUT, buffer, 2047

.open_file:
    ; Open the local index.html
    WRITE STDOUT, open_index_msg, open_index_msg_len
    OPEN index_html_fname, O_RDONLY, 0
    cmp rax, 0
    jg .fstat_file
    jmp .exit_fail

.fstat_file:
    ; Figure out how much mem we need to read the file
    mov r13, rax
    WRITE STDOUT, fstat_msg, fstat_msg_len
    FSTAT r13, stat_struct
    mov r12, [stat_struct + ST_SIZE_OFFS]

    ; Alloc that memory
    WRITE STDOUT, mmap_msg, mmap_msg_len
    MMAP 0, r12, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0
    cmp rax, 0
    jg .read_file
    jmp .exit_fail

.read_file:
    ; Read the file into the memory
    mov [contents], rax
    WRITE STDOUT, read_index_msg, read_index_msg_len
    READ r13, [contents], r12

    ; Write the http header and then the index.html to the client
    WRITE STDOUT, write_to_client_msg, write_to_client_msg_len
    WRITE [client_fd], header, header_len
    WRITE [client_fd], [contents], r12

    ; Free the memory alloced for the file
    WRITE STDOUT, munmap_msg, munmap_msg_len
    MUNMAP [contents], r12

.close:
    ; Close the connection
    WRITE STDOUT, closing_cnxion_msg, closing_cnxion_msg_len
    CLOSE [client_fd]

    ; Loop back to the start to prep for the next client
    jmp .server_loop

.exit_fail:
    WRITE STDERR, err_msg, err_msg_len
    EXIT EXIT_FAILURE

section .data
    header db "HTTP/1.1 200 OK", 13, 10
           db "Content-Type: text/html", 13, 10, 13, 10
    header_len equ $ - header
    index_html_fname db "src/index.html", 0

    socket_msg db "INFO: Creating socket...", 10
    socket_msg_len equ $ - socket_msg

    bind_msg db "INFO: Binding to port...", 10
    bind_msg_len equ $ - bind_msg

    listen_msg db "INFO: Started listening...", 10
    listen_msg_len equ $ - listen_msg

    accept_msg db "INFO: Awaiting connections...", 10
    accept_msg_len equ $ - accept_msg

    open_index_msg db "INFO: Opening index.html...", 10
    open_index_msg_len equ $ - open_index_msg

    fstat_msg db "INFO: Fstating index.html...", 10
    fstat_msg_len equ $ - fstat_msg

    mmap_msg db "INFO: Mapping memory for the file...", 10
    mmap_msg_len equ $ - mmap_msg

    read_index_msg db "INFO: Reading index.html...", 10
    read_index_msg_len equ $ - read_index_msg

    write_to_client_msg db "INFO: Sending data to client...", 10
    write_to_client_msg_len equ $ - write_to_client_msg

    munmap_msg db "INFO: Unmapping the memory...", 10
    munmap_msg_len equ $ - munmap_msg

    closing_cnxion_msg db "INFO: Closing the connection to the client...", 10
    closing_cnxion_msg_len equ $ - closing_cnxion_msg

    err_msg db "ERROR", 10
    err_msg_len equ $ - err_msg

    addr.sin_family dw AF_INET
    addr.sin_port dw 36895    ; htons(8080)
    addr.sin_addr dd 0
    addr.sin_zero dq 0
    addr_len equ $ - addr.sin_family

section .bss
    contents: resq 1
    sock: resd 1
    client_fd: resd 1
    stat_struct: resb 144
    buffer: resb 2048

