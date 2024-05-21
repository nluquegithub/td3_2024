CHAIN=arm-none-eabi
CFLAGS=-std=gnu99 -Wall -mfpu=neon -mhard-float -mcpu=cortex-a8 -DCPU_A8
# CFLAGS=-std=gnu99 -Wall -mfpu=neon -mcpu=cortex-a8
AFLAGS=-mfpu=neon
OBJ=obj/
BIN=bin/
INC=inc/
SRC=src/
LST=lst/

# all: $(BIN)bios.bin $(BIN)bios.MLO $(OBJ)bios.elf
all: $(BIN)bios.bin $(OBJ)bios.elf

$(BIN)bios.bin: $(OBJ)bios.elf
	$(CHAIN)-objcopy -O binary $< $@

#$(CHAIN)-ld --defsym BOOT_START_ADDR=$(START_ADDR) -T td3bbb_memmap.ld $(OBJ)*.o -o $(OBJ)bios.elf -Map $(LST)bios_ld_map.map 

$(OBJ)bios.elf: $(OBJ)startup.o $(OBJ)reset_vector.o $(OBJ)exception_handlers.o $(OBJ)gic.o
	@echo "Linkeando..."
	mkdir -p obj
	mkdir -p lst
	$(CHAIN)-ld -T td3_memmap.ld $(OBJ)*.o -o $(OBJ)bios.elf -Map $(LST)bios_ld_map.map 
# $(CHAIN)-gcc -T td3_memmap.ld -lgcc --specs=nosys.specs -lm $(OBJ)*.o -o $(OBJ)bios.elf -Wl,-Map=bios_ld_map.map 
	@echo "Linkeo finalizado!!"
	@echo ""
	@echo "Generando archivos de información: mapa de memoria y simbolos"
	readelf -a $(OBJ)bios.elf > $(LST)bios_readelf.txt
	$(CHAIN)-objdump -D $(OBJ)bios.elf > $(LST)bios.lst
#
# Ensamblado de código assembler
#

# Ensamblamos: startup.s
$(OBJ)startup.o: $(SRC)startup.s
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Ensamblando startup.s ..."
	$(CHAIN)-as $(AFLAGS) $(SRC)startup.s -o $(OBJ)startup.o -a > $(LST)startup.lst

# Ensamblamos: reset_vector.s
$(OBJ)reset_vector.o: $(SRC)reset_vector.s
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst	
	@echo "Ensamblando reset_vector.s ..."
	$(CHAIN)-as $(AFLAGS) $(SRC)reset_vector.s -o $(OBJ)reset_vector.o -a > $(LST)reset_vector.lst

# Ensamblamos: reset_vector.s
$(OBJ)exception_handlers.o: $(SRC)exception_handlers.s
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst	
	@echo "Ensamblando exception_handlers.s ..."
	$(CHAIN)-as $(AFLAGS) $(SRC)exception_handlers.s -o $(OBJ)exception_handlers.o -a > $(LST)exception_handlers.lst

$(OBJ)gic.o: $(SRC)gic.c
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando gic.c ..."
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)gic.c -o $(OBJ)gic.o

clean:
	rm -rf $(OBJ)*.o
	rm -rf $(OBJ)*.objstart
	rm -rf $(OBJ)*.elf
	rm -rf $(BIN)*.bin
	rm -rf $(BIN)*.MLO 
	rm -rf $(LST)*.lst 
	rm -rf $(LST)*.txt 
	rm -rf $(LST)*.map 

#$(BIN)bios.MLO: $(BIN)bios.bin
#	bin/mk-gpimage 0x402f0400 $< $@