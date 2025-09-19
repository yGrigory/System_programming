format ELF executable
entry start

segment readable executable

start:
    ; Вывод фамилии
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, surname    ; указатель на фамилию
    mov edx, surname_len ; длина фамилии
    int 0x80
    
    ; 
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; 
    mov eax, 4
    mov ebx, 1
    mov ecx, name
    mov edx, name_len
    int 0x80
    
    ; 
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; 
    mov eax, 4
    mov ebx, 1
    mov ecx, patronymic
    mov edx, patronymic_len
    int 0x80
    
    ; Вывод новой строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Завершение программы
    mov eax, 1          ; 
    xor ebx, ebx        ;
    int 0x80

segment readable writeable

surname    db 'Юдин'      ;
surname_len = $ - surname

name       db 'Григорий'        ; 
name_len = $ - name

patronymic db 'Олегович'    ; 
patronymic_len = $ - patronymic

newline    db 10            ; 