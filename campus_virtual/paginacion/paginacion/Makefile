all:
	arm-linux-gnueabihf-as -g -o startup.o startup.s
	arm-linux-gnueabihf-ld -g -o first_test.elf startup.o -Map first_test.map -T td3_memmap.ld
	arm-linux-gnueabihf-objdump -g first_test.elf > first_test.lst
	readelf -a first_test.elf > first_test_elf.txt
	arm-linux-gnueabihf-objcopy -g -O binary first_test.elf first_test.bin
	qemu-system-arm -M realview-pb-a8 -m 32M -no-reboot -nographic -monitor telnet:127.0.0.1:1234,server,nowait -S -gdb tcp::2159 -kernel first_test.bin

debug:
	rm ~/.ddd/init
	ddd --debugger "gdb-multiarch -x gdb_init_commands.txt" first_test.elf

clean:
	rm -f *.o *.lst *.elf *.map *.bin
