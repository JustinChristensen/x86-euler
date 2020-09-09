.text
.global start

SYS_EXIT = 0x2000001
SYS_WRITE = 0x2000004
SUCCESS = 0
STDOUT = 1

exit:
    movl $SYS_EXIT, %eax
    movl $SUCCESS, %edi
    syscall
    retq

write:
    movl $STDOUT, %edi
    leaq hello(%rip), %rsi
    movl $hello_len, %edx
    movl $SYS_WRITE, %eax
    syscall
    retq

start:
    callq write
    callq exit

.data

hello:
    .ascii "hello, world!\n"
hello_len = . - hello
