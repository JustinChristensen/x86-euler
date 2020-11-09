TOPDIR := ../..
S_PROG := blend

S_OBJS := base.o exit.o io.o io_utils.o string.o

include $(TOPDIR)/make/common.mk

# ./blend image.png | while read line; do (txt=$(printf "0x%x\n" $line | xxd -r | rev) && echo "$txt"); done > chunks.txt
