.global start
.p2align 4

.include "io.s"
.include "exit.s"

start:
    lea foo(%rip), %rdi
    movb $'A', %al
    mov foo_len(%rip), %ecx
    rep stosb
    decq %rdi
    movb $'\n', (%rdi)
    lea foo(%rip), %rsi
    mov foo_len(%rip), %edx
    callq write
    call exit

.data
.p2align 4
foo:
.space 2048
foo_len:
.long . - foo


