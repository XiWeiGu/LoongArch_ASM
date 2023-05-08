CROSS_COMPILE ?= loongarch64-linux-gnu-
CC = $(CROSS_COMPILE)gcc
all: asm.S test.S utest.c
	$(CC) asm.S test.S utest.c -o utest -g
clean:
	rm -f *.o utest *.out