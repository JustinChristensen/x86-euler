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
    callq uint_to_str

    movl %eax, %edx         # length
    movq %rdi, %rsi         # string pointer
    callq write

    addq $16, %rsp          # reclaim stack space

    callq exit

