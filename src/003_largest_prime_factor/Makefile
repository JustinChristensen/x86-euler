TOPDIR := ../..
S_PROG := largest_prime
C_PROG := $(S_PROG)_c

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	./$(S_PROG) | grep '6857' &> /dev/null
