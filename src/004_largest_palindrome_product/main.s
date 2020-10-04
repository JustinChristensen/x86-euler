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
    mov $0, %rdx               # low bound, rax = high bound
    dec %rax
    jmp Lis_palindrome_loop
Lis_palindrome_loop:
    mov (%rdi, %rax), %r8b     # load high character
    cmp (%rdi, %rdx), %r8b     # compare with low character
    jne Lis_palindrome_end      # bail early when not equal
    dec %rax
    inc %rdx                   # --> <--
    cmp %rdx, %rax
    jge Lis_palindrome_loop
    xor %eax, %eax              # ZF=1 for success
Lis_palindrome_end:
    ret

largest_palindrome:
    mov %rsp, %rbp
    dec %rbp                   # avoid clobbering return address
    sub $16, %rsp              # space for string conversion
                                # r12 max
    mov $999, %ebx             # i
Llargest_palindrome_loop:
    mov %ebx, %ecx             # j
Llargest_palindrome_inner:
    xor %edx, %edx
    mov %ebx, %eax
    mul %ecx

    mov %rbp, %rdi
    mov %eax, %esi
    call uint_to_str

    call is_palindrome
    jne Llargest_palindrome_not

    cmp %r12d, %esi            # max = n > max ? n : max
    cmovg %esi, %r12d
Llargest_palindrome_not:
    dec %ecx
    cmp $0, %ecx
    jg Llargest_palindrome_inner

    dec %ebx
    cmp $0, %ebx
    jg Llargest_palindrome_loop

    add $16, %rsp
    mov %r12d, %eax             # return max
    ret

start:
    call largest_palindrome

    mov %rsp, %rdi
    mov %eax, %esi
    sub $16, %rsp          # make space for integer conversion

    call uint_to_str_nl

    mov %eax, %edx         # length
    mov %rdi, %rsi         # string pointer
    call write

    add $16, %rsp          # reclaim stack space

    call exit

