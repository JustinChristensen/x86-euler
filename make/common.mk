S_SOURCE ?= main.s
C_SOURCE ?= main.c

AS := as
AS_FLAGS := -static -Wall -Wextra

LD := ld
LD_FLAGS := -static
ifdef BYTE_ALIGN
	LD_FLAGS += -segalign 1
endif

CFLAGS := -O

ifndef NO_DEBUG
    CFLAGS += -g
	AS_FLAGS += -g
endif

all: $(S_PROG)

$(S_PROG): $(S_SOURCE)
	$(AS) $(AS_FLAGS) -o $@.o $^
	$(LD) $(LD_FLAGS) -o $@ $@.o
ifndef NO_DEBUG
	dsymutil $@
endif

ifdef C_PROG
$(C_PROG): $(C_SOURCE)
	$(CC) $(CFLAGS) -o $@ $^
endif

ifdef C_SOURCE
optimized.s: $(C_SOURCE)
	$(CC) $(CFLAGS) -S -o $@ $^
endif

.PHONY: clean
clean:
	rm -rf *.o *.dSYM $(C_PROG) $(S_PROG) optimized.s


