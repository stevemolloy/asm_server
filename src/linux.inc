%define SYS_WRITE 1
%define SYS_CLOSE 3
%define SYS_SOCKET 41
%define SYS_ACCEPT 43
%define SYS_BIND 49
%define SYS_LISTEN 50
%define SYS_EXIT 60

%define STDIN  0
%define STDOUT 1
%define STDERR 2

%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

%define AF_INET 2
%define SOCK_STREAM 1
%define IPPROTO_IP 0

%macro SYSCALL1 2
    mov rax, %1
    mov rdi, %2
    syscall
%endmacro

%macro SYSCALL2 3
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    syscall
%endmacro

%macro SYSCALL3 4
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    syscall
%endmacro

%macro SYSCALL4 5
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    syscall
%endmacro

%macro EXIT 1
    SYSCALL1 SYS_EXIT, %1
%endmacro

%macro WRITE 3
    SYSCALL3 SYS_WRITE, %1, %2, %3
%endmacro

%macro SOCKET 3
    SYSCALL3 SYS_SOCKET, %1, %2, %3
%endmacro

%macro BIND 3
    SYSCALL3 SYS_BIND, %1, %2, %3
%endmacro

%macro LISTEN 2
    SYSCALL2 SYS_LISTEN, %1, %2
%endmacro

%macro ACCEPT 3
    SYSCALL3 SYS_ACCEPT, %1, %2, %3
%endmacro

%macro CLOSE 1
    SYSCALL1 SYS_CLOSE, %1
%endmacro

