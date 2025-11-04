format ELF64
public _start

section '.data' writable
prompt db "Введите число: "
prompt_len = $ - prompt
true_msg db "Цифры в неубывающем порядке", 10
true_len = $ - true_msg
false_msg db "Цифры НЕ в неубывающем порядке", 10
false_len = $ - false_msg
newline db 10

section '.bss' writable
number rq 1
result rq 1
input_buffer rb 16

section '.text' executable

check_order:
    mov rbx, 10
    mov rcx, 10
.check_loop:
    test rax, rax
    jz .success
    xor rdx, rdx
    div rbx
    cmp rdx, rcx
    jg .failure
    mov rcx, rdx
    jmp .check_loop
.failure:
    mov rax, 0
    ret
.success:
    mov rax, 1
    ret

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
    je .check_number
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .convert_input
.check_number:
    mov [number], rax
    call check_order
    mov [result], rax
    cmp qword [result], 1
    je .print_true
    mov rax, 1
    mov rdi, 1
    lea rsi, [false_msg]
    mov rdx, false_len
    syscall
    jmp .exit
.print_true:
    mov rax, 1
    mov rdi, 1
    lea rsi, [true_msg]
    mov rdx, true_len
    syscall
.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
