TOPDIR := ../..
S_PROG := smallest_multiple
C_PROG := $(S_PROG)_c

S_OBJS := exit.o io.o io_utils.o string.o

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	output=$$(./$(S_PROG)) && echo $$output | grep '232792560' &> /dev/null
