section .data
    prompt db "Введите количество судей: "
    prompt_len equ $ - prompt
    vote_prompt db "Введите голос (1-Да, 0-Нет) для судьи "
    vote_len equ $ - vote_prompt
    colon db ": "
    colon_len equ $ - colon
    yes_msg db "Решение: ДА", 10
    yes_len equ $ - yes_msg
    no_msg db "Решение: НЕТ", 10
    no_len equ $ - no_msg
    newline db 10
    
    n dd 0
    yes_count dd 0
    current_judge dd 1

section .bss
    input_buffer resb 16
    judge_num_buffer resb 8

section .text
    global _start

; Функция преобразования числа в строку
; eax - число, edi - буфер
itoa:
    mov ecx, 10
    xor ebx, ebx
    
    test eax, eax
    jnz convert
    mov byte [edi], '0'
    inc edi
    jmp done
    
convert:
    xor edx, edx
    div ecx
    add dl, '0'
    push edx
    inc ebx
    test eax, eax
    jnz convert
    
pop_loop:
    pop edx
    mov [edi], dl
    inc edi
    dec ebx
    jnz pop_loop
    
done:
    mov byte [edi], 0
    ret

_start:
    ; Ввод количества судей
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
convert_n:
    mov bl, byte [esi]
    cmp bl, 10
    je start_voting
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp convert_n

start_voting:
    mov [n], eax
    mov dword [current_judge], 1
    mov dword [yes_count], 0

vote_loop:
    mov eax, [current_judge]
    cmp eax, [n]
    jg count_votes

    ; Вывод приглашения для голоса
    mov eax, 4
    mov ebx, 1
    mov ecx, vote_prompt
    mov edx, vote_len
    int 0x80

    ; Вывод номера судьи
    mov eax, [current_judge]
    mov edi, judge_num_buffer
    call itoa
    
    ; Вывод номера
    mov eax, 4
    mov ebx, 1
    mov ecx, judge_num_buffer
    mov edx, 8
    int 0x80

    ; Вывод ": "
    mov eax, 4
    mov ebx, 1
    mov ecx, colon
    mov edx, colon_len
    int 0x80

    ; Ввод голоса
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    ; Преобразование голоса
    mov esi, input_buffer
    xor eax, eax
    mov al, byte [esi]
    sub al, '0'
    
    cmp eax, 1
    jne next_vote
    inc dword [yes_count]

next_vote:
    inc dword [current_judge]
    jmp vote_loop

count_votes:
    ; Принятие решения
    mov eax, [yes_count]
    mov ebx, [n]
    shr ebx, 1
    
    cmp eax, ebx
    jg decision_yes
    
    ; Решение "НЕТ"
    mov eax, 4
    mov ebx, 1
    mov ecx, no_msg
    mov edx, no_len
    int 0x80
    jmp exit

decision_yes:
    ; Решение "ДА"
    mov eax, 4
    mov ebx, 1
    mov ecx, yes_msg
    mov edx, yes_len
    int 0x80

exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80