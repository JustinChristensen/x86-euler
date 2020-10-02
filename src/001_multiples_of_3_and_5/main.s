.global start
.p2align 4

/*

Improvements to consider:
1. Use multiplicative inverse instead of division
2. Conditionally set the addend to 0 when neither i % 3 or i % 5 == 0 instead of jumping

*/

.include "exit.s"
.include "io.s"
.include "string.s"

# eax `mod` edi
# eax - dividend
# edi - divisor
divides:
    xorl %edx, %edx                # DIV divides edx:eax by src, so we've gotta zero edx
    divl %edi
    testl %edx, %edx
    retq

# eax = sum [i | i <- [3..1000], i `mod` 3 == 0 || i `mod` 5 == 0]
sum_multiples:
    xorl %ebx, %ebx              # sum
    movl $3, %ecx
Lsum_multiples_loop:
    movl %ecx, %eax
    movl $3, %edi                # i % 3 == 0
    callq divides
    je Lsum_multiples_loop_add
    # ||
    movl %ecx, %eax              # i % 5 == 0
    movl $5, %edi
    callq divides
    je Lsum_multiples_loop_add

    jmp Lsum_multiples_loop_test
Lsum_multiples_loop_add:
    add %ecx, %ebx              # sum += i
Lsum_multiples_loop_test:
    incl %ecx                    # i++
    cmpl $1000, %ecx
    jb Lsum_multiples_loop       # i <= 1000
    movl %ebx, %eax
    retq

start:
    callq sum_multiples

    movq %rsp, %rdi
    movl %eax, %esi
    subq $16, %rsp               # make space for the integer ascii string

    callq uint_to_str_nl         # convert answer to string

    movq %rdi, %rsi
    movl %eax, %edx
    callq write                  # write to stdout

    addq $16, %rsp               # reclaim string storage

    callq exit

