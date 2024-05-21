#CHAIN=arm-none-eabi
CHAIN=arm-linux-gnueabihf
CFLAGS=-std=gnu99 -Wall -mcpu=cortex-a8

OBJ=obj/
BIN=bin/
INC=inc/
SRC=src/
LST=lst/

all: $(BIN)mi_suma.bin $(OBJ)mi_suma.elf

$(BIN)mi_suma.bin: $(OBJ)mi_suma.elf
	$(CHAIN)-objcopy -O binary $< $@


$(OBJ)mi_suma.elf: $(OBJ)suma_abi.o $(OBJ)suma_c.o
	@echo "Linkeando ... "
	mkdir -p obj
	mkdir -p lst
	$(CHAIN)-ld -g -T td3_memmap.ld $(OBJ)*.o -o $(OBJ)mi_suma.elf -Map $(LST)mi_suma.map
	@echo "Linkeo finalizado!!"
	@echo ""
	@echo "Generando archivos de información: mapa de memoria y símbolos"
	readelf -a $(OBJ)mi_suma.elf > $(LST)mi_suma_elf.txt
	$(CHAIN)-objdump -D $(OBJ)mi_suma.elf > $(LST)mi_suma.lst

$(OBJ)suma_abi.o: $(SRC)suma_abi.s
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Ensamblando suma_abi.s ..."
	$(CHAIN)-as $(SRC)suma_abi.s -g -o $(OBJ)suma_abi.o -a > $(LST)suma_abi.lst

$(OBJ)suma_c.o: $(SRC)suma_c.c
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando suma_c.c ..."
	$(CHAIN)-gcc -g -O0 $(CFLAGS) -c $(SRC)suma_c.c -o $(OBJ)suma_c.o

clean:
	rm -rf $(OBJ)*.o $(OBJ)*.elf $(BIN)*.bin $(LST)*.lst $(LST)*.txt $(LST)*.map

run:
	qemu-system-arm -M realview-pb-a8 -m 32M -no-reboot -nographic -monitor telnet:127.0.0.1:1234,server,nowait -S -gdb tcp::2159 -kernel ./$(BIN)/mi_suma.bin

debug:
	ddd --debugger gdb-multiarch $(OBJ)mi_suma.elf

