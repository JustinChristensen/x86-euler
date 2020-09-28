L_SYS_WRITE = 0x2000004
L_STDOUT = 1

# edx - string length
# rsi - string pointer
write:
    movl $L_STDOUT, %edi
    movl $L_SYS_WRITE, %eax
    syscall
    retq

