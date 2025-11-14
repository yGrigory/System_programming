format ELF64
public _start

section '.data' writeable
usage_msg db "Usage: expr <a> <b> <c>", 10
usage_len = $ - usage_msg
divzero_msg db "Error: division by zero (a == 0)", 10
divzero_len = $ - divzero_msg
newline db 10

section '.bss' writeable
buf rb 32

section '.text' executable align 16

atoi:
    push rbx
    push rcx
    xor rax, rax
    xor rbx, rbx
    mov cl, [rsi]
    cmp cl, '-'
    jne .parse
    mov bl, 1
    inc rsi
.parse:
    mov cl, [rsi]
    test cl, cl
    jz .done
    cmp cl, '0'
    jb .done
    cmp cl, '9'
    ja .done
    imul rax, 10
    sub cl, '0'
    add rax, rcx
    inc rsi
    jmp .parse
.done:
    cmp bl, 1
    jne .ret
    neg rax
.ret:
    pop rcx
    pop rbx
    ret
;(((((a + b) - a) / a) + c) / a)
print_int64:
    push rax
    push rbx
    push rcx
    push rdx
    push r11
    lea rcx, [buf + 32]
    mov rbx, 10
    xor r11, r11
    cmp rax, 0
    jge .convert
    neg rax
    mov r11, 1
.convert:
.ne
