format ELF64

public _start

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn usleep
extrn printw

section '.bss' writable
    xmax dq 1
    ymax dq 1
    palette dq 1
    delay dq ?

section '.text' executable
_start:
    call initscr
    mov rdi, [stdscr]
    call getmaxx
    dec rax
    mov [xmax], rax
    call getmaxy
    dec rax
    mov [ymax], rax
    call start_color
    ; Инициализация цветовых пар для желтого и белого
    mov rdi, 1
    mov rsi, 3      ; COLOR_YELLOW (обычно 3 в ncurses)
    mov rdx, 0      ; COLOR_BLACK как фон
    call init_pair
    mov rdi, 2
    mov rsi, 7      ; COLOR_WHITE (обычно 7 в ncurses)
    mov rdx, 0      ; COLOR_BLACK как фон
    call init_pair
    call refresh
    call noecho
    call raw
    mov rax, ' '
    or rax, 0x200
    mov [palette], rax

.begin:
    mov rax, [palette]
    and rax, 0x100
    cmp rax, 0
    jne .white      ; Изменено с .mag на .white
    mov rax, [palette]
    and rax, 0xff
    or rax, 0x100   ; Желтый цвет
    jmp @f
.white:
    mov rax, [palette]
    and rax, 0xff
    or rax, 0x200   ; Белый цвет
@@:
    mov [palette], rax
    mov r8, 0
    mov r9, 0
    jmp .loop_to_right

.to_down_left:
    inc r8
    inc r9
    cmp r9, [ymax]
    jg .begin

.loop_to_right:
    mov rdi, [delay]
    call usleep
    mov rdi, r9
    mov rsi, r8
    push r8
    push r9
    call move
    mov rdi, [palette]
    call addch
    call refresh
    mov rdi, 1
    call timeout
    call getch
    cmp rax, 'z'    ; Изменено с 'a' на 'z'
    jne @f
    jmp .exit
@@:
    cmp rax, 'k'    ; Изменено с 'g' на 'k'
    jne @f
    cmp [delay], 2000
    je .fast1
    mov [delay], 2000
    jmp @f
.fast1:
    mov [delay], 1
@@:
    pop r9
    pop r8
    inc r8
    cmp r8, [xmax]
    jg .to_down_right
    jmp .loop_to_right

.to_down_right:
    dec r8
    inc r9
    cmp r9, [ymax]
    jg .begin

.loop_to_left:
    mov rdi, [delay]
    call usleep
    mov rdi, r9
    mov rsi, r8
    push r8
    push r9
    call move
    mov rdi, [palette]
    call addch
    call refresh
    mov rdi, 1
    call timeout
    call getch
    cmp rax, 'z'    ; Изменено с 'a' на 'z'
    jne @f
    jmp .exit
@@:
    cmp rax, 'k'    ; Изменено с 'g' на 'k'
    jne @f
    cmp [delay], 2000
    je .fast2
    mov [delay], 2000
    jmp @f
.fast2:
    mov [delay], 1
@@:
    pop r9
    pop r8
    dec r8
    cmp r8, 0
    jl .to_down_left
    jmp .loop_to_left

.exit:
    call endwin
    call exit