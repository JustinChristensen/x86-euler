.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

# rdi - the number to compute the largest prime factor for
# rax - largest prime factor result
largest_prime:
    movq %rdi, %rbx                 # n
    cmpq $1, %rbx
    cmovleq %rbx, %rax
    jle Llargest_prime_end

    movq $2, %r10
Llargest_prime_loop:
    movq %rbx, %rax                 # only commit the change to the dividend after finding the next factor
    xorq %rdx, %rdx
    divq %r10
    testq %rdx, %rdx
    jz Llargest_prime_loop_body
    incq %r10
    jmp Llargest_prime_loop

Llargest_prime_loop_body:
    movq %rax, %rbx
    cmpq $1, %rbx
    jg Llargest_prime_loop

    movq %r10, %rax
Llargest_prime_end:
    retq

start:
    movq $600851475143, %rdi
    callq largest_prime

    movq %rsp, %rdi
    movl %eax, %esi
    subq $16, %rsp          # make space for integer conversion
    callq uint_to_str_nl

    movl %eax, %edx         # length
    movq %rdi, %rsi         # string pointer
    callq write

    addq $16, %rsp          # reclaim stack space

    callq exit

