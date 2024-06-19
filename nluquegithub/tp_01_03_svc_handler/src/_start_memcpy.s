// memcpy_bytes.s

/* Symbols de direcciones definidas externamente en otro archivo o en linker_script */
.extern	__VECTOR_TABLE_BASE
.extern	__PUBLIC_ROM_INIT
.extern	__PUBLIC_STACK_INIT
.extern	__PUBLIC_RAM_INIT
@ .extern	__KERNEL_START_VMA

.extern	__VECTOR_TABLE_START_VMA
.extern	__VECTOR_TABLE_START_LMA
.extern	__VECTOR_TABLE_SIZE

.extern	__RESET_START_VMA
.extern	__RESET_START_LMA
.extern	__RESET_SIZE

.extern	__KERNEL_START_VMA
.extern	__KERNEL_START_LMA
.extern	__KERNEL_SIZE

.extern	__HANDLERS_START_VMA
.extern	__HANDLERS_END_VMA

.extern	__SYS_STACK_START
.extern	__SYS_STACK_SIZE
.extern	__SYS_STACK_END

.extern	__IRQ_STACK_START
.extern	__IRQ_STACK_SIZE
.extern	__IRQ_STACK_END

.extern	__FIQ_STACK_START
.extern	__FIQ_STACK_SIZE
.extern	__FIQ_STACK_END

.extern	__SVC_STACK_START
.extern	__SVC_STACK_SIZE
.extern	__SVC_STACK_END

.extern	__ABT_STACK_START
.extern	__ABT_STACK_SIZE
.extern	__ABT_STACK_END

.extern	__UND_STACK_START
.extern	__UND_STACK_SIZE
.extern	__UND_STACK_END

.extern	__GAP_SIZE

/* Explicitamos simbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global _start
.global memcpy

/*---------------------------------------------------------------------------------------------------------  .memcpy_asm */

.section .memcpy_asm, "ax"            

_start:
        @ entry point, es la forma comun de indicar por donde arranca y/o resetea el microprocesador

/*---  aca estamos copiando el vector_table a 0x00.. ya que vimos que qemu no lo estaba haciendo */
	LDR r0, =__VECTOR_TABLE_START_LMA	@ _dir_inicio_data_copiar
	LDR r1, =__VECTOR_TABLE_START_VMA	@ _dir_inicio_data_pegar
	LDR	r2, =__VECTOR_TABLE_SIZE		@ _largo_data_copiar ; inicio + largo = _final_data_copiar
	BL	memcpy

/*---  aca estamos copiando el programa entero a la zona donde trabajara desde SRAM */
	LDR r0, =__RESET_START_LMA		@ _dir_inicio_data_copiar
	LDR r1, =__RESET_START_VMA		@ _dir_inicio_data_pegar
	LDR	r2, =__RESET_SIZE		@ _largo_data_copiar ; inicio + largo = _final_data_copiar
	BL	memcpy
        
/*---  aca estamos copiando el programa entero a la zona donde trabajara desde DRAM */
	LDR r0, =__KERNEL_START_LMA		@ _dir_inicio_data_copiar
	LDR r1, =__KERNEL_START_VMA		@ _dir_inicio_data_pegar
	LDR	r2, =__KERNEL_SIZE		@ _largo_data_copiar ; inicio + largo = _final_data_copiar
	BL	memcpy

    @ @ BL clear_bss          // #TODO agregar una rutina de clear_bss para asegurar de poner esa zona de memoria en ceros


	// SETEAMOS EL LR Y PC para empezar a correr desde la zona de memoria RAM, antes de inicializar los stacks
	LDR lr,  =__RESET_START_VMA
	LDR pc,  =__RESET_START_VMA


memcpy:
							    @ tenemos que tener previamente los punteros _inicio_data_copiar en r0, y _inicio_data_pegar en r1
							    @ asi el bloque de codigo en r0 = _inicio_data_copiar, se copiara en r1 = _inicio_data_pegar en adelante
	ADD r2, r2, r0 			    @  r2 = _largo_data_copiar + _inicio_data_copiar
	fast_copy:
		LDMIA	r0!, {r3 - r10}	@ load memory increment after. carga lo que hay desde r0 inclusive a r3 , luego incrementar r0 y cargarlo en r4,....
								@ hasta cargar en r10, = desde la pos r0 cargar 8*4bytes, o sea lo que esta en r0 y los siguientes 7 bytes
		STMIA	r1!, {r3 - r10}	@ store memory increment after, al final de todo en r0 quedo el ultimo valor de direccion donde termino la copia
		CMP	r0, r2 				@ compara la ultima direccion de copia que quedo en r0, contra el contenido de r2 (r2 = _final_data_copiar por el primer add)
		BLE	fast_copy
	MOV	pc, lr                  @ volvemos al branch with link BL que lo llamo
