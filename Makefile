edit : *.asm
	nasm -f elf client.asm -o client.o
	ld -m elf_i386 client.o -o client
clean :	*.asm
	rm client.o client