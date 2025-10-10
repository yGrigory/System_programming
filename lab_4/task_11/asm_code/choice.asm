format ELF64
public _start

section '.data' writable
prompt db "Введите количество судей: "
prompt_len = $ - prompt
vote_prompt db "Введите голос (1-Да, 0-Нет) для судьи "
vote_len = $ - vote_prompt
colon db ": "
colon_len = $ - colon
yes_msg db "Решение: ДА", 10
yes_len = $ - yes_msg
no_msg db "Решение: НЕТ", 10
no_len = $ - no_msg
newline db 10

section '.bss' writable
n rq 1
yes_count rq 1
current_judge rq 1
input_buffer rb 16
judge_num_buffer rb 8

section '.text' executable

itoa:
    mov rcx, 10
    xor rbx, rbx
    test rax, rax
    jnz .convert
    mov byte [rdi], '0'
    inc rdi
    jmp .done
.convert:
    xor rdx, rdx
    div rcx
    add dl, '0'
    push rdx
    inc rbx
    test rax, rax
    jnz .convert
.pop_loop:
    pop rdx
    mov [rdi], dl
    inc rdi
    dec rbx
    jnz .pop_loop
.done:
    mov byte [rdi], 0
    ret

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [prompt]
    mov rdx, prompt_len
    syscall

    mov rax, 0
    mov rdi, 0
    lea rsi, [input_buffer]
    mov rdx, 16
    syscall

    lea rsi, [input_buffer]
    xor rax, rax
    xor rbx, rbx
.convert_n:
    mov bl, [rsi]
    cmp bl, 10
    je .start_voting
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .convert_n

.start_voting:
    mov [n], rax
    mov qword [current_judge], 1
    mov qword [yes_count], 0

.vote_loop:
    mov rax, [current_judge]
    cmp rax, [n]
    jg .count_votes

    mov rax, 1
    mov rdi, 1
    lea rsi, [vote_prompt]
    mov rdx, vote_len
    syscall

    mov rax, [current_judge]
    lea rdi, [judge_num_buffer]
    call itoa

    mov rax, 1
    mov rdi, 1
    lea rsi, [judge_num_buffer]
    mov rdx, 8
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [colon]
    mov rdx, colon_len
    syscall

    mov rax, 0
    mov rdi, 0
    lea rsi, [input_buffer]
    mov rdx, 16
    syscall

    lea rsi, [input_buffer]
    xor rax, rax
    mov al, [rsi]
    sub al, '0'

    cmp rax, 1
    jne .next_vote
    inc qword [yes_count]

.next_vote:
    inc qword [current_judge]
    jmp .vote_loop

.count_votes:
    mov rax, [yes_count]
    mov rbx, [n]
    shr rbx, 1
    cmp rax, rbx
    jg .decision_yes

    mov rax, 1
    mov rdi, 1
    lea rsi, [no_msg]
    mov rdx, no_len
    syscall
    jmp .exit

.decision_yes:
    mov rax, 1
    mov rdi, 1
    lea rsi, [yes_msg]
    mov rdx, yes_len
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
