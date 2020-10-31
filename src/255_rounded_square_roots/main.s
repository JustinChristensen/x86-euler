.p2align 4

fp_ceil:
    mov $0x800, %bx      # bx - rounding mode
    jmp Lround
fp_floor:
    mov $0xc00, %bx
Lround:
    sub $4, %rsp
    fstcw 2(%rsp)

    fstcw (%rsp)
    andw $0xf3ff, (%rsp)  # zero rounding bits (nearest)

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

# rsi - input integer
# rax - number of digits for integer
fp_ndigits:
    sub $16, %rsp

    mov %rsi, 8(%rsp)
    fildq 8(%rsp)      # x

    call fp_log10       # a = log10(x)
    fld1
    fadd                # b = a + 1
    call fp_floor       # c = floor(b)

    fistpq 8(%rsp)
    mov 8(%rsp), %rax

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

# rbx - base
# rcx - exponent
# rax - return integer
ipow:
    push %rbp
    push %rdx
    mov $1, %rbp        # result
    xor %rdx, %rdx
ipow_loop:
    test $1, %rcx
    jz ipow_shift

    mov %rbp, %rax
    imul %rbx
    mov %rax, %rbp      # result *= base

ipow_shift:
    shr %ecx
    jz ipow_end

    mov %rbx, %rax
    mov %rbx, %rax
    imul %rbx
    mov %rax, %rbx      # base *= base

    jmp ipow_loop
ipow_end:
    mov %rbp, %rax
    pop %rdx
    pop %rbp
    ret

# rdi - buffer to fill
# rsi - requested precision
# st(0) - float to convert
f2s:
    sub $32, %rsp
    fstcw 2(%rsp)               # restore original control word after all is said and done

    fstcw (%rsp)
    andw $0xf3ff, (%rsp)        # zero rounding bits (round to nearest)
    orw %0xc00, (%rsp)          # round to zero
    fldcw (%rsp)                # set rounding mode

    mov %rsi, 24(%rsp)          # stash rsi for later
    fist 16(%rsp)               #

    mov 16(%rsp), %rsi
    call fp_ndigits             # rax is now the integer component length

    mov $MAX_FLOAT_LEN, %rsi
    sub %rax, %rsi
    cmp 24(%rsp), %rsi          # compare requested precision to available precision
    cmovg 24(%rsp), %rsi

    fld %st(0)

    fldcw 2(%rsp)         # restore original rounding mode
    add $32, %rsp
    ret


# rdi - pointer to temporary integer storage
# k * 10^((d - s)/2)
herons_term0:
    call fp_ndigits     # d

    mov $1, %rbx        # s
    mov $2, %rcx        # k
    mov $7, %rdx

    test $1, %rax
    cmove %rcx, %rbx
    cmove %rdx, %rcx

    sub %rbx, %rax      # a = d - s
    shr %rax            # b = a / 2

    mov %rax, (%rdi)
    fildq (%rdi)         # y

    movl $10, (%rdi)
    fildl (%rdi)         # x

    call fp_pow          # x x^y

    mov %rcx, (%rdi)
    fildq (%rdi)
    fmul

    ret

# es - input integer
# rdi - temporary integer storage
# x_k+1 = floor((x_k + ceil(n / x_k)) / 2)
herons:
    call herons_term0           # either compute the first term

    # movq $7000000, (%rdi)     # OR hardcode
    # fildq (%rdi)

    xor %ecx, %ecx
Lherons_loop:
    inc %ecx                # track iterations
    movl $2, (%rdi)
    fildl (%rdi)
    fld %st(1)              # addend x_k
    fld %st(0)              # divisor x_k
    mov %rsi, (%rdi)
    fildq (%rdi)            # n

    fdiv                    # a = n / x_k
    call fp_ceil            # b = ceil(a)
    fadd                    # c = x_k + b
    fdiv                    # d = c / 2
    call fp_floor           # next = floor(d)

    fxch                    # leave next behind after fcomp pop
    fcomip                  # next == prev (compare and set eflags)
    jne Lherons_loop

    fistpq (%rdi)
    mov (%rdi), %rax        # rounded square root of x

    ret

maybe_print_result:
    mov %rax, %r13
    xor %rdx, %rdx
    mov %rsi, %rax
    mov $100000000, %r12
    div %r12
    mov %r13, %rax
    test %rdx, %rdx
    jz Lprint_result
    ret
Lprint_result:
    push %rbp
    push %rbx
    push %rcx
    push %rsi
    push %rdi
    lea -1(%rsp), %rdi
    sub $16, %rsp
    mov %rax, %rbp
    mov %rcx, %rbx

    call write_uint                 # print out "n herons(n)\n"
    call write_space
    mov %rbp, %rsi
    call write_uint
    call write_space
    mov %rbx, %rsi
    call write_uint_nl

    add $16, %rsp
    pop %rdi
    pop %rsi
    pop %rcx
    pop %rbx
    pop %rbp
    ret

# [rsi, rbp] - range of numbers to apply heron's method to
average_iterations:
    mov %rbp, %r14
    sub %rsi, %r14
    inc %r14
Laverage_iterations_loop:
    call herons
#     call maybe_print_result
    add %rcx, %r15
    inc %rsi
    cmp %rsi, %rbp
    jge Laverage_iterations_loop

    mov %r14, (%rdi)
    fildq (%rdi)
    mov %r15, (%rdi)
    fildq (%rdi)
    fdiv

    ret

.global start
start:
    add $16, %rsp

    # this can/should be done in terms of integer operations
    # i.e. division rounded to zero, but I was feeling like doing it in terms of x87 fpu ops
    # also, this only works for the example solution, the real problem requires some sort
    # of fancy number theory trick, because 10^14-1 - 10^13 takes too long to brute force

    # use double-precision for this
    fstcw (%rsp)
    andw $0xfcff, (%rsp)
    orw $0x200, (%rsp)
    fldcw (%rsp)

    mov $10000, %rsi
    mov $99999, %rbp        # [rsi, rbp]
    lea 8(%rsp), %rdi
    call average_iterations

    # actual: 289363
    # expected: 288926
    # off by 437

    # example of a value for which 80-bit precision causes an extra iteration in
    # the herons loop over 64-bit precision
    # mov $47400, %rsi
    # call herons

    movl $10, %edi          # precision
    call f2s

    sub $16, %rsp
    call exit

