TOPDIR := ../..
S_PROG := smallest_multiple
C_PROG := $(S_PROG)_c

include $(TOPDIR)/make/common.mk

test: $(S_PROG)
	./$(S_PROG) | grep '232792560' &> /dev/null
