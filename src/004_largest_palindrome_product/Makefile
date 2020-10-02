TOPDIR := ../..
S_PROG := largest_palindrome
C_PROG := $(S_PROG)_c

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	./$(S_PROG) | grep '906609' &> /dev/null
