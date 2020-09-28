OBJDUMP := objdump
OBJDUMP_FLAGS := --print-imm-hex
TARGETS := $(wildcard src/*)

.PHONY: all
all: $(TARGETS)

.PHONY: $(TARGETS)
$(TARGETS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: clean
clean: $(TARGETS)

.PHONY: dump_kernel_lib
dump_kernel_lib: KERNEL_LIB := /usr/lib/system/libsystem_kernel.dylib
dump_kernel_lib:
	$(OBJDUMP) $(OBJDUMP_FLAGS) -d $(KERNEL_LIB) > kernel_disasm.s

