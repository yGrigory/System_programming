section .data
    msg_n db "Enter N: ", 0
    msg_input db "Enter input filename: ", 0
    msg_output db "Enter output filename: ", 0
    msg_done db "Done! Check output file.", 10, 0
    error_file db "Error: Cannot open file", 10, 0
    newline db 10, 0
    space db " ", 0

section .bss
    n resd 1
    input_file resb 32
    output_file resb 32
    buffer resb 256
    number_buf resb 16
    input_fd resd 1
    output_fd resd 1
    primes resd 10000

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 9
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 256
    int 0x80
    
    mov esi, buffer
    call string_to_int
    mov [n], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, 22
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, input_file
    mov edx, 32
    int 0x80
    
    mov edi, input_file
    call remove_newline
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_output
    mov edx, 23
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, output_file
    mov edx, 32
    int 0x80
    
    mov edi, output_file
    call remove_newline
    
    call generate_primes_to_file
    call filter_primes_ending_with_one
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_done
    mov edx, 23
    int 0x80
    
    mov eax, 1
    xor ebx, ebx
    int 0x80

remove_newline:
    mov al, [edi]
    test al, al
    jz .done
    cmp al, 10
    je .found
    inc edi
    jmp remove_newline
.found:
    mov byte [edi], 0
.done:
    ret

string_to_int:
    xor eax, eax
    xor ebx, ebx
.convert:
    mov bl, [esi]
    cmp bl, 10
    je .done
    cmp bl, 0
    je .done
    cmp bl, '0'
    jb .error
    cmp bl, '9'
    ja .error
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .convert
.error:
    mov eax, 4
    mov ebx, 2
    mov ecx, error_file
    mov edx, 24
    int 0x80
    mov eax, 1
    mov ebx, 1
    int 0x80
.done:
    ret

int_to_string:
    mov edi, number_buf
    add edi, 15
    mov byte [edi], 0
    dec edi
    mov byte [edi], 10
    dec edi
    mov ebx, 10
    mov ecx, eax
.convert:
    mov eax, ecx
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    mov ecx, eax
    test eax, eax
    jnz .convert
    inc edi
    ret

is_prime:
    cmp eax, 2
    jl .not_prime
    je .prime
    test eax, 1
    jz .not_prime
    mov ebx, 3
.loop:
    mov ecx, ebx
    imul ecx, ecx
    cmp ecx, eax
    ja .prime
    xor edx, edx
    div ebx
    test edx, edx
    jz .not_prime
    mov eax, [esp+4]
    add ebx, 2
    jmp .loop
.prime:
    mov eax, 1
    ret
.not_prime:
    xor eax, eax
    ret

generate_primes_to_file:
    mov eax, 5
    mov ebx, input_file
    mov ecx, 0x241
    mov edx, 0644o
    int 0x80
    cmp eax, 0
    jl .error
    mov [input_fd], eax
    
    mov esi, primes
    mov dword [esi], 2
    add esi, 4
    
    mov ecx, 3
.generate_loop:
    cmp ecx, [n]
    ja .write_file
    mov eax, ecx
    push ecx
    call is_prime
    pop ecx
    test eax, eax
    jz .next
    mov [esi], ecx
    add esi, 4
.next:
    inc ecx
    jmp .generate_loop

.write_file:
    mov edi, primes
.write_loop:
    cmp edi, esi
    jae .close
    mov eax, [edi]
    call int_to_string
    mov eax, 4
    mov ebx, [input_fd]
    mov ecx, edi
    push esi
    mov esi, edi
    call strlen
    mov edx, eax
    mov eax, 4
    int 0x80
    pop esi
    mov eax, 4
    mov ebx, [input_fd]
    mov ecx, space
    mov edx, 1
    int 0x80
    add edi, 4
    jmp .write_loop

.close:
    mov eax, 6
    mov ebx, [input_fd]
    int 0x80
    ret
.error:
    mov eax, 4
    mov ebx, 2
    mov ecx, error_file
    mov edx, 24
    int 0x80
    mov eax, 1
    mov ebx, 1
    int 0x80

filter_primes_ending_with_one:
    mov eax, 5
    mov ebx, input_file
    mov ecx, 0
    mov edx, 0
    int 0x80
    cmp eax, 0
    jl .error
    mov [input_fd], eax
    
    mov eax, 5
    mov ebx, output_file
    mov ecx, 0x241
    mov edx, 0644o
    int 0x80
    cmp eax, 0
    jl .error
    mov [output_fd], eax

.read_loop:
    mov eax, 3
    mov ebx, [input_fd]
    mov ecx, buffer
    mov edx, 256
    int 0x80
    cmp eax, 0
    jle .close
    
    mov esi, buffer
.process_buffer:
    cmp byte [esi], 0
    je .read_loop
    call parse_number
    test eax, eax
    jz .next_char
    mov ebx, 10
    xor edx, edx
    div ebx
    cmp edx, 1
    jne .next_char
    mov eax, [esp-4]
    call int_to_string
    mov ecx, edi
    call strlen
    mov edx, eax
    mov eax, 4
    mov ebx, [output_fd]
    int 0x80
    mov eax, 4
    mov ebx, [output_fd]
    mov ecx, space
    mov edx, 1
    int 0x80
.next_char:
    inc esi
    jmp .process_buffer

.close:
    mov eax, 6
    mov ebx, [input_fd]
    int 0x80
    mov eax, 6
    mov ebx, [output_fd]
    int 0x80
    ret
.error:
    mov eax, 4
    mov ebx, 2
    mov ecx, error_file
    mov edx, 24
    int 0x80
    mov eax, 1
    mov ebx, 1
    int 0x80

parse_number:
    xor eax, eax
    xor ebx, ebx
.parse_loop:
    mov bl, [esi]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .parse_loop
.done:
    ret

strlen:
    mov ecx, 0
.count:
    cmp byte [edi + ecx], 0
    je .done
    inc ecx
    jmp .count
.done:
    mov eax, ecx
    ret