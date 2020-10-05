L_SYS_EXIT = 0x2000001
L_SUCCESS = 0

exit:
    mov $L_SYS_EXIT, %eax
    mov $L_SUCCESS, %edi
    syscall
    ret

