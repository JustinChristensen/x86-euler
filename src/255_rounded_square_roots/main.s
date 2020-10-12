.global start
.p2align 4

.include "exit.s"
.include "io.s"
.include "string.s"

# TODO unwrap this for the outer loop
fp_floor:
    fstcw (%rdi)
    orw $0xc00, (%rdi)     # round to zero
    fldcw (%rdi)

    frndint

    andw $0xf3ff, (%rdi)   # TODO restore round mode back to original, for now round-to-even
    fldcw (%rdi)

    ret

# ebx - input integer
# eax - number of digits for integer
fp_ndigits:
    sub $16, %rsp

    fldl2t
    fld1
    fdiv                    # 1 / log2(10)

    movl %ebx, 8(%rsp)
    fildl 8(%rsp)           # load x

    fyl2x                   # 1 / log2(10) * log2(x)

    fld1
    fadd                    # log10(x) + 1

    lea 4(%rsp), %rdi
    callq fp_floor          # floor(log10(x) + 1)

    fistl 8(%rsp)
    mov 8(%rsp), %eax

    add $16, %rsp

    ret

# herons:

start:
    call fp_ndigits
    call exit

