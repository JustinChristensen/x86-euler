TOPDIR := ../..
S_PROG := even_fibs
C_PROG := $(S_PROG)_c

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	./$(S_PROG) | grep '4613732' &> /dev/null
