TOPDIR := ../..
S_PROG := rounded_sqrts
C_PROG := $(S_PROG)_c

S_OBJS := exit.o float.o int.o io.o io_utils.o string.o

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	output=$$(./$(S_PROG)) && echo $$output | grep '3.2102888889' &> /dev/null


