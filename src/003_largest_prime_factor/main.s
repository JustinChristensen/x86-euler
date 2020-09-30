.global start
.p2align 4

/*
general-purpose registers
       rax rbx rcx rdx rdi rsi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15                quadword (64-bit)
       rip
    rflags
        cs ds es ss fs gs                                                           segment selectors
       eax ebx ecx edx edi esi ebp esp r8d r9d r10d r11d r12d r13d r14d r15d        doubleword (32-bit)
        ax bx cx dx di si bp sp r8w r9w r10w r11w r12w r13w r14w r15w               word (16-bit)
        ah bh ch dh                                                                 high byte (legacy)
        al bl cl dl dil sil bpl spl r8l r9l r10l r11l r12l r13l r14l r15l           low byte

system-V calling convention
parameter     1    2    3    4    5    6      return
register    rdi  rsi  rdx  rcx   r8   r9      rdx:rax
*/

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
    callq uint_to_str

    movl %eax, %edx         # length
    movq %rdi, %rsi         # string pointer
    callq write

    addq $16, %rsp          # reclaim stack space

    callq exit

