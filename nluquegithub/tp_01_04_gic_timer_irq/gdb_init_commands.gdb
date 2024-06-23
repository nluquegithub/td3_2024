### gdb_init_commands.gdb
##		archivo con los comandos iniciales al ejecutar (gdb) con DDD o similar, invocado desde el makefile, en la carpeta raiz del proyecto
##		a diferencia del archivo '.gdb_init' que depende de la carpeta home de usuario, estos comandos permanecen en el proyecto
#
target remote localhost:2159
#set logging file gdb_output.txt
#set logging enabled on
set history save on
set $pc=0x70010000
#display `x /40dw 0x700300c8`
b hardware_init
c
b Inicializado
# c
b IRQ_Handler
