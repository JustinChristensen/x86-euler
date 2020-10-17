.global start
.p2align 4

.include "io.s"
.include "exit.s"

.set L_SIGN_MASK, 0x8000000000000000
.set L_EXP_MASK, 0x7FF0000000000000
.set L_SIG_MASK, 0xFFFFFFFFFFFFF

# rdi - input/output pointer to ascii string storage
# rax - output string length
dtoa:
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
    jz Ldtoa_after_sign

    movb $'-', (%rdi)
    inc %rax
    inc %rdi
Ldtoa_after_sign:
    test %rbx, %rbx
    jz Ldtoa_denorm
    cmp $2047, %rbx
    jz Ldtoa_inf_nan
    jmp Ldtoa_norm
Ldtoa_denorm:
    test %rdx, %rdx
    jz Ldtoa_zero
    mov $Ldenorm_len, %rcx
    lea Ldenorm(%rip), %rsi
    add %rcx, %rax
    rep movsb
    jmp Ldtoa_end
Ldtoa_zero:
    movb $'0', (%rdi)
    inc %rdi
    inc %rax
    jmp Ldtoa_end
Ldtoa_inf_nan:
    test %rdx, %rdx
    jz Ldtoa_inf
    mov $Lnan_len, %rcx
    lea Lnan(%rip), %rsi
    add %rcx, %rax
    rep movsb
    jmp Ldtoa_end
Ldtoa_inf:
    mov $Linf_len, %rcx
    lea Linf(%rip), %rsi
    add %rcx, %rax
    rep movsb
    jmp Ldtoa_end
Ldtoa_norm:
    mov $Lnorm_len, %rcx
    lea Lnorm(%rip), %rsi
    add %rcx, %rax
    rep movsb
Ldtoa_end:
    movb $'\n', (%rdi)
    inc %rax
    pop %rdi
    ret

dtoa_write:
    sub $16, %rsp
    mov %rsp, %rdi
    call dtoa

    mov %rax, %rdx
    mov %rdi, %rsi
    call write
    add $16, %rsp
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

