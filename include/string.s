# rdi - buffer pointer
# eax - running length for string
newline:
    incl %eax
    movb $'\n', (%rdi)
    decq %rdi
    retq

uint_to_str_nl:
    xorl %eax, %eax
    callq newline
    callq _uint_to_str
    retq

# length = to_str &rdi esi
# rdi - pointer to end of string storage and result pointer after decrementing by length
# esi - unsigned integer to stringify
# eax - length of string
uint_to_str:
    xorl %eax, %eax
_uint_to_str:
    movl %eax, %r10d             # length
    movl %esi, %eax              # edx:eax
    movl $10, %r11d              # divisor
Luint_to_str_loop:
    xorl %edx, %edx              # clear edx, otherwise quotients >= 2^w result in a floating point exception with DIV
    divl %r11d
    addb $'0', %dl
    movb %dl, (%rdi)
    decq %rdi                    # pointer--
    incl %r10d                   # length++
    testl %eax, %eax
    jg Luint_to_str_loop         # quotient > 0
    incq %rdi
    movl %r10d, %eax             # return length
    retq

