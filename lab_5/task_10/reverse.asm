format ELF executable
entry start

segment readable executable

start:
    pop eax
    cmp eax, 3
    jne error

    pop eax
    pop ebx
    mov [input_file], ebx
    pop ebx
    mov [output_file], ebx

    mov eax, 5
    mov ebx, [input_file]
    mov ecx, 0
    int 0x80
    cmp eax, 0
    jl error
    mov [input_fd], eax

    mov eax, 5
    mov ebx, [output_file]
    mov ecx, 0x241
    mov edx, 0644o
    int 0x80
    cmp eax, 0
    jl error
    mov [output_fd], eax

read_loop:
    mov eax, 3
    mov ebx, [input_fd]
    mov ecx, char_buffer
    mov edx, 1
    int 0x80
    cmp eax, 0
    jle process_remaining

    mov al, [char_buffer]
    mov esi, [sentence_pos]
    mov [sentence_buffer + esi], al
    inc esi
    mov [sentence_pos], esi

    cmp al, '.'
    je process_sentence
    cmp al, '!'
    je process_sentence
    cmp al, '?'
    je process_sentence
    cmp esi, 255
    jl read_loop

process_sentence:
    mov esi, [sentence_pos]
    mov byte [sentence_buffer + esi], 0
    call reverse_sentence
    call write_sentence
    mov dword [sentence_pos], 0
    jmp read_loop

process_remaining:
    cmp dword [sentence_pos], 0
    jle close_files
    mov esi, [sentence_pos]
    mov byte [sentence_buffer + esi], 0
    call reverse_sentence
    call write_sentence

close_files:
    mov eax, 6
    mov ebx, [input_fd]
    int 0x80
    mov eax, 6
    mov ebx, [output_fd]
    int 0x80
    mov eax, 1
    xor ebx, ebx
    int 0x80

reverse_sentence:
    mov esi, sentence_buffer
    mov edi, esi
    call strlen
    test eax, eax
    jz .done
    mov edi, esi
    add edi, eax
    dec edi
.reverse_loop:
    cmp esi, edi
    jae .done
    mov al, [esi]
    mov bl, [edi]
    mov [esi], bl
    mov [edi], al
    inc esi
    dec edi
    jmp .reverse_loop
.done:
    ret

write_sentence:
    mov esi, sentence_buffer
    call strlen
    mov edx, eax
    mov eax, 4
    mov ebx, [output_fd]
    mov ecx, sentence_buffer
    int 0x80
    ret

strlen:
    xor eax, eax
.count:
    cmp byte [esi + eax], 0
    je .done
    inc eax
    jmp .count
.done:
    ret

error:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, error_msg_len
    int 0x80
    mov eax, 1
    mov ebx, 1
    int 0x80

segment readable writeable

error_msg db "Error", 10, 0
error_msg_len = $ - error_msg

input_file dd 0
output_file dd 0
input_fd dd 0
output_fd dd 0
sentence_pos dd 0
char_buffer rb 1
sentence_buffer rb 256