format ELF executable
entry start

segment readable executable

start:
    mov esi, number_str
    mov dword [sum], 0

process_digits:
    mov al, [esi]
    test al, al
    jz print_result
    sub al, '0'
    movzx eax, al
    add [sum], eax
    inc esi
    jmp process_digits

print_result:
    mov eax, [sum]
    mov ebx, 10
    mov edi, buffer + 10
    mov byte [edi], 0
    dec edi
    mov byte [edi], 10

convert_loop:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz convert_loop

    mov ecx, edi
    mov edx, buffer + 11
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

segment readable writeable

number_str db '5277616985', 0
sum dd 0
buffer rb 11