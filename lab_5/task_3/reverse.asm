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

read_file:
    mov eax, 3
    mov ebx, [input_fd]
    mov ecx, file_buffer
    mov edx, 4096
    int 0x80
    cmp eax, 0
    jle reverse_content
    mov [file_size], eax
    jmp read_file

reverse_content:
    mov esi, file_buffer
    mov edi, file_buffer
    add edi, [file_size]
    dec edi

reverse_loop:
    cmp esi, edi
    jae write_reversed
    mov al, [esi]
    mov bl, [edi]
    mov [esi], bl
    mov [edi], al
    inc esi
    dec edi
    jmp reverse_loop

write_reversed:
    mov eax, 4
    mov ebx, [output_fd]
    mov ecx, file_buffer
    mov edx, [file_size]
    int 0x80

    mov eax, 6
    mov ebx, [input_fd]
    int 0x80

    mov eax, 6
    mov ebx, [output_fd]
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

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

error_msg db "Error: usage: ./reverse input.txt output.txt", 10, 0
error_msg_len = $ - error_msg

input_file dd 0
output_file dd 0
input_fd dd 0
output_fd dd 0
file_size dd 0
file_buffer rb 4096