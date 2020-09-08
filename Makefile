SOURCES := \
01-multiples_of_3_and_5.s

AS_FLAGS := -static -Wall -Wextra -g
LD_FLAGS := -static

define gen_rule
TARGETS += $1
CLEAN += $1
$1: $2
	as $$(AS_FLAGS) -o $$@.o $$^
	ld $$(LD_FLAGS) -o $$@ $$@.o
	rm $$@.o
endef

$(foreach S,$(SOURCES),$(eval $(call gen_rule,$(word 2,$(subst -, ,$(basename $(S)))), $(S))))

.PHONY: clean
clean:
	rm -rf *.o $(CLEAN)


