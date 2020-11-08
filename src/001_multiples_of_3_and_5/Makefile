TOPDIR := ../..
S_PROG := multiples_of_3_and_5
C_PROG := $(S_PROG)_c

S_OBJS := exit.o io.o io_utils.o string.o

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	output=$$(./$(S_PROG)) && echo $$output | grep '233168' &> /dev/null
