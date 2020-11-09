.p2align 4

.include "syms.s"

L_PNG_SIGNATURE = 0x0a1a0a0d474e5089
L_PNG_IHDR = 0x52444849
L_PNG_IEND = 0x444e4549

.global not_png_error
not_png:
    lea not_png_error(%rip), %rsi
    mov not_png_error_len(%rip), %edx
    call write_stdout
    call exit                       # TODO: exit nonzero

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

    mov %rax, %rbp
    mov $L_PNG_SIGNATURE, %rax
    cmpq %rax, (%rbp)
    je Lstart_png
    call not_png
Lstart_png:
    add $8, %rbp        # skip over png signature
    jmp L_png_loop_test
L_png_loop:
    mov %ecx, %esi
    call write_uint_nl
    movbe (%rbp), %ebx
    lea 12(%rbp, %rbx), %rbp      # increment pointer (length) + length + type + crc
L_png_loop_test:
    mov 4(%rbp), %ecx
    cmp $L_PNG_IEND, %ecx
    jne L_png_loop
    mov %ecx, %esi
    call write_uint_nl           # print end

Lstart_end:
    call exit

.data
not_png_error:     .ascii "input file is not a png\n"
not_png_error_len: .long . - not_png_error

