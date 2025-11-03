format ELF executable
entry start

segment readable executable

start:
    mov edi, buffer
    mov ecx, N
    mov al, [symbol]
.fill_loop:
    mov [edi], al
    inc edi
    loop .fill_loop

    mov esi, buffer
    mov ebx, K
    
.row_loop:
    mov ecx, M
    
.col_loop:
    push ebx
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, 1
    int 0x80
    pop ecx
    pop ebx
    
    inc esi
    loop .col_loop
    
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    pop ebx
    
    dec ebx
    jnz .row_loop
    
    mov eax, 1
    xor ebx, ebx
    int 0x80

segment readable writeable

N = 66
M = 6
K = 11

symbol db '+'
newline db 10
buffer rb N