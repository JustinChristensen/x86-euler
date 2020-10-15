TOPDIR := ../..
S_PROG := even_fibs
C_PROG := $(S_PROG)_c

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	output=$$(./$(S_PROG)) && echo $$output | grep '4613732' &> /dev/null
