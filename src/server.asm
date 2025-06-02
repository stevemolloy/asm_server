%include "src/linux.inc"

%define BACKLOG 16

global _start

section .text
_start:
    WRITE STDOUT, socket_msg, socket_msg_len
    SOCKET AF_INET, SOCK_STREAM, 0
    cmp rax, 0
    jl .exit_fail
    mov [sock], rax

    WRITE STDOUT, bind_msg, bind_msg_len
    BIND [sock], addr.sin_family, addr_len
    cmp rax, 0
    jne .exit_fail

    WRITE STDOUT, listen_msg, listen_msg_len
    LISTEN [sock], BACKLOG
    cmp rax, 0
    jne .exit_fail

.server_loop:
    WRITE STDOUT, accept_msg, accept_msg_len
    ACCEPT [sock], 0, 0
    cmp rax, 0
    jl .exit_fail
    mov [client_fd], rax

    WRITE [client_fd], hello, hello_len

    CLOSE [client_fd]

    jmp .server_loop

.exit_fail:
    WRITE STDERR, err_msg, err_msg_len
    EXIT EXIT_FAILURE

strlen:
    xor rax, rax
.loop:
    cmp byte [rdi], 0
    je .done
    inc rax
    inc rdi
    jmp .loop
.done:
    ret
    
section .data
    hello db "HTTP/1.1 200 OK", 13, 10, "Content-Type: text/html", 13, 10, 13, 10, "<html><h1>Hello world from ASM</h1><p>Testing</p></html>"
    hello_len equ $ - hello

    socket_msg db "INFO: Creating socket...", 10
    socket_msg_len equ $ - socket_msg

    bind_msg db "INFO: Binding to port...", 10
    bind_msg_len equ $ - bind_msg

    listen_msg db "INFO: Started listening...", 10
    listen_msg_len equ $ - listen_msg

    accept_msg db "INFO: Awaiting connections...", 10
    accept_msg_len equ $ - accept_msg

    err_msg db "ERROR", 10
    err_msg_len equ $ - err_msg

    addr.sin_family dw AF_INET
    addr.sin_port dw 36895
    addr.sin_addr dd 0
    addr.sin_zero dq 0
    addr_len equ $ - addr.sin_family

section .bss
    sock: resd 1
    client_fd: resd 1

