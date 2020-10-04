.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

sum_even_fibs:
    mov $1, %ebx       # i
    mov $2, %ecx       # j
    mov %ecx, %eax     # sum
Lsum_even_fibs_loop:
    xor %edx, %edx     # if odd, += 0
    test $1, %ecx
    cmovne %ecx, %edx  # if even, += j
    add %edx, %eax

    mov %ebx, %edx     # k = i + j
    add %ecx, %edx

    mov %ecx, %ebx     # i = j
    mov %edx, %ecx     # j = k

    cmp $4000000, %ecx
    jle Lsum_even_fibs_loop

    ret

start:
    call sum_even_fibs

    mov %rsp, %rdi
    mov %eax, %esi
    sub $16, %rsp          # make space for integer conversion
    call uint_to_str_nl

    mov %eax, %edx         # length
    mov %rdi, %rsi         # string pointer
    call write

    add $16, %rsp          # reclaim stack space

    call exit

