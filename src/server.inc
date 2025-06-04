%macro ZERO_MEM 2
    mov rdi, %1
    mov rcx, %2
    xor rax, rax
    rep stosb    ; stosb stores the value of RAX to the location pointed to by RDI and increments RDI
                 ; rep repeats this while RCX!=0, decrementing RCX each time
%endmacro

%define BACKLOG 16
%define BUFF_LEN 2048

