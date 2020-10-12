.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

compute_powers:
    lea powers(%rip), %rdi             # powers
    mov $2, %ebx                       # i
Lsmallest_multiple_loop:
    mov $2, %ecx                       # j - divisor
    mov %ebx, %r8d                     # n - number to divide
Lsmallest_multiple_inner:
    cmpb $0, (%rdi, %rcx)               # skip compounds
    jz Lsmallest_multiple_inner_test
    xor %esi, %esi                     # p
    mov %r8d, %eax
    jmp Lsmallest_multiple_divide_test
Lsmallest_multiple_divide_loop:
    mov %eax, %r8d                     # commit n = n / j
    inc %esi
Lsmallest_multiple_divide_test:
    xor %edx, %edx
    div %ecx                           # n / j
    test %edx, %edx                    # n % j == 0
    jz Lsmallest_multiple_divide_loop

    movzb (%rdi, %rcx), %edx           # powers[j]
    cmp %esi, %edx                     # powers[j] - p
    cmovg %edx, %esi                   # powers[j] = p > powers[j] ? p : powers[j]
    movb %sil, (%rdi, %rcx)
Lsmallest_multiple_inner_test:
    test %r8d, %r8d
    jz Lsmallest_multiple_loop_test     # check n
    inc %ecx
    cmp $20, %ecx
    jle Lsmallest_multiple_inner
Lsmallest_multiple_loop_test:
    inc %ebx
    cmp $20, %ebx
    jle Lsmallest_multiple_loop
    ret

compute_lcm:
    lea powers(%rip), %rdi             # powers
    mov $2, %ecx                       # i
    mov $1, %eax                       # multiple
Lcompute_lcm_loop:
    movzb (%rdi, %rcx), %ebx              # p
    jmp Lcompute_lcm_multiple_test      # while (p > 0)
Lcompute_lcm_multiple:
    dec %ebx
    mul %ecx
Lcompute_lcm_multiple_test:
    test %ebx, %ebx
    jg Lcompute_lcm_multiple
    inc %ecx
    cmp $20, %ecx
    jle Lcompute_lcm_loop
    ret

start:
    call compute_powers
    call compute_lcm

    mov %rsp, %rdi
    sub $16, %rsp
    mov %eax, %esi
    call uint_to_str_nl

    mov %eax, %edx
    mov %rdi, %rsi
    call write

    add $16, %rsp
    call exit

.data
powers:
.byte 0, 0, 1, 1, 0, 1, 0, 1    # 7
.space 3                        # 10
.byte 1, 0, 1                   # 13
.space 3                        # 16
.byte 1, 0, 1, 0                # 20
