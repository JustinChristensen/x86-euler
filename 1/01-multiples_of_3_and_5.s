.globl start

start:
    # ...
    movq $0x2000001, %rax	# exit syscall (see disassembly of /usr/lib/system/libsystem_kernel.dylib)
    movq $100, %rdi		    # exit code
    syscall

