all: asm.S test.S utest.c
	gcc asm.S test.S utest.c -o utest
clean:
	rm *.o utest
