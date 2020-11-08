.p2align 4

L_SYS_WRITE = 0x2000004
L_SYS_OPEN = 0x2000005
L_SYS_READ = 0x2000003
L_SYS_FSTAT = 0x20000bd

STDOUT = 1
OPEN_RDONLY = 0x0000
OPEN_WRONLY = 0x0001

# edi - file descriptor
# edx - string length
# rsi - string pointer
.global write
write:
    push %rcx
    mov $L_SYS_WRITE, %eax
    syscall
    pop %rcx
    ret

# edx - string length
# rsi - string pointer
.global write_stdout
write_stdout:
    mov $STDOUT, %edi
    call write
    ret

# rdi - path
# esi - open flags
# eax - return file descriptor
# eax - return status
.global open
open:
    mov $L_SYS_OPEN, %eax
    syscall
    ret

# edi - file descriptor
# rsi - pointer to stat buffer
# eax - return status
.global fstat
fstat:
    mov $L_SYS_FSTAT, %eax
    syscall
    ret

# edi - file descriptor
# rsi - pointer to character buffer
# rdx - number of bytes to read
# rax - number of bytes read
.global read
read:
    mov $L_SYS_READ, %eax
    syscall
    ret

