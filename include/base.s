.p2align 4

L_SYS_MMAP = 0x20000c5

# rdi - hint address
# rsi - length to request, in bytes
# edx - protections (NONE | READ | WRITE | EXEC)
# ecx - flags (ANON | FILE | FIXED | PRIVATE | SHARED)
# r8d - file descriptor
# r9 - offset
.global mmap
mmap:
    mov $L_SYS_MMAP, %eax
    syscall
    ret

