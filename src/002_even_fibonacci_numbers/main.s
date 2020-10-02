.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

sum_even_fibs:
    movl $1, %ebx       # i
    movl $2, %ecx       # j
    movl %ecx, %eax     # sum
Lsum_even_fibs_loop:
    xorl %edx, %edx     # if odd, += 0
    testl $1, %ecx
    cmovnel %ecx, %edx  # if even, += j
    addl %edx, %eax

    movl %ebx, %edx     # k = i + j
    addl %ecx, %edx

    movl %ecx, %ebx     # i = j
    movl %edx, %ecx     # j = k

    cmpl $4000000, %ecx
    jle Lsum_even_fibs_loop

    retq

start:
    callq sum_even_fibs

    movq %rsp, %rdi
    movl %eax, %esi
    subq $16, %rsp          # make space for integer conversion
    callq uint_to_str_nl

    movl %eax, %edx         # length
    movq %rdi, %rsi         # string pointer
    callq write

    addq $16, %rsp          # reclaim stack space

    callq exit

