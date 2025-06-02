%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_FSTAT 5
%define SYS_MMAP 9
%define SYS_MUNMAP 11
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

%define O_RDONLY 0
%define ST_SIZE_OFFS 48

%define PROT_READ     1
%define PROT_WRITE    2
%define MAP_PRIVATE   2
%define MAP_ANONYMOUS 32

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

%macro SYSCALL5 6
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8, %6
    syscall
%endmacro

%macro SYSCALL6 7
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    mov r10, %5
    mov r8, %6
    mov r9, %7
    syscall
%endmacro

%macro EXIT 1
    SYSCALL1 SYS_EXIT, %1
%endmacro

%macro READ 3
    SYSCALL3 SYS_READ, %1, %2, %3
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

%macro OPEN 3
    SYSCALL3 SYS_OPEN, %1, %2, %3
%endmacro

%macro FSTAT 2
    SYSCALL2 SYS_FSTAT, %1, %2
%endmacro

%macro MMAP 6
    SYSCALL6 SYS_MMAP, %1, %2, %3, %4, %5, %6
%endmacro

%macro MUNMAP 2
    SYSCALL2 SYS_MUNMAP, %1, %2
%endmacro

