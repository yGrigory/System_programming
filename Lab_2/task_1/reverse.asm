section .data
    str db "JhWDOroBVTeXKFUlGWfCQZjNLw", 0   ; строка (null-terminated)

section .text
    global _start

_start:
    ; найти длину строки
    mov rdi, str
    xor rcx, rcx
.len_loop:
    cmp byte [rdi+rcx], 0
    je .len_done
    inc rcx
    jmp .len_loop
.len_done:
    mov rsi, rcx          ; длина строки в rsi

    ; выводить по одному символу с конца
.print_loop:
    dec rsi
    mov al, [rdi+rsi]     ; берём символ
    mov rdx, 1
    mov rsi, rsp
    push rax              ; временно кладём символ в стек
    mov rdi, 1            ; stdout
    mov rax, 1            ; sys_write
    syscall
    pop rax               ; убрать символ со стека
    test rsi, rsi
    jnz .print_loop

    ; завершение программы
    mov rax, 60
    xor rdi, rdi
    syscall
