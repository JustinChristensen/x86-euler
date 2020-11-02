.p2align 4

# x87 float math routines

# st(0) = floor/ceil(st(0))
.global fp_ceil
.global fp_floor
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
.global fp_log10
fp_log10:
    fldl2t
    fld1
    fdiv                  # a = 1 / log2(10)
    fxch
    fyl2x                 # b = a * log2(x)
    ret

# st(0) = x
# st(1) = y
# x^y = 2^(y * log2(x))
.global fp_pow
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

.set L_MAX_FLOAT_LEN, 16
.set L_SIGN_MASK, 0x8000000000000000
.set L_EXP_MASK, 0x7FF0000000000000
.set L_SIG_MASK, 0xFFFFFFFFFFFFF

# this version uses multiplication to scale the fractional part of the floating point value
# and so it can't handle the full range of values a double precision floating point value can represent
# buyer beware
# st(0) - float to stringify
# rbx - requested fractional precision
# rdi - pointer to end of buffer (points to start on return)
# rax - length of string
dtoa:
    push %rsi
    push %rcx
    push %rdx
    push %r10
    push %r11
    sub $16, %rsp

    xor %r10, %r10                  # length

    fstl 8(%rsp)
    mov 8(%rsp), %rbp
    # detecting +-inf, nan, and +-0
    mov $L_EXP_MASK, %rsi
    and %rbp, %rsi                  # exponent
    shr $52, %rsi
    mov $L_SIG_MASK, %rdx
    and %rbp, %rdx                  # significand
    mov $L_SIGN_MASK, %r11
    and %rbp, %r11                  # sign
    shr $63, %r11

    std                             # set direction flag for string copies below
    test %rsi, %rsi
    jz Ldtoa_maybe_zero             # zero exponent
    cmp $2047, %rsi
    jz Ldtoa_inf_nan
    jmp Ldtoa_norm_denorm
Ldtoa_maybe_zero:
    test %rdx, %rdx
    jnz Ldtoa_norm_denorm           # zero significand
    movb $'0', (%rdi)               # we found zero
    dec %rdi
    inc %r10
    jmp Ldtoa_end
Ldtoa_inf_nan:
    test %rdx, %rdx
    jz Ldtoa_inf
    mov $Lnan_len, %rcx
    lea Lnan-1(%rip), %rsi
    add %rcx, %rsi
    add %rcx, %r10
    rep movsb
    jmp Ldtoa_end
Ldtoa_inf:
    mov $Linf_len, %rcx
    lea Linf-1(%rip), %rsi
    add %rcx, %rsi
    add %rcx, %r10
    rep movsb
    jmp Ldtoa_end
Ldtoa_norm_denorm:
    # i am not a good enough programmer to do this in terms of integer operations
    # on the above exponent and significand registers, so here's a kludgy approach
    fld %st(0)
    fabs
    fld %st(0)
    fisttpq 8(%rsp)                 # floor and store
    fisubl 8(%rsp)
    mov 8(%rsp), %rdx

    mov $L_MAX_FLOAT_LEN, %rax
    test %rbx, %rbx
    cmovz %rax, %rbx
    cmp %rax, %rbx                  # compare requested precision to available precision
    cmovg %rax, %rbx
    mov %rbx, 8(%rsp)               # restore rbx after ipow
    mov %rbx, %rcx
    mov $10, %rbx
    call ipow                       # scale factor
    mov 8(%rsp), %rbx
    mov %rax, 8(%rsp)
    fildq 8(%rsp)
    fmul                            # multiply by fractional component
    fistpq 8(%rsp)
    mov 8(%rsp), %rax               # fractional component
    mov %rdx, %rcx                  # stash int component

    # rdx - integer part, rcx - fractional part
    mov $10, %rsi
Ldtoa_fraction_loop:                # handle the fractional part
    xor %rdx, %rdx
    div %rsi
    movb %dl, (%rdi)
    addb $'0', (%rdi)
    dec %rdi
    inc %r10
    test %rax, %rax
    jnz Ldtoa_fraction_loop

    movb $'.', (%rdi)
    dec %rdi
    inc %r10

    mov %rcx, %rax
Ldtoa_int_loop:                     # handle the integer part
    xor %rdx, %rdx
    div %rsi
    movb %dl, (%rdi)
    addb $'0', (%rdi)
    dec %rdi
    inc %r10
    test %rax, %rax
    jnz Ldtoa_int_loop
Ldtoa_end:
    cld                     # clear direction flag
    test %r11, %r11
    jz Ldtoa_after_sign
    movb $'-', (%rdi)
    inc %r10
    dec %rdi
Ldtoa_after_sign:
    inc %rdi
    mov %r10, %rax          # return the length
    add $16, %rsp
    pop %r11
    pop %r10
    pop %rdx
    pop %rcx
    pop %rsi
    ret

.global dtoa_write
dtoa_write:
    lea -1(%rsp), %rdi
    sub $64, %rsp

    movb $'\n', (%rdi)
    dec %rdi
    call dtoa
    inc %rax

    mov %rax, %rdx
    mov %rdi, %rsi
    call write
    add $64, %rsp
    ret

.data
Lnan: .ascii "nan"
.set Lnan_len, . - Lnan
Linf: .ascii "inf"
.set Linf_len, . - Linf
Lnorm: .ascii "norm"
.set Lnorm_len, . - Lnorm
Ldenorm: .ascii "denorm"
.set Ldenorm_len, . - Ldenorm

