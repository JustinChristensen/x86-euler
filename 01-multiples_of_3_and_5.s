.intel_syntax
.global start

.set SYS_EXIT, 0x2000001
.set SUCCESS, 100

exit:
    mov rax, SYS_EXIT	# exit syscall (see disassembly of /usr/lib/system/libsystem_kernel.dylib)
    mov rdi, SUCCESS    # exit code
    syscall

start:
    # ...
    jmp exit

