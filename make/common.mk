TOPDIR ?= .
S_SOURCE ?= main.s
S_OBJS ?= exit.o
C_SOURCE ?= main.c

S_OBJS := $(addprefix $(TOPDIR)/include/, $(S_OBJS))

AS := as
AS_FLAGS := -static -Wall -Wextra

LD := ld
LD_FLAGS := -static -dead_strip
ifdef BYTE_ALIGN
	LD_FLAGS += -segalign 1
endif

CFLAGS := -O -Wall -Wextra
OP_CFLAGS := $(CFLAGS) -fno-verbose-asm

ifndef NO_DEBUG
    CFLAGS += -g
	AS_FLAGS += -g
endif

$(S_PROG): $(S_SOURCE) $(S_OBJS)
	$(AS) -I$(TOPDIR)/include $(AS_FLAGS) -o $@.o $(S_SOURCE)
	$(LD) $(LD_FLAGS) -o $@ $@.o $(S_OBJS)
ifndef NO_DEBUG
	dsymutil $@
endif

%.o: %.s
	$(AS) -I$(TOPDIR)/include $(AS_FLAGS) -o $@ $<

ifdef C_PROG
$(C_PROG): $(C_SOURCE)
	$(CC) $(CFLAGS) -o $@ $^
endif

ifdef C_SOURCE
optimized.s: $(C_SOURCE)
	$(CC) $(OP_CFLAGS) -S -o $@ $^
endif

.PHONY: clean
clean:
	rm -rf *.o *.dSYM $(C_PROG) $(S_PROG) optimized.s


