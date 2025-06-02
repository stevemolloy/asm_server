%include "src/linux.inc"

%define BACKLOG 16

global _start

section .text
_start:
    SOCKET AF_INET, SOCK_STREAM, 0
    cmp rax, 0
    jl .exit_fail
    mov [sock], rax

    BIND [sock], addr.sin_family, 16
    cmp rax, 0
    jne .exit_fail

    LISTEN [sock], BACKLOG
    cmp rax, 0
    jne .exit_fail

.server_loop:
    ACCEPT [sock], 0, 0
    cmp rax, 0
    jl .exit_fail
    mov [client_fd], rax

    WRITE [client_fd], hello, hello_len

    CLOSE [client_fd]

    jmp .server_loop

.exit_fail:
    WRITE STDERR, fail_msg, fail_msg_len
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
    hello db "HTTP/1.1 200 OK", 13, 10, "Content-Type: text/html", 13, 10, 13, 10, "<html><h1>Hello world from ASM</h1></html>"
    hello_len equ $ - hello

    fail_msg db "ERROR", 10
    fail_msg_len equ $ - fail_msg

    addr.sin_family dw AF_INET
    addr.sin_port dw 36895
    addr.sin_addr dd 0
    addr.sin_zero dq 0

section .bss
    sock: resd 1
    client_fd: resd 1

