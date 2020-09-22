.text
.global start

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

SYS_EXIT = 0x2000001
SYS_WRITE = 0x2000004
SUCCESS = 0
STDOUT = 1

exit:
    movl $SYS_EXIT, %eax
    movl $SUCCESS, %edi
    syscall
    retq

# edx - string length
# rsi - string pointer
write:
    movl $STDOUT, %edi
    movl $SYS_WRITE, %eax
    syscall
    retq

# length = to_str rdi esi
# rdi - pointer to string storage
# esi - unsigned integer to stringify
uint_to_str:
    movl $1, %r10d               # length
    movl $0, %edx
    movl %esi, %eax              # edx:eax
    movl $10, %r11d              # divisor
uint_to_str_loop:
    divl %r11d
    addl $'0', %edx
    movb %dl, (%rdi)
    incq %rdi
    incl %r10d                   # length++
    movl $0, %edx
    cmpl $0, %eax
    jg uint_to_str_loop          # quotient > 0
    movb $'\n', %dl              # append newline
    movb %dl, (%rdi)
    movl %r10d, %eax             # return length
    retq

# eax `mod` edi
# eax - dividend
# edi - divisor
divides:
    movl $0, %edx                # DIV divides edx:eax by src, so we've gotta zero edx
    divl %edi
    cmpl $0, %edx
    retq

# eax = sum [i | i <- [3..1000], i `mod` 3 == 0 || i `mod` 5 == 0]
sum_multiples:
    movl $0, %r10d
    movl $3, %ecx
sum_multiples_loop:
    movl %ecx, %eax
    movl $3, %edi                # i % 3 == 0 || i % 5 == 0
    callq divides
    je sum_multiples_loop_add

    movl %ecx, %eax
    movl $5, %edi
    callq divides
    je sum_multiples_loop_add

    jmp sum_multiples_loop_test
sum_multiples_loop_add:
    add %ecx, %r10d              # sum += i
sum_multiples_loop_test:
    incl %ecx                    # i++
    cmpl $1000, %ecx
    jbe sum_multiples_loop       # i <= 1000
    movl %r10d, %eax
    retq

start:
    callq sum_multiples

    subq $16, %rsp               # make space for the integer ascii string

    movq %rsp, %rdi
    movl %eax, %esi
    callq uint_to_str            # convert answer to string

    movq %rsp, %rsi
    movl %eax, %edx
    callq write                  # write to stdout

    addq $16, %rsp               # reclaim string storage

    callq exit

