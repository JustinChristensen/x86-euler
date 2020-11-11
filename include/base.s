.p2align 4

L_SYS_MMAP = 0x20000c5

# rdi - hint address
# rsi - length to request, in bytes
# edx - protections (NONE | READ | WRITE | EXEC)
# ecx - flags (ANON | FILE | FIXED | PRIVATE | SHARED)
# r8d - file descriptor
# r9 - offset
# clobbers: r11 (syscall)
.global mmap
mmap:
    push %r10
    mov %ecx, %r10d
    mov $L_SYS_MMAP, %eax
    syscall
    pop %r10
    ret

# rdi - pointer to
# rsi - value to set
# rcx - length in quadwords
.global memset
memset:
    push %rax
    mov %rsi, %rax
    rep stosq
    pop %rax
    ret

# rdi - pointer to
# rcx - length in quadwords
.global zeromem
zeromem:
    push %rsi
    xor %rsi, %rsi
    call memset
    pop %rsi
    ret

