TOPDIR := ../..
S_PROG := blend

S_OBJS := base.o exit.o io.o io_utils.o string.o

DYNAMIC := 1
LIBS := -lSystem -lz

CLEAN += blend_c

include $(TOPDIR)/make/common.mk

$(S_PROG)_c: main.c
	$(CC) -Wall -Wextra -o $@ $^ -lz

