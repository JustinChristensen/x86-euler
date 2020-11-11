.p2align 4

.include "syms.s"

L_PNG_SIGNATURE = 0x0a1a0a0d474e5089
L_PNG_IHDR = 0x52444849
L_PNG_IDAT = 0x54414449
L_PNG_IEND = 0x444e4549

.global not_png_error
not_png:
    lea not_png_error(%rip), %rsi
    mov not_png_error_len(%rip), %edx
    call write_stdout
    call exit                       # TODO: exit nonzero

.global _main
_main:
    # 16-byte align the stack pointer

    # normally, I would expect this to already be done, but the dynamic loader seems to
    # anticipate that main will push an 8 byte value onto the stack (maybe rbp), and that
    # that will align the stack to the 16-byte boundary

    # WARNING: dyld will throw an error for calls it resolves if the stack is not 16-byte aligned
    sub $8, %rsp

    # mov (%rsp), %rbx                # argc (system v start)
    mov %rdi, %rbx                    # dynamic main
    cmp $1, %rbx
    jle Lstart_end

    # mov 16(%rsp), %rdi              # argv[0] (system v start)
    mov 8(%rsi), %rdi
    mov $OPEN_RDONLY, %esi
    call open                       # TODO: close
    mov %eax, %r15d                  # file descriptor

    sub $160, %rsp
    mov %eax, %edi
    mov %rsp, %rsi
    call fstat
    mov %rsi, %rbx
    mov 72(%rbx), %r14      # length
    add $160, %rsp

    # mmap input file
    xor %rdi, %rdi          # hint
    mov %r14, %rsi          # length
    mov $PROT_READ, %edx    # protection
    xor %ecx, %ecx          # flags
    or $MAP_FILE, %ecx
    or $MAP_PRIVATE, %ecx
    mov %r15d, %r8d
    xor %r9d, %r9d            # offset
    call mmap                 # TODO: unmap?
    mov %rax, %rbp

    # mmap scratch space for deflating the png
    xor %rdi, %rdi          # hint
    mov %r14, %rsi          # length
    mov $PROT_READ, %edx
    or $PROT_WRITE, %edx    # protection
    xor %ecx, %ecx          # flags
    or $MAP_ANON, %ecx
    or $MAP_PRIVATE, %ecx
    mov $-1, %r8d
    xor %r9d, %r9d            # offset
    call mmap
    mov %rax, %r10           # pointer to scratch space

    mov $L_PNG_SIGNATURE, %rax
    cmpq %rax, (%rbp)
    je Lstart_png
    call not_png

Lstart_png:
    add $8, %rbp        # skip over png signature
    mov $4, %edx        # TEMP: chunk type
    jmp L_png_loop_test
L_png_loop:
    lea 4(%rbp), %rsi
    call putstrln
    movbe (%rbp), %ebx
    lea 12(%rbp, %rbx), %rbp      # increment pointer (length) + length + type + crc
L_png_loop_test:
    cmpl $L_PNG_IDAT, 4(%rbp)
    je L_first_idat
    cmpl $L_PNG_IEND, 4(%rbp)
    jne L_png_loop
    lea 4(%rbp), %rsi
    call putstrln           # print end

L_first_idat:
    sub $128, %rsp

    mov %rsp, %rdi
    mov $16, %rcx
    call zeromem
    mov %rsp, %rdi

    # r10 - scratch space to inflate data into
    # rbp - input file
    leaq 8(%rbp), %rax
    mov %rax, (%rdi)            # next_in
    movbe (%rbp), %eax
    mov %eax, 8(%rdi)           # avail_in
    mov %r10, 24(%rdi)          # next_out
    mov %r14, 32(%rdi)          # avail_out
    xor %rsi, %rsi
    call _inflate

    add $128, %rsp

Lstart_end:
    add $8, %rsp

    call exit

.data
not_png_error:     .ascii "input file is not a png\n"
not_png_error_len: .long . - not_png_error

