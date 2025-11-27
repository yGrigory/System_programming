format ELF64
include 'func.asm'

public _start

ARRLEN = 891

section '.bss' writable
    array rb ARRLEN
    buffer rb 10
    f db "/dev/random", 0
    msg1 db "Медиана (округленная до целого):", 0xA, 0
    msg2 db "Количество простых:", 0xA, 0
    msg3 db "Количество чисел кратных пяти:", 0xA, 0
    msg4 db "Среднее арифметическое значение (округленное до целого):", 0xA, 0
    space db " ", 0

section '.text' executable
_start:
    mov rax, 9   
    xor rdi, rdi     
    mov rsi, ARRLEN  
    mov rdx, 3       
    mov r10, 0x22   
    mov r8, -1        
    xor r9, r9        
    syscall
    
    mov r15, rax    

    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    mov r8, rax

    mov rax, 0
    mov rdi, r8
    mov rsi, r15     
    mov rdx, ARRLEN
    syscall

    mov rsi, r15
    mov rdi, array
    mov rcx, ARRLEN
    rep movsb

    .filter_loop:
        call filter
        cmp rax, 0
        jne .filter_loop

    mov rax, 11        
    mov rdi, r15      
    mov rsi, ARRLEN    
    syscall

    mov rcx, ARRLEN
    .print:
        xor rax, rax
        mov al, [array + rcx - 1]
        mov rsi, buffer
        call number_str
        call print_str
        mov rsi, space
        call print_str
        dec rcx
        jnz .print
    call new_line

    mov rax, 57
    syscall

    cmp rax, 0
    je .median

    mov rax, 61
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    mov rax, 57
    syscall

    cmp rax, 0
    je .prime_count

    mov rax, 61
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    mov rax, 57
    syscall

    cmp rax, 0
    je .multiple_of_five

    mov rax, 61
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    mov rax, 57
    syscall

    cmp rax, 0
    je .medium

    mov rax, 61
    mov rdi, -1
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    
    call exit

.median:
    mov rsi, msg1
    call print_str

    mov rax, ARRLEN
    test rax, 1
    jnz .odd_length
    
    ; Четная длина
    mov rax, ARRLEN
    shr rax, 1      
    xor rbx, rbx
    mov bl, [array + rax - 1] 
    xor rcx, rcx
    mov cl, [array + rax]    
    mov rax, rbx
    add rax, rcx
    shr rax, 1               
    jmp .print_median
    
    .odd_length:
    ; Нечетная длина
    mov rax, ARRLEN
    shr rax, 1
    xor rbx, rbx
    mov bl, [array + rax]
    mov rax, rbx
    
    .print_median:
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.prime_count:
    mov rsi, msg2
    call print_str

    xor rbx, rbx  
    mov rcx, ARRLEN
    
    .prime_loop:
        movzx rax, byte [array + rcx - 1]
        
        cmp rax, 2
        jl .not_prime  
        je .is_prime  
        
        test al, 1
        jz .not_prime  
        
        mov r8, 3
        mov r9, rax  
        
        .check_divisors:
            mov rax, r8
            mul r8
            cmp rax, r9
            jg .is_prime
            
            mov rax, r9
            xor rdx, rdx
            div r8
            test rdx, rdx
            jz .not_prime
            
            add r8, 2
            jmp .check_divisors
        
        .is_prime:
            inc rbx
        
        .not_prime:
        dec rcx
        jnz .prime_loop

    mov rax, rbx
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.multiple_of_five:
    mov rsi, msg3
    call print_str

    xor rbx, rbx      
    mov rcx, ARRLEN
    
    .multiple_loop:
        movzx rax, byte [array + rcx - 1]
        
        xor rdx, rdx
        mov r8, 5
        div r8
        test rdx, rdx
        jnz .not_multiple
        
        inc rbx
        
        .not_multiple:
        dec rcx
        jnz .multiple_loop

    mov rax, rbx
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.medium:
    mov rsi, msg4
    call print_str

    xor rax, rax 
    xor rbx, rbx  
    .sum_loop:
        xor rcx, rcx
        mov cl, [array + rbx]
        add rax, rcx

        inc rbx
        cmp rbx, ARRLEN
        jl .sum_loop

    xor rdx, rdx
    mov r8, ARRLEN
    div r8

    mov r9, r8
    shr r9, 1
    cmp rdx, r9
    jb .no_round
    inc rax
    
    .no_round:
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

filter:
    xor rax, rax
    mov rsi, array
    mov rcx, ARRLEN
    dec rcx
    
    .check:
        mov dl, [rsi]
        mov dh, [rsi+1]
        cmp dl, dh
        jbe .ok

        mov [rsi], dh
        mov [rsi+1], dl
        inc rax

        .ok:
        inc rsi
        dec rcx
        jnz .check
    ret