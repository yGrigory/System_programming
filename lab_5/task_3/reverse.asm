format ELF64
public _start

section '.data' writable
    usage_msg db "Usage: ./reverse <input_file> <output_file>", 10
    usage_len = $ - usage_msg

    error_open db "Error: cannot open file", 10
    error_open_len = $ - error_open

    buffer_size equ 4096

section '.bss' writable
    input_fd   dq 0
    output_fd  dq 0
    file_size  dq 0
    file_buffer rb buffer_size

section '.text' executable

_start:
    pop rcx
    cmp rcx, 3
    jne .show_usage

    pop rsi                ; пропустить имя программы
    pop rdi                ; argv[1] = input
    mov r12, rdi
    pop rdi                ; argv[2] = output
    mov r13, rdi

    ; открыть входной файл (O_RDONLY)
    mov rax, 2
    mov rdi, r12
    xor rsi, rsi
    syscall
    cmp rax, 0
    jl .error_open
    mov [input_fd], rax

    ; открыть/создать выходной файл (O_CREAT|O_WRONLY|O_TRUNC)
    mov rax, 2
    mov rdi, r13
    mov rsi, 0x241         ; O_CREAT | O_WRONLY | O_TRUNC
    mov rdx, 0644o
    syscall
    cmp rax, 0
    jl .error_open
    mov [output_fd], rax

    ; читать входной файл
.read_file:
    mov rax, 0
    mov rdi, [input_fd]
    mov rsi, file_buffer
    mov rdx, buffer_size
    syscall
    cmp rax, 0
    jle .reverse_content
    mov [file_size], rax
    jmp .read_file

.reverse_content:
    mov rsi, file_buffer
    mov rdi, file_buffer
    mov rax, [file_size]
    add rdi, rax
    dec rdi

.reverse_loop:
    cmp rsi, rdi
    jae .write_reversed
    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al
    inc rsi
    dec rdi
    jmp .reverse_loop

.write_reversed:
    mov rax, 1
    mov rdi, [output_fd]
    mov rsi, file_buffer
    mov rdx, [file_size]
    syscall

    ; закрыть файлы
    mov rax, 3
    mov rdi, [input_fd]
    syscall
    mov rax, 3
    mov rdi, [output_fd]
    syscall

    jmp .exit_success

.show_usage:
    mov rax, 1
    mov rdi, 1
    mov rsi, usage_msg
    mov rdx, usage_len
    syscall
    jmp .exit_fail

.error_open:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_open
    mov rdx, error_open_len
    syscall
    jmp .exit_fail

.exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall

.exit_fail:
    mov rax, 60
    mov rdi, 1
    syscall
