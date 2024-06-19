##################################		MAKEFILE		##################################
# AUTOR	: NLUQUE
# FECHA	: 2023.07.18
# USOS	: UTN FRBA TD3 R5053 2023

## Change log:
# 2024-06-01 19:43:59 adapte para usar en TD3 2024 con DDD debugger (interfaz grafica para gdb)

##################################		MACROS		##################################
## Sirven para expandir reglas de forma iterativa cuando se combinan con 'foreach'
## Se pasan parametros de la macro sustituyendo en orden.
## Cambiar de la regla original los $() en orden
## Se invoca como una macro en #C
#$(call MACRONAME,1,2,3)


## Compilado del codigo en C
define COMPILE
$(1) : $(2) $(3)
	$(CC) $(2) -o $(1)
endef
#$(1) : Object file to generate
#$(2) : Source file
#$(3) : Additional dependencies
#$(eval $(call COMPILE,obj.o,src.c,inc.h))

#$(OBJ)$(CCODE).o: $(SRC)$(CCODE).c
#	$(CHAIN)-gcc -g -O3 $(CFLAGS) -c $(SRC)$(CCODE).c -o $(OBJ)$(CCODE).o


## Ensamblado del codigo en assembler
define ASSEMBLY
$(1) : $(2) $(3)
	$(AS) $(2) -o $(1) -als > $(4)
endef
#$(1) : Object file to generate
#$(2) : Source file
#$(3) : Additional dependencies
#$(4) : List files to generate
#$(eval $(call ASSEMBLY,obj.o,src.s,inc.h,lst.lst))

#$(OBJ)$(ACODE).o: $(SRC)$(ACODE).s
#	$(CHAIN)-as -g $(SRC)$(ACODE).s -o $(OBJ)$(ACODE).o -als > $(LST)$(ACODE).lst


## Cambiar la ruta y extensión de SOURCE.c a OBJECT.o
define C2O
$(patsubst %.c,%.o,$(patsubst $(SRC)%,$(OBJ)%,$(1)))
endef
#$(1) : Source file
#$(call C2O,$(F))


## Cambiar la ruta y extensión de SOURCE.s a OBJECT.o
define ASM2O
$(patsubst %.s,%.o,$(patsubst $(SRC)%,$(OBJ)%,$(1)))
endef
#$(1) : Source file
#$(call ASM2O,$(F))

## Cambiar la ruta y extensión de SOURCE.s a LIST.lst
define ASM2LST
$(patsubst %.s,%.lst,$(patsubst $(SRC)%,$(LST)%,$(1)))
endef
#$(1) : Source file
#$(call ASM2LST,$(F))

##################################		CONFIG		##################################

## Proyecto
APP 	:= app
CHAIN	:= arm-linux-gnueabihf
LSCRIPT	:= linker_script.ld
# LSCRIPT	:= td3_memmap.ld
BOARD	:= realview-pb-a8

## otras placas posibles a emular descomentar la que se quiera usar
#BOARD	:= mcimx6ul-evk
#BOARD	:= vexpress-a15

## para ver el listado completo usar el comando:
## qemu-system-arm -M help | grep Cortex-A
## se puede usar cualquiera lo que cambia es el vector de reset en la emualcion
## tener en cuenta esto para modificar el linker script acorde


### Emulador QEMU y sus parametros
## si uso qemu con gdb_dashboard en la terminal, ojo que requiere un .gdbinit distinto
# PORT	:= 12345
# TCPport	:= 1234
# VMFLGS	:= -M $(BOARD) -no-reboot -nographic -monitor telnet:127.0.0.1:$(PORT),server,nowait
## si uso qemu con DDD (interfaz grafica para gdb)
PORT	:= 1234
TCPport	:= 2159
VMFLGS	:= -M $(BOARD) -no-reboot -nographic -monitor telnet:127.0.0.1:$(PORT),server,nowait -gdb tcp::$(TCPport) -S
VME		:= qemu-system-arm

## Herramientas del cross-compiler
CC	:= $(CHAIN)-gcc -g -O3 $(CFLAGS) -c
LD	:= $(CHAIN)-ld -T $(LSCRIPT) 
AS	:= $(CHAIN)-as -g

