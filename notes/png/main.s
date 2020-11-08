.p2align 4

write_nl:
    push %rsi
    push %rdx
    sub $16, %rsp
    call write
    movb $'\n', (%rsp)
    lea (%rsp), %rsi
    mov $1, %edx
    call write

    add $16, %rsp
    pop %rdx
    pop %rsi
    ret

.global start
start:
    mov (%rsp), %rbx                # argc
    # lea 8(%rsp), %rbp             # argv (including the program name)
    lea 16(%rsp), %rbp              # argv
    dec %ebx
    xor %ecx, %ecx
    jmp Largs_loop_test
Largs_loop:
    call strlen
    mov %eax, %edx
    call write_nl
    inc %ecx
Largs_loop_test:
    mov (%rbp, %rcx, 8), %rsi       # argv[++argc]
    cmp %ecx, %ebx
    jg Largs_loop

    call exit

