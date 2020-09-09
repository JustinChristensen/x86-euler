.intel_syntax
.global start

SYS_EXIT = 0x2000001
SYS_WRITE = 0x2000004
SUCCESS = 100
STDOUT = 1

exit:
    mov eax, SYS_EXIT
    mov edi, SUCCESS
    syscall

write:
    mov edi, STDOUT
    lea rsi, [rip + hello]
    mov edx, [rip + hello_len]
    mov eax, SYS_WRITE
    syscall
    jmp r8

start:
    lea r8, [rip + do_exit]
    jmp write
do_exit:
    jmp exit

.data

hello:
    .ascii "hello, world!\n"
hello_len:
    .long .  - hello
