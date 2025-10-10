section .data
    prompt db "Введите n: "
    prompt_len equ $ - prompt
    result_msg db "Результат: "
    result_len equ $ - result_msg
    newline db 10
    
    n dd 0
    sum dd 0

section .bss
    input_buffer resb 16
    output_buffer resb 16

section .text
    global _start

_start:
    ; Вывод приглашения
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; Ввод n через системный вызов read
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    ; Преобразование строки в число
    mov esi, input_buffer
    xor eax, eax
    xor ebx, ebx
convert_input:
    mov bl, byte [esi]
    cmp bl, 10
    je start_calculation
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp convert_input

start_calculation:
    mov [n], eax
    mov ecx, 1          ; k = 1
    mov dword [sum], 0  ; sum = 0

calculate_loop:
    cmp ecx, [n]
    jg print_result

    ; Вычисляем (-1)^k
    mov eax, ecx
    and eax, 1
    jz positive
    mov ebx, -1
    jmp calc_term
positive:
    mov ebx, 1

calc_term:
    ; Вычисляем k(k+4)(k+8)
    mov eax, ecx
    add eax, 4
    imul eax, ecx
    
    mov edx, ecx
    add edx, 8
    imul eax, edx
    
    imul eax, ebx
    add [sum], eax
    
    inc ecx
    jmp calculate_loop

print_result:
    ; Вывод "Результат: "
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_len
    int 0x80

    ; Преобразование результата в строку
    mov eax, [sum]
    mov edi, output_buffer
    mov ecx, 10
    xor ebx, ebx
    
    test eax, eax
    jns convert_positive
    neg eax
    mov byte [edi], '-'
    inc edi
convert_positive:
    xor edx, edx
    div ecx
    add dl, '0'
    push edx
    inc ebx
    test eax, eax
    jnz convert_positive

pop_digits:
    pop edx
    mov [edi], dl
    inc edi
    dec ebx
    jnz pop_digits
    
    mov byte [edi], 0

    ; Вывод результата
    mov eax, 4
    mov ebx, 1
    mov ecx, output_buffer
    mov edx, 16
    int 0x80

    ; Вывод новой строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Завершение программы
    mov eax, 1
    xor ebx, ebx
    int 0x80