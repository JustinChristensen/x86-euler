.global start
.p2align 4

start:
    sub $16, %rsp

    # -0
    fldz
    fchs
    call dtoa_write

    # 0
    fchs
    call dtoa_write

    mov $10, %rbx
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
    movq $1, 8(%rsp)
    fldl 8(%rsp)
    call dtoa_write

    # -denorm
    fchs
    call dtoa_write

    add $16, %rsp
    call exit

