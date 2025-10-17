format ELF64
public _start

section '.data' writable
    usage_msg    db "Usage: ./reverse <input_file> <output_file>", 10
    usage_len    = $ - usage_msg

    error_msg    db "Error", 10
    error_len    = $ - error_msg

section '.bss'
    input_fd       rq 1
    output_fd      rq 1
    sentence_pos   rq 1
    char_buffer    rb 1
    sentence_buffer rb 256

section '.text' executable

_start:
    ; argc check
    pop rcx
    cmp rcx, 3
    jne show_usage

    pop rsi            ; argv[0]
    pop rdi            ; argv[1] -> input filename
    mov r12, rdi
    pop rdi            ; argv[2] -> output filename
    mov r13, rdi

    ; open input file (O_RDONLY)
    mov rax, 2         ; sys_open
    mov rdi, r12
    xor rsi, rsi       ; O_RDONLY
    syscall
    cmp rax, 0
    jl error
    mov [input_fd], rax

    ; open/create output file (O_CREAT | O_WRONLY | O_TRUNC)
    mov rax, 2
    mov rdi, r13
    mov rsi, 0x241     ; flags
    mov rdx, 0644o     ; mode
    syscall
    cmp rax, 0
    jl error
    mov [output_fd], rax

    mov qword [sentence_pos], 0

read_loop:
    mov rax, 0         ; sys_read
    mov rdi, [input_fd]
    lea rsi, [char_buffer]
    mov rdx, 1
    syscall
    cmp rax, 0
    jle process_remaining

    mov al, [char_buffer]
    mov rbx, [sentence_pos]
    mov [sentence_buffer + rbx], al
    inc qword [sentence_pos]

    cmp al, '.'
    je process_sentence
    cmp al, '!'
    je process_sentence
    cmp al, '?'
    je process_sentence

    mov rax, [sentence_pos]
    cmp rax, 255
    jl read_loop

process_sentence:
    mov rax, [sentence_pos]
    mov byte [sentence_buffer + rax], 0
    call reverse_sentence
    call write_sentence
    mov qword [sentence_pos], 0
    jmp read_loop

process_remaining:
    mov rax, [sentence_pos]
    cmp rax, 0
    je close_files
    mov byte [sentence_buffer + rax], 0
    call reverse_sentence
    call write_sentence

close_files:
    mov rax, 3         ; sys_close
    mov rdi, [input_fd]
    syscall
    mov rax, 3
    mov rdi, [output_fd]
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall

;------------------------------------------
reverse_sentence:
    lea rsi, [sentence_buffer]
    call strlen
    test rax, rax
    jz .done

    mov rcx, rax
    dec rcx
    xor rbx, rbx
.rev_loop:
    cmp rbx, rcx
    jae .done
    mov al, [sentence_buffer + rbx]
    mov dl, [sentence_buffer + rcx]
    mov [sentence_buffer + rbx], dl
    mov [sentence_buffer + rcx], al
    inc rbx
    dec rcx
    jmp .rev_loop
.done:
    ret

;------------------------------------------
write_sentence:
    lea rsi, [sentence_buffer]
    call strlen
    mov rdx, rax
    mov rax, 1         ; sys_write
    mov rdi, [output_fd]
    lea rsi, [sentence_buffer]
    syscall
    ret

;------------------------------------------
strlen:
    xor rax, rax
.len_loop:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .len_loop
.done:
    ret

show_usage:
    mov rax, 1
    mov rdi, 1
    mov rsi, usage_msg
    mov rdx, usage_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

error:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall
