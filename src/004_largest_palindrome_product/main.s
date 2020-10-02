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
        al bl cl dl dil sil bpl spl r8b r9b r10b r11b r12b r13b r14b r15b           low byte

system-V calling convention
parameter     1    2    3    4    5    6      return
register    rdi  rsi  rdx  rcx   r8   r9      rdx:rax
*/

.include "exit.s"
.include "io.s"
.include "string.s"

# eax - string length
# rdi - string pointer
is_palindrome:
    xorb %r8b, %r8b             # nuke whatever is in r8b
    testl %eax, %eax
    jz Lis_palindrome_end       # jump to end for 0 length string

    movq %rax, %r8              # for below test
    movq %rax, %rdx             # low bound
    shrq %rax                   # high bound
    movq %rax, %rdx             # low bound
    decq %rdx
    testq $1, %r8              # -1 for even lengths
    cmovnzq %rax, %rdx
Lis_palindrome_loop:
    movb (%rdi, %rax), %r8b     # load high character
    cmpb (%rdi, %rdx), %r8b     # compare with low character
    sete %r8b                   # r8b = rdi[low] == rdi[high]
    jne Lis_palindrome_end      # bail early when not equal
    testq %rdx, %rdx
    jz Lis_palindrome_end       # return if lower bound is 0
    decq %rdx                   # <-- -->
    incq %rax
    jmp Lis_palindrome_loop
Lis_palindrome_end:
    cmpb $1, %r8b               # put flags into the right state
    retq

largest_palindrome:
    movq %rsp, %rbp
    decq %rbp                   # avoid clobbering return address
    subq $16, %rsp              # space for string conversion
                                # r12 max
    movl $999, %ebx             # i
Llargest_palindrome_loop:
    movl %ebx, %ecx             # j
Llargest_palindrome_inner:
    xorl %edx, %edx
    movl %ebx, %eax
    mull %ecx

    movq %rbp, %rdi
    movl %eax, %esi
    callq uint_to_str

    callq is_palindrome
    jne Llargest_palindrome_not

    cmpl %r12d, %esi            # max = n > max ? n : max
    cmovgl %esi, %r12d
Llargest_palindrome_not:
    decl %ecx
    cmpl $0, %ecx
    jg Llargest_palindrome_inner

    decl %ebx
    cmpl $0, %ebx
    jg Llargest_palindrome_loop

    addq $16, %rsp
    mov %r12d, %eax             # return max
    retq

start:
    callq largest_palindrome

    movq %rsp, %rdi
    movl %eax, %esi
    subq $16, %rsp          # make space for integer conversion

    callq uint_to_str_nl

    movl %eax, %edx         # length
    movq %rdi, %rsi         # string pointer
    callq write

    addq $16, %rsp          # reclaim stack space

    callq exit

