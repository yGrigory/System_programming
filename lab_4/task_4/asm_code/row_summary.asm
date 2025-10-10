format ELF64
public _start

section '.data' writable
    prompt      db "Введите n: "
    prompt_len  = $ - prompt
    result_msg  db "Результат: "
    result_len  = $ - result_msg
    newline     db 10

section '.bss'
    n       rq 1
    sum     rq 1
    input_buffer  rb 16
    output_buffer rb 32

section '.text' executable

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [prompt]
    mov rdx, prompt_len
    syscall

    mov rax, 0
    mov rdi, 0
    lea rsi, [input_buffer]
    mov rdx, 16
    syscall

    lea rsi, [input_buffer]
    xor rax, rax
    xor rbx, rbx
.convert_input:
    mov bl, [rsi]
    cmp bl, 10
    je .done_convert
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .convert_input
.done_convert:
    mov [n], rax

    mov rcx, 1
    mov qword [sum], 0

.calculate_loop:
    cmp rcx, [n]
    jg .print_result

    mov rax, rcx
    and rax, 1
    jz .positive
    mov rbx, -1
    jmp .calc_term
.positive:
    mov rbx, 1

.calc_term:
    mov rax, rcx
    mov rdx, rax
    add rdx, 4
    imul rax, rdx
    mov rdx, rcx
    add rdx, 8
    imul rax, rdx
    imul rax, rbx
    add [sum], rax

    inc rcx
    jmp .calculate_loop

.print_result:
    mov rax, 1
    mov rdi, 1
    lea rsi, [result_msg]
    mov rdx, result_len
    syscall

    mov rax, [sum]
    lea rdi, [output_buffer]
    mov rcx, 10
    xor rbx, rbx
    mov r8, rdi

    test rax, rax
    jns .convert_positive
    neg rax
    mov byte [rdi], '-'
    inc rdi
.convert_positive:
    mov rcx, 10
    xor rbx, rbx

.convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    push rdx
    inc rbx
    test rax, rax
    jnz .convert_loop

.pop_digits:
    mov rdi, r8
    test byte [r8], '-'
    jz .no_minus
    inc rdi
.no_minus:
.pop_loop:
    pop rdx
    mov [rdi], dl
    inc rdi
    dec rbx
    jnz .pop_loop
    mov byte [rdi], 0

    mov rdx, rdi
    sub rdx, r8

    mov rax, 1
    mov rdi, 1
    lea rsi, [output_buffer]
    and rsp, -16
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall