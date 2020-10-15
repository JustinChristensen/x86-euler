TOPDIR := ../..
S_PROG := largest_prime
C_PROG := $(S_PROG)_c

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	output=$$(./$(S_PROG)) && echo $$output | grep '6857' &> /dev/null

