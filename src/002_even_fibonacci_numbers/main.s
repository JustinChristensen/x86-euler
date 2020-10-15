.global start
.p2align 4

.include "exit.s"
.include "io.s"

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
    mov %eax, %esi
    call write_uint_nl
    call exit

