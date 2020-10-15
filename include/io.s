.ifndef L_INCLUDE_IO
.set L_INCLUDE_IO, 1

.include "string.s"

L_SYS_WRITE = 0x2000004
L_STDOUT = 1

# edx - string length
# rsi - string pointer
write:
    mov $L_STDOUT, %edi
    mov $L_SYS_WRITE, %eax
    syscall
    ret

# TODO: think about whether it makes sense to turn this into
# write :: (a -> String) -> IO () or not
write_space:
    lea space(%rip), %rax
    jmp Lwrite_uint
write_uint_nl:
    lea uint_to_str_nl(%rip), %rax
    jmp Lwrite_uint
write_uint:
    lea uint_to_str(%rip), %rax
Lwrite_uint:
    mov %rsp, %rdi
    sub $16, %rsp               # make space for the integer ascii string
    dec %rdi

    call *%rax                  # convert answer to string

    mov %rdi, %rsi
    mov %eax, %edx
    call write                  # write to stdout

    add $16, %rsp               # reclaim string storage
    ret

.endif      # L_INCLUDE_IO
