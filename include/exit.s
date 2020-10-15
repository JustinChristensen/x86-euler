.ifndef L_INCLUDE_EXIT
.set L_INCLUDE_EXIT, 1

L_SYS_EXIT = 0x2000001
L_SUCCESS = 0

exit:
    mov $L_SYS_EXIT, %eax
    mov $L_SUCCESS, %edi
    syscall
    ret

.endif      # L_INCLUDE_EXIT
