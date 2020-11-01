.global start
.p2align 4

.set L_MAX_FLOAT_LEN, 18
.set L_SIGN_MASK, 0x8000000000000000
.set L_EXP_MASK, 0x7FF0000000000000
.set L_SIG_MASK, 0xFFFFFFFFFFFFF

# this version uses multiplication to scale the fractional part of the floating point value
# and so it can't handle the full range of values a double precision floating point value can represent
# buyer beware
dtoa:
    push %rdi
    push %rsi
    push %rbx
    push %rcx
    push %rdx
    sub $32, %rsp

    fistl 16(%rsp)
    mov 16(%rsp), %rsi

    xor %r10, %r10                  # length

    # detecting +-inf, nan, and +-0
    mov $L_EXP_MASK, %rbx
    and %rsi, %rbx                  # exponent
    shr $52, %rbx
    mov $L_SIG_MASK, %rdx
    and %rsi, %rdx                  # significand
    mov $L_SIGN_MASK, %rax
    and %rsi, %rax                  # sign
    shr $63, %rax
    jz Ldtoa_after_sign

    movb $'-', (%rdi)
    inc %r10
    inc %rdi
Ldtoa_after_sign:
    test %rbx, %rbx
    jz Ldtoa_maybe_zero             # zero exponent
    cmp $2047, %rbx
    jz Ldtoa_inf_nan
    jmp Ldtoa_norm_denorm
Ldtoa_maybe_zero:
    test %rdx, %rdx
    jnz Ldtoa_norm_denorm           # zero significand
    movb $'0', (%rdi)               # we found zero
    inc %rdi
    inc %r10
    jmp Ldtoa_end
Ldtoa_inf_nan:
    test %rdx, %rdx
    jz Ldtoa_inf
    mov $Lnan_len, %rcx
    lea Lnan(%rip), %rsi
    add %rcx, %r10
    rep movsb
    jmp Ldtoa_end
Ldtoa_inf:
    mov $Linf_len, %rcx
    lea Linf(%rip), %rsi
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
    fistpq 16(%rsp)                 # store integer
    mov 16(%rsp), %rax

    mov $L_MAX_FLOAT_LEN, %rax
    cmp %rax, %rsi                  # compare requested precision to available precision
    cmovg %rax, %rsi
    mov $10, %rbx
    mov %rsi, %rcx
    call ipow                       # scale factor
    mov %rax, 16(%rsp)
    fldl 16(%rsp)
    fmul                            # multiply by fractional component
    fistl 16(%rsp)
    mov 16(%rsp), %rsi              # fractional component

    # rax - integer part, rsi - fractional part
    mov $10, %rbx
    xor %rdx, %rdx
Ldtoa_int_loop:                     # handle the integer part
    div %rbx
    mov %rdx, (%rdi)
    addb $'0', (%rdi)
    inc %rdi
    inc %r10
    test %rax, %rax
    jnz Ldtoa_int_loop

    movb $'.', (%rdi)
    inc %rdi
    inc %r10

    mov %rsi, %rax
Ldtoa_fraction_loop:                # handle the fractional part
    div %rbx
    mov %rdx, (%rdi)
    addb $'0', (%rdi)
    inc %rdi
    inc %r10
    test %rax, %rax
    jnz Ldtoa_fraction_loop

Ldtoa_end:
    mov %r10, %rax      # return the length
    add $32, %rsp
    push %rdx
    push %rcx
    push %rbx
    push %rsi
    push %rdi           # this restores the rdi pointer back for the caller
    ret



# rdi - input/output pointer to ascii string storage
# rax - output string length
dtoa_old:
    push %rdi

    xor %rax, %rax                  # length

    mov $L_EXP_MASK, %rbx
    and %rsi, %rbx                  # exponent
    shr $52, %rbx
    mov $L_SIG_MASK, %rdx
    and %rsi, %rdx                  # significand
    mov $L_SIGN_MASK, %rbp
    and %rsi, %rbp                  # sign
    shr $63, %rbp
    jz Ldtoa_old_after_sign

    movb $'-', (%rdi)
    inc %rax
    inc %rdi
Ldtoa_old_after_sign:
    test %rbx, %rbx
    jz Ldtoa_old_denorm
    cmp $2047, %rbx
    jz Ldtoa_old_inf_nan
    jmp Ldtoa_old_norm
Ldtoa_old_denorm:
    test %rdx, %rdx
    jz Ldtoa_old_zero
    mov $Ldenorm_len, %rcx
    lea Ldenorm(%rip), %rsi
    add %rcx, %rax
    rep movsb
    jmp Ldtoa_old_end
Ldtoa_old_zero:
    movb $'0', (%rdi)
    inc %rdi
    inc %rax
    jmp Ldtoa_old_end
Ldtoa_old_inf_nan:
    test %rdx, %rdx
    jz Ldtoa_old_inf
    mov $Lnan_len, %rcx
    lea Lnan(%rip), %rsi
    add %rcx, %rax
    rep movsb
    jmp Ldtoa_old_end
Ldtoa_old_inf:
    mov $Linf_len, %rcx
    lea Linf(%rip), %rsi
    add %rcx, %rax
    rep movsb
    jmp Ldtoa_old_end
Ldtoa_old_norm:
    mov $Lnorm_len, %rcx
    lea Lnorm(%rip), %rsi
    add %rcx, %rax
    rep movsb
Ldtoa_old_end:
    movb $'\n', (%rdi)
    inc %rax
    pop %rdi
    ret

dtoa_write:
    sub $64, %rsp
    mov %rsp, %rdi
    call dtoa

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
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # 0
    fchs
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # -pi
    fldpi
    fchs
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # pi
    fchs
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # inf
    fdivp
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # -inf
    fchs
    fstpl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # -nan
    fldz
    fldz
    fdivp
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # nan
    fchs
    fstpl 8(%rsp)
    mov 8(%rsp), %rsi
    call dtoa_write

    # denorm
    fldz
    fstl 8(%rsp)
    mov 8(%rsp), %rsi
    or $0x1, %rsi
    call dtoa_write

    # -denorm
    fchs
    fstpl 8(%rsp)
    mov 8(%rsp), %rsi
    or $0x1, %rsi
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

