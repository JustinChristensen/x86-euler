.ifndef L_INCLUDE_STRING
.set L_INCLUDE_STRING, 1

.include "io.s"

# rdi - buffer pointer
# eax - running length for string
newline:
    inc %rax
    movb $'\n', (%rdi)
    dec %rdi
    ret

uint_to_str_nl:
    xor %eax, %eax
    call newline
    call _uint_to_str
    ret

# length = to_str &rdi esi
# rdi - pointer to end of string storage and result pointer after decrementing by length
# esi - unsigned integer to stringify
# eax - length of string
uint_to_str:
    xor %eax, %eax
_uint_to_str:
    mov %rax, %r10              # length
    mov %rsi, %rax              # edx:eax
    mov $10, %r11               # divisor
Luint_to_str_loop:
    xor %edx, %edx              # clear edx, otherwise quotients >= 2^w result in a floating point exception with DIV
    div %r11
    add $'0', %dl
    mov %dl, (%rdi)
    dec %rdi                    # pointer--
    inc %r10                    # length++
    test %rax, %rax
    jg Luint_to_str_loop         # quotient > 0
    inc %rdi
    mov %r10, %rax             # return length
    ret

space:
    mov $1, %eax
    movb $' ', (%rdi)
    ret

.endif      # L_INCLUDE_STRING
