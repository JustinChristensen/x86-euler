.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

# eax - string length
# rdi - string pointer
is_palindrome:
    test %rax, %rax
    jz Lis_palindrome_end
    movq $0, %rdx               # low bound, rax = high bound
    decq %rax
    jmp Lis_palindrome_loop
Lis_palindrome_loop:
    movb (%rdi, %rax), %r8b     # load high character
    cmpb (%rdi, %rdx), %r8b     # compare with low character
    jne Lis_palindrome_end      # bail early when not equal
    decq %rax
    incq %rdx                   # --> <--
    cmpq %rdx, %rax
    jge Lis_palindrome_loop
    xor %eax, %eax              # ZF=1 for success
Lis_palindrome_end:
    ret

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
    call uint_to_str

    call is_palindrome
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
    ret

start:
    call largest_palindrome

    movq %rsp, %rdi
    movl %eax, %esi
    subq $16, %rsp          # make space for integer conversion

    call uint_to_str_nl

    movl %eax, %edx         # length
    movq %rdi, %rsi         # string pointer
    call write

    addq $16, %rsp          # reclaim stack space

    call exit

