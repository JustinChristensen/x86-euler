.p2align 4

.include "syms.s"

.global start
start:
    mov (%rsp), %rbx                # argc
    cmp $1, %rbx
    jle Lstart_end

    mov 16(%rsp), %rdi              # argv[0]
    mov $OPEN_RDONLY, %esi
    call open
    mov %eax, %ebp                  # file descriptor

    sub $160, %rsp
    mov %eax, %edi
    mov %rsp, %rsi
    call fstat
    mov %rsi, %rbx
    mov 72(%rbx), %rsi      # length
    add $160, %rsp

    xor %rdi, %rdi          # hint
    mov $PROT_READ, %edx    # protection
    xor %ecx, %ecx          # flags
    or $MAP_FILE, %ecx
    or $MAP_PRIVATE, %ecx
    mov %ebp, %r8d
    xor %r9d, %r9d            # offset
    call mmap

    mov %rax, %rsi
    call write_uint_nl

Lstart_end:
    call exit

