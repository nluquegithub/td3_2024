PROGRAMA = factorial_ASCII
all:
	arm-linux-gnueabihf-as -g -o $(PROGRAMA).o $(PROGRAMA).s
	arm-linux-gnueabihf-ld -g -o $(PROGRAMA).elf $(PROGRAMA).o -Map $(PROGRAMA).map -T td3_memmap.ld
	arm-linux-gnueabihf-objdump -g $(PROGRAMA).elf > $(PROGRAMA).lst
	arm-linux-gnueabihf-objcopy -g -O binary $(PROGRAMA).elf $(PROGRAMA).bin
	qemu-system-arm -M realview-pb-a8 -m 32M -no-reboot -nographic -monitor telnet:127.0.0.1:1234,server,nowait -S -gdb tcp::2159 -kernel $(PROGRAMA).bin

debug:
	ddd --debugger gdb-multiarch $(PROGRAMA).elf

clean:
	rm -f *.bin *.elf *.o *.lst *.map
