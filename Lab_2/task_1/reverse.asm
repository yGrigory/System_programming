format ELF executable
entry start

segment readable executable

start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_original
    mov edx, msg_original_len
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, input_string
    mov edx, input_string_len
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_reversed
    mov edx, msg_reversed_len
    int 0x80
    
    mov esi, input_string
    mov ecx, input_string_len
    add esi, ecx
    dec esi                  
    
.reverse_print:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi             
    mov edx, 1              
    int 0x80
    
    dec esi                 
    cmp esi, input_string    
    jae .reverse_print        
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    mov eax, 1
    xor ebx, ebx
    int 0x80

segment readable writeable

msg_original db 'Original: '
msg_original_len = $ - msg_original

msg_reversed db 'Reversed: '
msg_reversed_len = $ - msg_reversed

input_string db 'JhWDOroBVTeXKFUlGWfCQZjNLw', 0
input_string_len = $ - input_string - 1

newline db 10