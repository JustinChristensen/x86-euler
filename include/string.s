# length = to_str &rdi esi
# rdi - pointer to end of string storage and result pointer after decrementing by length
# esi - unsigned integer to stringify
# eax - length of string
uint_to_str:
    movl $1, %r10d               # length
    movb $'\n', %dl              # append newline
    movb %dl, (%rdi)
    xorl %edx, %edx
    movl %esi, %eax              # edx:eax
    movl $10, %r11d              # divisor
Luint_to_str_loop:
    decq %rdi                    # pointer--
    incl %r10d                   # length++
    divl %r11d
    addb $'0', %dl
    movb %dl, (%rdi)
    xorl %edx, %edx              # clear edx, otherwise quotients >= 2^w result in a floating point exception with DIV
    testl %eax, %eax
    jg Luint_to_str_loop         # quotient > 0
    movl %r10d, %eax             # return length
    retq

