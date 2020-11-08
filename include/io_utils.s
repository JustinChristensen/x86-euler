.p2align 4

# rsi - unsigned integer to stringify
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
    call write_stdout           # write to stdout

    add $16, %rsp               # reclaim string storage
    pop %rdx
    pop %rsi
    ret

