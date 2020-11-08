.p2align 4

L_SYS_WRITE = 0x2000004
L_SYS_OPEN = 0x2000005
L_SYS_READ = 0x2000003
L_SYS_FSTAT = 0x20000bd

STDOUT = 1
OPEN_RDONLY = 0x0000
OPEN_WRONLY = 0x0001

# edx - string length
# rsi - string pointer
.global write
write:
    push %rcx
    mov $STDOUT, %edi
    mov $L_SYS_WRITE, %eax
    syscall
    pop %rcx
    ret

# TODO: think about whether it makes sense to turn this into
# write :: (a -> String) -> IO () or not
.global write_space
write_space:
    lea space(%rip), %rax
    jmp Lwrite_uint
.global write_uint_nl
write_uint_nl:
    lea uint_to_str_nl(%rip), %rax
    jmp Lwrite_uint
.global write_uint
write_uint:
    lea uint_to_str(%rip), %rax
Lwrite_uint:
    push %rsi
    push %rdx
    mov %rsp, %rdi
    sub $16, %rsp               # make space for the integer ascii string
    dec %rdi

    call *%rax                  # convert answer to string

    mov %rdi, %rsi
    mov %eax, %edx
    call write                  # write to stdout

    add $16, %rsp               # reclaim string storage
    pop %rdx
    pop %rsi
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

