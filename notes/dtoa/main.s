.global start
.p2align 4

.set L_MAX_FLOAT_LEN, 16
.set L_SIGN_MASK, 0x8000000000000000
.set L_EXP_MASK, 0x7FF0000000000000
.set L_SIG_MASK, 0xFFFFFFFFFFFFF

# 1 10000000000 1001001000011111101101010100010001000010110100011000

# this version uses multiplication to scale the fractional part of the floating point value
# and so it can't handle the full range of values a double precision floating point value can represent
# buyer beware
dtoa:
    push %rbx
    push %rcx
    push %rdx
    push %r10
    push %r11
    sub $16, %rsp

    xor %r10, %r10                  # length

    fstl 8(%rsp)
    mov 8(%rsp), %rbp
    # detecting +-inf, nan, and +-0
    mov $L_EXP_MASK, %rbx
    and %rbp, %rbx                  # exponent
    shr $52, %rbx
    mov $L_SIG_MASK, %rdx
    and %rbp, %rdx                  # significand
    mov $L_SIGN_MASK, %r11
    and %rbp, %r11                  # sign
    shr $63, %r11

    std                             # set direction flag for string copies below
    test %rbx, %rbx
    jz Ldtoa_maybe_zero             # zero exponent
    cmp $2047, %rbx
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
    lea Lnan(%rip), %rsi
    add %rcx, %rsi
    dec %rsi
    add %rcx, %r10
    rep movsb
    jmp Ldtoa_end
Ldtoa_inf:
    mov $Linf_len, %rcx
    lea Linf(%rip), %rsi
    add %rcx, %rsi
    dec %rsi
    add %rcx, %r10
    rep movsb
    jmp Ldtoa_end
Ldtoa_norm_denorm:
    # i am not a good enough programmer to do this in terms of integer operations
    # on the above exponent and significand registers, so here's a kludgy approach
    fld %st(0)
    fabs
    fld %st(0)

    call fp_floor
    fxch
    fprem1
    fxch                            # top = integer, top - 1 = fractional
    fistpq 8(%rsp)                  # store integer
    mov 8(%rsp), %rdx

    mov $L_MAX_FLOAT_LEN, %rax
    test %rsi, %rsi
    cmovz %rax, %rsi
    cmp %rax, %rsi                  # compare requested precision to available precision
    cmovg %rax, %rsi
    mov $10, %rbx
    mov %rsi, %rcx
    call ipow                       # scale factor
    mov %rax, 8(%rsp)
    fildq 8(%rsp)
    fmul                            # multiply by fractional component
    fistpq 8(%rsp)
    mov 8(%rsp), %rax               # fractional component
    mov %rdx, %rsi                  # stash int component

    # rdx - integer part, rsi - fractional part
    mov $10, %rbx
Ldtoa_fraction_loop:                # handle the fractional part
    xor %rdx, %rdx
    div %rbx
    movb %dl, (%rdi)
    addb $'0', (%rdi)
    dec %rdi
    inc %r10
    test %rax, %rax
    jnz Ldtoa_fraction_loop

    movb $'.', (%rdi)
    dec %rdi
    inc %r10

    mov %rsi, %rax
Ldtoa_int_loop:                     # handle the integer part
    xor %rdx, %rdx
    div %rbx
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
    pop %rbx
    ret

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

start:
    sub $16, %rsp

    # -0
    fldz
    fchs
    call dtoa_write

    # 0
    fchs
    call dtoa_write

    # -pi
    fldpi
    fchs
    call dtoa_write

    # pi
    fchs
    call dtoa_write

    # inf
    fdivp
    call dtoa_write

    # -inf
    fchs
    call dtoa_write

    # -nan
    fldz
    fldz
    fdivp
    call dtoa_write

    # nan
    fchs
    call dtoa_write

    # denorm
    # TODO: fix this
    movq $1, 8(%rsp)
    fldl 8(%rsp)
    call dtoa_write

    # -denorm
    fchs
    call dtoa_write

    add $16, %rsp
    call exit

.data
Lnan: .ascii "nan"
.set Lnan_len, . - Lnan
Linf: .ascii "inf"
.set Linf_len, . - Linf
Lnorm: .ascii "norm"
.set Lnorm_len, . - Lnorm
Ldenorm: .ascii "denorm"
.set Ldenorm_len, . - Ldenorm

