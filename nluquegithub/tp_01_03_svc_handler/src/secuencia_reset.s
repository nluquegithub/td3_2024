// secuencia_reset.s 

/* Defino etiquetas para luego hacer los cambios de modo */
.equ USR_MODE, 0x10
.equ FIQ_MODE, 0x11
.equ IRQ_MODE, 0x12
.equ SVC_MODE, 0x13
.equ ABT_MODE, 0x17
.equ UND_MODE, 0x1B
.equ SYS_MODE, 0x1F
/* Máscaras para des-habilitar interrupciones */
.equ I_BIT,    0x80
.equ F_BIT,    0x40

/* Symbols de direcciones definidas externamente en otro archivo o en linker_script */
.extern	__VECTOR_TABLE_BASE
.extern	__PUBLIC_ROM_INIT
.extern	__STACK_BASE
.extern	__KERNEL_VMA

.extern	__VECTOR_TABLE_START_LMA
.extern	__VECTOR_TABLE_SIZE
.extern	__KERNEL_LMA
.extern	__KERNEL_SIZE

.extern	__HANDLERS_START
.extern	__HANDLERS_END

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

/* Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global Reset_Handler

.code 32			//especificamos que la siguiente seccion es código de 32-bits


/*--------------------------------------------------------------------------------------------------------- .secuencia_reset */

.section .secuencia_reset, "ax"

_start:
        @ entry point, es la forma común de indicar por dónde arranca y/o resetea el microprocesador

        
memcpy:
							@ tenemos que tener previamente los punteros _inicio_data_copiar en r0, y _inicio_data_pegar en r1
							@ así el bloque de código en r0 = _inicio_data_copiar, se copiará en r1 = _inicio_data_pegar en adelante
	ADD r2, r2, r0 			@  r2 = _largo_data_copiar + _inicio_data_copiar
	fast_copy:
		LDMIA	r0!, {r3 - r10}	@ load memory increment after. carga lo que hay desde r0 inclusive a r3 , luego incrementar r0 y cargarlo en r4,....
								@ hasta cargar en r10, = desde la pos r0 cargar 8*4bytes, o sea lo que esta en r0 y los siguientes 7 bytes
		STMIA	r1!, {r3 - r10}	@ store memory increment after, al final de todo en r0 quedó el último valor de dirección donde terminó la copia
		CMP	r0, r2 				@ compara la última dirección de copia que quedó en r0, contra el contenido de r2 (r2 = _final_data_copiar por el primer add)
		BLE	fast_copy
	MOV	pc, lr


Reset_Handler:
	/* Inicializo modo SVC supervisor */
	MRS	r0, cpsr			@ Move to general purpose Register a System register
	BIC	r0, r0, #0x1F 		@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR	r0, r0, #0xD3 		@ OR bitwise 0xD3 11010011 CPSR, pone modo supervisor SVC, modo ARM, irq y fiq = 1 des-habilitados
	BIC	r0, r0, #0xF0000000	@ Bitwise bit Clear N, Z, C, V bits
	MSR	cpsr, r0			@ devuelve al CPSR lo modificado en r0
	LDR sp, =__SVC_STACK_END /* aca tengo que inicializar las pilas*/

/*---  aca estamos copiando el vector_table a 0x00.. ya que vimos que qemu no lo estaba haciendo */
	LDR r0, =__VECTOR_TABLE_START_LMA	@ _dir_inicio_data_copiar
	LDR r1, =__VECTOR_TABLE_BASE		@ _dir_inicio_data_pegar
	LDR	r2, =__VECTOR_TABLE_SIZE		@ _largo_data_copiar ; inicio + largo = _final_data_copiar
	BL	memcpy

/*---  aca estamos copiando el programa entero a la zona donde trabajará RAM */
	LDR r0, =__KERNEL_LMA		@ _dir_inicio_data_copiar
	LDR r1, =__KERNEL_VMA		@ _dir_inicio_data_pegar
	LDR	r2, =__KERNEL_SIZE		@ _largo_data_copiar ; inicio + largo = _final_data_copiar
	BL	memcpy

stack_setup:
	// entro en cada uno de los modos, con interrupciones des-habilitadas, y cargo la dirección max de pila en el stack pointer de ese modo

	MRS r0, cpsr					@ Move to general purpose Register a System register
	BIC r0, r0, #0x1F       			@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR r0, r0, #(IRQ_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0					@ devuelve al CPSR lo modificado en r0
    LDR SP, =__IRQ_STACK_END

@	MRS r0, cpsr					@ Move to general purpose Register a System register
	BIC r0, r0, #0x1F       			@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR r0, r0,#(FIQ_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0					@ devuelve al CPSR lo modificado en r0
    LDR SP, =__FIQ_STACK_END

@    MRS r0, cpsr					@ Move to general purpose Register a System register
	BIC r0, r0, #0x1F       			@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR r0, r0, #(SVC_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0					@ devuelve al CPSR lo modificado en r0
    LDR SP, =__SVC_STACK_END

@	MRS r0, cpsr					@ Move to general purpose Register a System register
	BIC r0, r0, #0x1F       			@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR r0, r0, #(ABT_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0					@ devuelve al CPSR lo modificado en r0
    LDR SP, =__ABT_STACK_END

@	MRS r0, cpsr					@ Move to general purpose Register a System register
	BIC r0, r0, #0x1F       			@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR r0, r0, #(UND_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0					@ devuelve al CPSR lo modificado en r0
    LDR SP, =__UND_STACK_END

@	MRS r0, cpsr					@ Move to general purpose Register a System register
	BIC r0, r0, #0x1F       			@ bitwise clear, sobre-escribe r0 con una máscara, limpio los primeros bits
	ORR r0, r0, #(SYS_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0					@ devuelve al CPSR lo modificado en r0
    LDR SP, =__SYS_STACK_END

/* aca termino de inicializar el stack, y puedo saltar a RAM donde pondré mi programa "main" */


	// SETEAMOS EL LR Y PC para empezar a correr desde la zona de memoria RAM, después de los handlers, antes de inicializar los stacks
	LDR lr,  =__HANDLERS_END
	LDR pc,  =__HANDLERS_END

