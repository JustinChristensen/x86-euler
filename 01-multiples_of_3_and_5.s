.text
.global start

SYS_EXIT = 0x2000001
SYS_WRITE = 0x2000004
SUCCESS = 100
STDOUT = 1

exit:
    movl $SYS_EXIT, %eax
    movl $SUCCESS, %edi
    syscall

write:
    movl $STDOUT, %edi
    leaq hello(%rip), %rsi
    movl $hello_len, %edx
    movl $SYS_WRITE, %eax
    syscall
    jmp *%r8

start:
    leaq do_exit(%rip), %r8
    jmp write
do_exit:
    jmp exit

.data

hello:
    .ascii "hello, world!\n"
hello_len = . - hello
