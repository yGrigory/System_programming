section .data
    prompt db "Введите число: "
    prompt_len equ $ - prompt
    true_msg db "Цифры в неубывающем порядке", 10
    true_len equ $ - true_msg
    false_msg db "Цифры НЕ в неубывающем порядке", 10
    false_len equ $ - false_msg
    newline db 10
    
    number dd 0
    result dd 0

section .bss
    input_buffer resb 16

section .text
    global _start

; Функция проверки неубывающего порядка
; eax - число
; возвращает eax = 1 (true) или 0 (false)
check_order:
    mov ebx, 10
    mov ecx, 10     ; предыдущая цифра
    
check_loop:
    test eax, eax
    jz success
    
    xor edx, edx
    div ebx
    
    cmp edx, ecx
    jg failure
    
    mov ecx, edx
    jmp check_loop

failure:
    mov eax, 0
    ret

success:
    mov eax, 1
    ret

_start:
    ; Ввод числа
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    ; Преобразование в число
    mov esi, input_buffer
    xor eax, eax
    xor ebx, ebx
convert_input:
    mov bl, byte [esi]
    cmp bl, 10
    je check_number
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp convert_input

check_number:
    mov [number], eax
    call check_order
    mov [result], eax

    ; Вывод результата
    cmp dword [result], 1
    je print_true

    ; Вывод false
    mov eax, 4
    mov ebx, 1
    mov ecx, false_msg
    mov edx, false_len
    int 0x80
    jmp exit

print_true:
    ; Вывод true
    mov eax, 4
    mov ebx, 1
    mov ecx, true_msg
    mov edx, true_len
    int 0x80

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80