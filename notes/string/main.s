.global start
.p2align 4

.include "io.s"
.include "exit.s"

repeat:
    lea foo(%rip), %rdi
    movb $'A', %al
    mov foo_len(%rip), %ecx
    rep stosb
    movb $'\n', -1(%rdi)
    ret

random:
    lea foo(%rip), %rdi
    mov foo_len(%rip), %ecx
    shr $2, %ecx
Lrandom_loop:
    rdrand %eax
    mov %eax, -4(%rdi, %rcx, 4)
    loop Lrandom_loop
    mov foo_len(%rip), %ecx
    movb $'\n', -1(%rdi, %rcx)
    ret

start:
    call repeat
    lea foo(%rip), %rsi
    mov foo_len(%rip), %edx
    call write

    call random
    lea foo(%rip), %rsi
    mov foo_len(%rip), %edx
    call write

    call exit

.data
.p2align 4
foo:
.space 2048
foo_len:
.long . - foo


