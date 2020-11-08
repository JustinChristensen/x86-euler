.p2align 4

L_SYS_MMAP = 0x20000c5

ONE_PAGE = 4096

PROT_NONE = 0x00
PROT_READ = 0x01
PROT_WRITE = 0x02
PROT_EXEC = 0x04

MAP_FILE = 0x0000
MAP_ANON = 0x1000
MAP_FIXED = 0x0010
MAP_SHARED = 0x0001
MAP_PRIVATE = 0x0002

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

