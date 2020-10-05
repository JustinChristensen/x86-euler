L_SYS_WRITE = 0x2000004
L_STDOUT = 1

# edx - string length
# rsi - string pointer
write:
    mov $L_STDOUT, %edi
    mov $L_SYS_WRITE, %eax
    syscall
    ret

