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

;-----------------------------------------
; atoi (rsi = pointer to string)
; returns: rax = signed integer
;-----------------------------------------
atoi:
    push rbx
    push rcx
    xor rax, rax
    xor rbx, rbx           ; rbx=0 means positive
    mov cl, [rsi]
    cmp cl, '-'
    jne .parse
    mov bl, 1              ; negative flag
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

;-----------------------------------------
; print_int64 (rax = value)
;-----------------------------------------
print_int64:
    push rax
    push rbx
    push rcx
    push rdx
    push r11

    lea rcx, [buf + 32]
    mov rbx, 10
    xor r11, r11           ; sign flag
    cmp rax, 0
    jge .convert
    neg rax
    mov r11, 1
.convert:
.next_digit:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .next_digit
    cmp r11, 0
    je .print
    dec rcx
    mov byte [rcx], '-'
.print:
    mov rdx, buf + 32
    sub rdx, rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    syscall

    ; print newline
    mov rax, 1
    mov rdi, 1
    lea rsi, [newline]
    mov rdx, 1
    syscall

    pop r11
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;-----------------------------------------
; main (_start)
;-----------------------------------------
_start:
    mov rdi, [rsp]         ; argc
    cmp rdi, 4
    jl show_usage

    mov rsi, [rsp + 16]    ; argv[1] -> a
    call atoi
    mov r8, rax             ; a

    mov rsi, [rsp + 24]    ; argv[2] -> b
    call atoi
    mov r9, rax             ; b

    mov rsi, [rsp + 32]    ; argv[3] -> c
    call atoi
    mov r10, rax            ; c

    cmp r8, 0
    je div_zero

    ; (((((a+b)-a)/a)+c)/a)
    mov rax, r8
    add rax, r9         ; a+b
    sub rax, r8         ; (a+b)-a
    cqo
    idiv r8             ; /a
    add rax, r10        ; +c
    cqo
    idiv r8             ; /a
    ; результат в RAX

    call print_int64
    jmp exit0

div_zero:
    mov rax, 1
    mov rdi, 1
    lea rsi, [divzero_msg]
    mov rdx, divzero_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

show_usage:
    mov rax, 1
    mov rdi, 1
    lea rsi, [usage_msg]
    mov rdx, usage_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

exit0:
    mov rax, 60
    xor rdi, rdi
    syscall