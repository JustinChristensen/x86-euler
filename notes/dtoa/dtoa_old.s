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

