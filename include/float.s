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

