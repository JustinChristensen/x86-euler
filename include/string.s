.p2align 4

# rdi - buffer pointer
# eax - running length for string
.global newline
newline:
    inc %rax
    movb $'\n', (%rdi)
    dec %rdi
    ret

.global uint_to_str_nl
uint_to_str_nl:
    xor %eax, %eax
    call newline
    call _uint_to_str
    ret

# length = to_str &rdi esi
# rdi - pointer to end of string storage and result pointer after decrementing by length
# rsi - unsigned integer to stringify
# rax - length of string
.global uint_to_str
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

.global space
space:
    mov $1, %eax
    movb $' ', (%rdi)
    ret

# rsi - pointer to string
# rax - string length
.global strlen
strlen:
    xor %rax, %rax
    jmp Lstrlen_loop_test
Lstrlen_loop:
    inc %rax
Lstrlen_loop_test:
    cmpb $0, (%rsi, %rax)
    jnz Lstrlen_loop
    ret

