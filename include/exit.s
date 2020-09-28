L_SYS_EXIT = 0x2000001
L_SUCCESS = 0

exit:
    movl $L_SYS_EXIT, %eax
    movl $L_SUCCESS, %edi
    syscall
    retq

