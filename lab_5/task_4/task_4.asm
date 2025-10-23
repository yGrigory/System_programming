section .data
    error_args db "Usage: ./program input_file output_file", 10, 0
    error_args_len equ $ - error_args
    
    error_input db "Error: Cannot open input file", 10, 0
    error_input_len equ $ - error_input
    
    error_output db "Error: Cannot open output file", 10, 0
    error_output_len equ $ - error_output
    
    error_read db "Error: Cannot read from input file", 10, 0
    error_read_len equ $ - error_read
    
    error_write db "Error: Cannot write to output file", 10, 0
    error_write_len equ $ - error_write

section .bss
    buffer resb 4096     
    input_fd resd 1     
    output_fd resd 1        
    input_filename resd 1   
    output_filename resd 1 

section .text
    global _start

_start:
    pop eax              
    cmp eax, 3             
    jne exit_error_args

    pop eax                
    pop eax               
    mov [input_filename], eax
    
    pop eax                
    mov [output_filename], eax 

    mov eax, 5             
    mov ebx, [input_filename] 
    mov ecx, 0              
    mov edx, 0                
    int 0x80
    
    cmp eax, 0              
    jl exit_error_input
    
    mov [input_fd], eax     

    mov eax, 5              
    mov ebx, [output_filename]
    mov ecx, 0x241       
    mov edx, 0644o         
    int 0x80
    
    cmp eax, 0          
    jl exit_error_output
    
    mov [output_fd], eax     

process_file:
    mov eax, 3              
    mov ebx, [input_fd]     
    mov ecx, buffer         
    mov edx, 4096            
    int 0x80
    
    cmp eax, 0           
    jl exit_error_read
    je close_files          
    
    mov esi, buffer        
    mov edi, buffer       
    mov ecx, eax             
    mov edx, eax           

process_buffer:
    jecxz write_result     
    
    lodsb                   
    
    cmp al, 'A'
    je skip_vowel
    cmp al, 'E'
    je skip_vowel
    cmp al, 'I'
    je skip_vowel
    cmp al, 'O'
    je skip_vowel
    cmp al, 'U'
    je skip_vowel
    cmp al, 'Y'
    je skip_vowel
    
    stosb                 
    jmp continue_loop

skip_vowel:
    dec edx                  

continue_loop:
    dec ecx            
    jmp process_buffer

write_result:
    mov eax, 4               
    mov ebx, [output_fd]     
    mov ecx, buffer         
    mov edx, edx          
    int 0x80
    
    cmp eax, 0              
    jl exit_error_write
    
    jmp process_file          

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

exit_error_args:
    mov eax, 4            
    mov ebx, 2               
    mov ecx, error_args
    mov edx, error_args_len
    int 0x80
    jmp exit_error

exit_error_input:
    mov eax, 4            
    mov ebx, 2              
    mov ecx, error_input
    mov edx, error_input_len
    int 0x80
    jmp exit_error

exit_error_output:
    mov eax, 6              
    mov ebx, [input_fd]
    int 0x80
    
exit_error_output_msg:
    mov eax, 4               
    mov ebx, 2              
    mov ecx, error_output
    mov edx, error_output_len
    int 0x80
    jmp exit_error

exit_error_read:
    mov eax, 6                ; sys_close
    mov ebx, [input_fd]
    int 0x80
    mov eax, 6                ; sys_close
    mov ebx, [output_fd]
    int 0x80
    
    mov eax, 4                ; sys_write
    mov ebx, 2                ; stderr
    mov ecx, error_read
    mov edx, error_read_len
    int 0x80
    jmp exit_error

exit_error_write:
    mov eax, 6                ; sys_close
    mov ebx, [input_fd]
    int 0x80
    mov eax, 6                ; sys_close
    mov ebx, [output_fd]
    int 0x80
    
    mov eax, 4                ; sys_write
    mov ebx, 2                ; stderr
    mov ecx, error_write
    mov edx, error_write_len
    int 0x80

exit_error:
    mov eax, 1                ; sys_exit
    mov ebx, 1                ; Код возврата 1
    int 0x80