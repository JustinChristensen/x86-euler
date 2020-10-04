.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

# rdi - the number to compute the largest prime factor for
# rax - largest prime factor result
largest_prime:
    mov %rdi, %rbx                 # n
    cmp $1, %rbx
    cmovle %rbx, %rax
    jle Llargest_prime_end

    mov $2, %r10
Llargest_prime_loop:
    mov %rbx, %rax                 # only commit the change to the dividend after finding the next factor
    xor %rdx, %rdx
    div %r10
    test %rdx, %rdx
    jz Llargest_prime_loop_body
    inc %r10
    jmp Llargest_prime_loop

Llargest_prime_loop_body:
    mov %rax, %rbx
    cmp $1, %rbx
    jg Llargest_prime_loop

    mov %r10, %rax
Llargest_prime_end:
    ret

start:
    mov $600851475143, %rdi
    call largest_prime

    mov %rsp, %rdi
    mov %eax, %esi
    sub $16, %rsp          # make space for integer conversion
    call uint_to_str_nl

    mov %eax, %edx         # length
    mov %rdi, %rsi         # string pointer
    call write

    add $16, %rsp          # reclaim stack space

    call exit

