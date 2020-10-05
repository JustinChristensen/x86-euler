# rdi - buffer pointer
# eax - running length for string
newline:
    inc %eax
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
    mov %eax, %r10d             # length
    mov %esi, %eax              # edx:eax
    mov $10, %r11d              # divisor
Luint_to_str_loop:
    xor %edx, %edx              # clear edx, otherwise quotients >= 2^w result in a floating point exception with DIV
    div %r11d
    add $'0', %dl
    mov %dl, (%rdi)
    dec %rdi                    # pointer--
    inc %r10d                   # length++
    test %eax, %eax
    jg Luint_to_str_loop         # quotient > 0
    inc %rdi
    mov %r10d, %eax             # return length
    ret

