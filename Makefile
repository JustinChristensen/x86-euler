SOURCES := \
01-multiples_of_3_and_5.s
NOTES := notes

AS := as
AS_FLAGS := -static -Wall -Wextra
LD := ld
LD_FLAGS := -static
OBJDUMP := objdump
OBJDUMP_FLAGS := --print-imm-hex

define gen_rule
TARGETS += $1
CLEAN += $1
$1: $2
	$$(AS) $$(AS_FLAGS) -o $$@.o $$^
	$$(LD) $$(LD_FLAGS) -o $$@ $$@.o
	dsymutil $$@
endef

$(foreach S,$(SOURCES),$(eval $(call gen_rule,$(word 2,$(subst -, ,$(basename $(S)))), $(S))))

.PHONY: dump_kernel_lib
dump_kernel_lib: KERNEL_LIB := /usr/lib/system/libsystem_kernel.dylib
dump_kernel_lib:
	$(OBJDUMP) $(OBJDUMP_FLAGS) -d $(KERNEL_LIB) > $(NOTES)/kernel_disasm.s

.PHONY: clean
clean:
	rm -rf *.o *.dSYM $(CLEAN)


