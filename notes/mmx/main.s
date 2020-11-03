.p2align 4

.global start
start:
    sub $32, %rsp
    movb $127, 15(%rsp)
    movb $125, 14(%rsp)
    movb $115, 13(%rsp)
    movb $110, 12(%rsp)
    movb $100, 11(%rsp)
    movb $91, 10(%rsp)
    movb $82, 9(%rsp)
    movb $75, 8(%rsp)
    movq 8(%rsp), %mm0

    movb $79, 8(%rsp)
    movb $89, 9(%rsp)
    movb $99, 10(%rsp)
    movb $110, 11(%rsp)
    movb $121, 12(%rsp)
    movb $125, 13(%rsp)
    movb $130, 14(%rsp)
    movb $155, 15(%rsp)
    movq 8(%rsp), %mm1

    paddusb %mm0, %mm1

    movq %mm1, 8(%rsp)
    mov $0, %rcx
Lprint_loop:
    lea 32(%rsp), %rdi
    movb 8(%rsp, %rcx), %sil
    xor %rax, %rax
    call write_uint_nl
    inc %rcx
    cmp $8, %rcx
    jnz Lprint_loop

    add $32, %rsp
    call exit

