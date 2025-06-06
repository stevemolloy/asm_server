%include "src/linux.inc"
%include "src/server.inc"

%define DEBUG

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
    ZERO_MEM filename,  MAX_FILE_LEN   ; Zero the filename buffer
    ZERO_MEM buffer, BUFF_LEN ; Zero the logging buffer
    mov rax, buffer
    mov [cursor], rax

    ; Accept incoming connections
    WRITE STDOUT, accept_msg, accept_msg_len
    WRITE STDOUT, html_folder, html_folder_len
    WRITE STDOUT, accept_msg_end, accept_msg_end_len
    ACCEPT [sock], 0, 0
    cmp rax, 0
    jl .exit_fail
    mov [client_fd], rax

    ; Read the request.
    WRITE STDOUT, req_recvd_msg, req_recvd_msg_len
    READ [client_fd], [cursor], BUFF_LEN - 1
    WRITE STDOUT, [cursor], BUFF_LEN - 1

    ; Check if this is a GET req. 404 if not.
    mov rdi, [cursor]
    mov rsi, get_req
    mov rdx, get_req_len
    call sized_strcmp
    cmp rax, 0
    jne .send_404

    ; Serve index.html if the request is for "/"
    mov rbx, [cursor]
    add rbx, get_req_len
    mov [cursor], rbx

    xor rax, rax            ; rax = character count
.next_char:
    cmp byte [rbx + rax], ' '
    je .copy_filename
    inc rax
    jmp .next_char

.copy_filename:
    mov rsi, rbx
    lea rdi, [filename]
    mov rsi, html_folder
    mov rcx, html_folder_len
    rep movsb

.empty_req_is_indexhtml:
    cmp rax, 0
    jne .file_from_request
    lea rdi, [filename + html_folder_len]
    mov rsi, index_html_fname
    mov rcx, index_html_fname_len
    rep movsb
    jmp .open_file

.file_from_request:
    mov rsi, [cursor]
    lea rdi, [filename + html_folder_len]
    mov rcx, rax
    rep movsb
    mov byte [rdi], 0

.open_file:
    ; Open the local index.html
%ifdef DEBUG
    WRITE STDOUT, open_index_msg, open_index_msg_len
    WRITE STDOUT, filename, MAX_FILE_LEN
    WRITE STDOUT, newline, newline_len
%endif
    OPEN filename, O_RDONLY, 0
    cmp rax, 0
    jg .fstat_file

    jmp .send_404

.fstat_file:
    ; Figure out how much mem we need to read the file
    mov r13, rax
%ifdef DEBUG
    WRITE STDOUT, fstat_msg, fstat_msg_len
%endif
    FSTAT r13, stat_struct
    mov r12, [stat_struct + ST_SIZE_OFFS]

    ; Alloc that memory
%ifdef DEBUG
    WRITE STDOUT, mmap_msg, mmap_msg_len
%endif
    MMAP 0, r12, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0
    cmp rax, 0
    jg .read_file
    jmp .exit_fail

.read_file:
    ; Read the file into the memory
    mov [contents], rax
%ifdef DEBUG
    WRITE STDOUT, read_index_msg, read_index_msg_len
%endif
    READ r13, [contents], r12

    ; Write the http header and then the index.html to the client
    WRITE STDOUT, write_to_client_msg, write_to_client_msg_len
    WRITE [client_fd], header200, header200_len
    WRITE [client_fd], [contents], r12

    ; Free the memory alloced for the file
%ifdef DEBUG
    WRITE STDOUT, munmap_msg, munmap_msg_len
%endif
    MUNMAP [contents], r12
    jmp .close

.send_404:
    WRITE STDOUT, log_404_msg, log_404_msg_len
    WRITE [client_fd], header404, header404_len

.close:
    ; Close the connection
    WRITE STDOUT, closing_cnxion_msg, closing_cnxion_msg_len
    CLOSE [client_fd]

    ; Loop back to the start to prep for the next client
    jmp .server_loop

.exit_fail:
    WRITE STDERR, err_msg, err_msg_len
    EXIT EXIT_FAILURE

sized_strcmp:
    ; rdi: String 1
    ; rsi: String 2
    ; rdx: N
.loop:
    mov r12, [rdi]
    mov r13, [rsi]
    cmp r12b, r13b
    jne .fail
    dec rdx
    jz .success
    inc rdi
    inc rsi
    jmp .loop
.success:
    xor rax, rax
    ret
.fail:
    mov rax, -1
    ret

section .data
    header200 db "HTTP/1.1 200 OK", 13, 10
           db "Content-Type: text/html", 13, 10, 13, 10
    header200_len equ $ - header200

    header404 db "HTTP/1.1 404 Not Found", 13, 10
    header404_len equ $ - header404

    index_html_fname db "index.html", 0
    index_html_fname_len equ $ - index_html_fname - 1

    socket_msg db "INFO: Creating socket...", 10
    socket_msg_len equ $ - socket_msg

    bind_msg db "INFO: Binding to port...", 10
    bind_msg_len equ $ - bind_msg

    listen_msg db "INFO: Started listening...", 10
    listen_msg_len equ $ - listen_msg

    accept_msg db "INFO: Awaiting connections (serving from folder: "
    accept_msg_len equ $ - accept_msg
    accept_msg_end db ")...", 10
    accept_msg_end_len equ $ - accept_msg_end

    req_recvd_msg db "INFO: Received the following request:", 10, 10
    req_recvd_msg_len equ $ - req_recvd_msg

    open_index_msg db "INFO: Opening file: "
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

    log_404_msg db "INFO: Sending 404...", 10
    log_404_msg_len equ $ - log_404_msg

    err_msg db "ERROR", 10
    err_msg_len equ $ - err_msg

    newline db 10
    newline_len equ $ - newline

    addr.sin_family dw AF_INET
    addr.sin_port dw 36895    ; htons(8080)
    addr.sin_addr dd 0
    addr.sin_zero dq 0
    addr_len equ $ - addr.sin_family

    get_req db "GET /"
    get_req_len equ $ - get_req

    root_req db " "
    root_req_len equ $ - root_req

    html_folder db "html/", 0
    html_folder_len equ $ - html_folder - 1

    indexhtml_req db "index.html"
    indexhtml_req_len equ $ - indexhtml_req

    favicon db "/favicon.ico"
    favicon_len equ $ - favicon

section .bss
    cursor: resq 1
    contents: resq 1
    sock: resd 1
    client_fd: resd 1
    stat_struct: resb 144
    buffer: resb BUFF_LEN
    filename: resb MAX_FILE_LEN

