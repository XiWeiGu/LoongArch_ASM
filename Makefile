all: asm.S test.S utest.c
	gcc asm.S test.S utest.c -o utest -g
clean:
	rm -f *.o utest *.out