CFLAGS	:= -std=gnu99 -Wall -mthumb -mcpu=cortex-a8 -fno-stack-protector -fno-asynchronous-unwind-tables -fno-PIC
#-fno-stack-protector -fno-asynchronous-unwind-tables -fno-PIC ## ChristiaN 23:01 14/08/2023 en clase
MKDIR	:= mkdir -p
BINF	= $(BIN)/$(APP).bin

## Etiquetado de rutas
OBJ	:= obj
BIN	:= bin
INC	:= inc
SRC	:= src
LST	:= lst

### Enlistado de rutas y archivos.
## NOTE! requiere que los archivos fuente existan en la sub-carpeta /src. Los archivos para linker_script.ld, gdb_init_commands.txt gdb_output.txt, esten la carpeta raiz del proyecto
ALL_Cs			:= $(shell find $(SRC)/ -type f -iname *.c)
ALL_ASMs		:= $(shell find $(SRC)/ -type f -iname *.s)
ALL_Cs_OBJs		:= $(foreach F,$(ALL_Cs),$(call C2O,$(F)))
ALL_ASMs_OBJs	:= $(foreach F,$(ALL_ASMs),$(call ASM2O,$(F)))
SUBDIRs			:= $(shell find $(SRC) -type d)
OBJSUBDIRs		:= $(patsubst $(SRC)%,$(OBJ)%,$(SUBDIRs))
LSTSUBDIRs		:= $(patsubst $(SRC)%,$(LST)%,$(SUBDIRs))


##################################		RULES		##################################
#### Reglas y dependencias
## Algunas que no generan archivos del nombre de la Reglas
.PHONY : all clean connect qemu gdb info MKSUBDIRs ddd ddd_clean

## Construccion del proyecto

all: $(MKSUBDIRs) $(BINF) $(BIN)/$(APP).elf
	@echo " ... MAKEFILE FINISH ... "
	
$(BINF): $(BIN)/$(APP).elf
	$(CHAIN)-objcopy -O binary $< $@

$(BIN)/$(APP).elf : MKSUBDIRs $(ALL_ASMs_OBJs) $(ALL_Cs_OBJs)
	$(LD) $(ALL_ASMs_OBJs) $(ALL_Cs_OBJs) -o $(BIN)/$(APP).elf -Map $(LST)/$(APP).map
	readelf -a $(BIN)/$(APP).elf > $(LST)/$(APP)_elf.txt
	$(CHAIN)-objdump -D $(BIN)/$(APP).elf > $(LST)/$(APP).lst


#### Generación de reglas para los objetos desde C y ASM
## solo se generan con las dependencias por cada objeto
## en la macro defini dependencia de inc.h pero al no pasarle el parametro compila sin fijarse
$(foreach F,$(ALL_Cs),$(eval $(call COMPILE,$(call C2O,$(F)),$(F))))
$(foreach F,$(ALL_ASMs),$(eval $(call ASSEMBLY,$(call ASM2O,$(F)),$(F),,$(call ASM2LST,$(F)))))

## Regla para crear directorios
MKSUBDIRs :
	@echo " ... MAKEFILE START ... "
	$(MKDIR) $(OBJSUBDIRs)
	$(MKDIR) $(LSTSUBDIRs)
	$(MKDIR) $(BIN)


info :
	$(info $(SUBDIRs))
	$(info $(OBJSUBDIRs))
	$(info $(LSTSUBDIRs))

clean:
	rm -rf $(OBJ)/*.o
	rm -rf $(BIN)/*.elf
	rm -rf $(BIN)/*.bin
	rm -rf $(LST)/*.lst
	rm -rf $(LST)/*.txt
	rm -rf $(LST)/*.map
	rm -rf $(OBJSUBDIRs)
	rm -rf $(LSTSUBDIRs)
	rm -rf $(BIN)
	
connect:
	telnet localhost $(PORT)
	
qemu:
	$(VME) $(VMFLGS) -kernel $(BINF)

## Regla para debug con gdb_dashboard (terminal), ojo que requiere otro .gdbinit diferente
gdb:
	gdb-multiarch $(BIN)/$(APP).elf

## Regla para debug con DDD (interfaz grafica) y gdb
ddd:
	ddd --debugger "gdb-multiarch -x gdb_init_commands.txt" $(BIN)/$(APP).elf

ddd_clean:
	rm ~/.ddd/init
	ddd --debugger "gdb-multiarch -x gdb_init_commands.txt" $(BIN)/$(APP).elf