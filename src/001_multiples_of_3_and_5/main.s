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

L_SYS_EXIT = 0x2000001
L_SYS_WRITE = 0x2000004
L_SUCCESS = 0
L_STDOUT = 1

exit:
    movl $L_SYS_EXIT, %eax
    movl $L_SUCCESS, %edi
    syscall
    retq

# edx - string length
# rsi - string pointer
write:
    movl $L_STDOUT, %edi
    movl $L_SYS_WRITE, %eax
    syscall
    retq

# length = to_str rdi esi
# rdi - pointer to string storage
# esi - unsigned integer to stringify
uint_to_str:
    movl $1, %r10d               # length
    movb $'\n', %dl              # append newline
    movb %dl, (%rdi)
    xorl %edx, %edx
    movl %esi, %eax              # edx:eax
    movl $10, %r11d              # divisor
Luint_to_str_loop:
    decq %rdi                    # pointer--
    incl %r10d                   # length++
    divl %r11d
    addb $'0', %dl
    movb %dl, (%rdi)
    xorl %edx, %edx                # clear edx, otherwise quotients >= 2^w result in a floating point exception with DIV
    testl %eax, %eax
    jg Luint_to_str_loop          # quotient > 0
    movl %r10d, %eax             # return length
    retq

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
    movl $3, %edi                # i % 3 == 0 || i % 5 == 0
    callq divides
    je Lsum_multiples_loop_add

    movl %ecx, %eax
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
    subq $16, %rsp               # make space for the integer ascii string
    movl %eax, %esi
    callq uint_to_str            # convert answer to string

    movq %rdi, %rsi
    movl %eax, %edx
    callq write                  # write to stdout

    addq $16, %rsp               # reclaim string storage

    callq exit

