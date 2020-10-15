.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

fp_ceil:
    mov $0xc800, %bx      # bx - rounding mode
    jmp Lround
fp_floor:
    mov $0xc00, %bx
Lround:
    sub $4, %rsp
    fstcw 2(%rsp)

    fstcw (%rsp)
    andw $0xf3ff, (%rsp)  # zero rounding bits
    orw %bx, (%rsp)
    fldcw (%rsp)          # set rounding mode
    frndint

    fldcw 2(%rsp)         # restore original
    add $4, %rsp
    ret

# st(0) = log10(st(0))
fp_log10:
    fldl2t
    fld1
    fdiv                  # a = 1 / log2(10)
    fxch
    fyl2x                 # b = a * log2(x)
    ret

# esi - input integer
# eax - number of digits for integer
fp_ndigits:
    sub $16, %rsp

    movl %esi, 12(%rsp)
    fildl 12(%rsp)      # x

    call fp_log10       # a = log10(x)
    fld1
    fadd                # b = a + 1
    call fp_floor       # c = floor(b)

    fistl 12(%rsp)
    mov 12(%rsp), %eax

    fstp %st(0)

    add $16, %rsp
    ret

# st(0) = x
# st(1) = y
# x^y = 2^(y * log2(x))
fp_pow:
    fyl2x           # a = y * log2(x)
    fld %st(0)      # dup
    call fp_floor   # b = floor(a)
    fxch
    fprem1          # c = a % b
    f2xm1           # d = 2^c - 1
    fld1
    fadd            # e = d + 1
    fscale          # e * 2^b
    fstp %st(1)
    ret

# rdi - pointer to temporary integer storage
# k * 10^((d - s)/2)
herons_term0:
    call fp_ndigits     # d
    mov $1, %ebx        # s
    mov $2, %ecx        # k
    mov $7, %edx

    test $1, %eax
    cmove %ecx, %ebx
    cmove %edx, %ecx

    sub %ebx, %eax      # a = d - s
    shr %eax            # b = a / 2

    mov %eax, (%rdi)
    fildl (%rdi)         # y

    movl $10, (%rdi)
    fildl (%rdi)         # x

    call fp_pow          # x x^y

    mov %ecx, (%rdi)
    fildl (%rdi)
    fmul

    ret

# es - input integer
# rdi - temporary integer storage
# x_k+1 = floor((x_k + ceil(n / x_k)) / 2)
herons:
    call herons_term0       # prev
    xor %ecx, %ecx
Lherons_loop:
    inc %ecx                # track iterations
    movl $2, (%rdi)
    fildl (%rdi)
    fld %st(1)              # addend x_k
    fld %st(0)              # divisor x_k
    mov %esi, (%rdi)
    fildl (%rdi)            # n

    fdiv                    # a = n / x_k
    call fp_ceil            # b = ceil(a)
    fadd                    # c = x_k + b
    fdiv                    # d = c / 2
    call fp_floor           # next = floor(d)

    fxch                    # leave next behind after fcomp pop
    fcomip                  # next == prev (compare and set eflags)
    jne Lherons_loop

    fistl (%rdi)
    mov (%rdi), %eax        # rounded square root of x
    fstp %st(0)

    ret

# [esi, ebp] - range of numbers to apply heron's method to
average_iterations:
    mov %ebp, %r9d
    sub %esi, %r9d
    inc %r9d                        # n = (ebp - esi) + 1
Laverage_iterations_loop:
    call herons
    add %ecx, %r10d
    inc %esi
    cmp %esi, %ebp
    jge Laverage_iterations_loop

    mov %r9d, (%rdi)
    fildl (%rdi)
    mov %r10d, (%rdi)
    fildl (%rdi)
    fdiv

    ret

# actual: 289363
# expected: 288926
# off by 437

start:
    add $16, %rsp

    mov $10000, %esi
    mov $99999, %ebp        # [esi, ebp]
    lea 12(%rsp), %rdi
    call average_iterations

    sub $16, %rsp
    call exit

