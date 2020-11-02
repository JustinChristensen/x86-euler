.p2align 4

# integer math routines

# rbx - base
# rcx - exponent
# rax - return integer
.global ipow
ipow:
    push %rbp
    push %rdx
    mov $1, %rbp        # result
    xor %rdx, %rdx
Lipow_loop:
    test $1, %rcx
    jz Lipow_shift

    mov %rbp, %rax
    imul %rbx
    mov %rax, %rbp      # result *= base

Lipow_shift:
    shr %ecx
    jz Lipow_end

    mov %rbx, %rax
    mov %rbx, %rax
    imul %rbx
    mov %rax, %rbx      # base *= base

    jmp Lipow_loop
Lipow_end:
    mov %rbp, %rax
    pop %rdx
    pop %rbp
    ret

# rax - signed input integer
abs:
    push %rsi
    mov %rax, %rsi
    neg %rax
    cmovl %rsi, %rax
    pop %rsi
    ret
