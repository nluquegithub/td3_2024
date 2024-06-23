// secuencia_reset.s 

/* Defino etiquetas para luego hacer los cambios de modo */
.equ USR_MODE,	0x10
.equ FIQ_MODE,	0x11
.equ IRQ_MODE,	0x12
.equ SVC_MODE,	0x13
.equ ABT_MODE,	0x17
.equ UND_MODE,	0x1B
.equ SYS_MODE,	0x1F
/* Mascaras para des-habilitar interrupciones */
.equ I_BIT,		0x80
.equ F_BIT,		0x40
/* Mascara para los flags de resultado del cpu */
.equ NZCV_bits,	0xF0000000
/* Mascara para cambios de modo ARM */
.equ MODE_bits,	0x1F

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
.global Reset_Handler

@ .code 32			//especificamos que la siguiente seccion es codigo de 32-bits


/*--------------------------------------------------------------------------------------------------------- .reset */

.section .reset, "ax"


Reset_Handler:

	/* Inicializo modo SVC supervisor */
	MRS	r0, cpsr								@ Move to general purpose Register a System register
	BIC	r0, r0, #(MODE_bits) 					@ bitwise clear, sobre-escribe r0 con una mascara, limpio los primeros bits
	ORR	r0, r0, #(SVC_MODE | I_BIT | F_BIT) 	@ OR bitwise 0xD3 11010011 CPSR, pone modo supervisor SVC, modo ARM, irq y fiq = 1 des-habilitados
	BIC	r0, r0, #(NZCV_bits)					@ Bitwise bit Clear N, Z, C, V bits
	MSR	cpsr, r0								@ devuelve al CPSR lo modificado en r0


stack_setup:
	// entro en cada uno de los modos, con interrupciones des-habilitadas, y cargo la direccion max de pila en el stack pointer de ese modo

	MRS r0, cpsr								@ Move to general purpose Register a System register
	BIC r0, r0, #(MODE_bits)	   				@ bitwise clear, sobre-escribe r0 con una mascara, limpio los primeros bits
	ORR r0, r0, #(IRQ_MODE | I_BIT | F_BIT)		@ cambio de modo procesador, irq y fiq = 1 des-habilitados
	MSR cpsr, r0								@ devuelve al CPSR lo modificado en r0, cambio de modo
	LDR SP, =__IRQ_STACK_END

	MRS r0, cpsr
	BIC r0, r0, #(MODE_bits)	   				
	ORR r0, r0,#(FIQ_MODE | I_BIT | F_BIT)		
	MSR cpsr, r0								
	LDR SP, =__FIQ_STACK_END

	MRS r0, cpsr
	BIC r0, r0, #(MODE_bits)	   				
	ORR r0, r0, #(SVC_MODE | I_BIT | F_BIT)		
	MSR cpsr, r0								
	LDR SP, =__SVC_STACK_END

	MRS r0, cpsr
	BIC r0, r0, #(MODE_bits)	   				
	ORR r0, r0, #(ABT_MODE | I_BIT | F_BIT)		
	MSR cpsr, r0								
	LDR SP, =__ABT_STACK_END

	MRS r0, cpsr
	BIC r0, r0, #(MODE_bits)	   				
	ORR r0, r0, #(UND_MODE | I_BIT | F_BIT)		
	MSR cpsr, r0								
	LDR SP, =__UND_STACK_END

	MRS r0, cpsr
	BIC r0, r0, #(MODE_bits)	   				
	ORR r0, r0, #(SYS_MODE | I_BIT | F_BIT)		
	MSR cpsr, r0								
	LDR SP, =__SYS_STACK_END

/* aca termino de inicializar el stack  */

clear_bss:
/*---  borramos a zero la zona de memoria bss, datos no inicializados. clear_bss */
	LDR r0, =0x00000000		@ valor 0 zero para borrar, pero si esta funcion fuera set
	LDR r1, =__bss_start__	@ _dir_inicio_data_borrar
	LDR r2, =__bss_end__	@ _dir_final_data_borrar
	BL clear_bytes

hardware_init:
/* NOTE! todas las inicializaciones necesarias volcarlas aca: 
[x] gic,
[x] timers, 
[ ] mmu paginacion... etc
y puedo saltar a DRAM donde pondre mi programa "main" */

/* Inicializar el GIC */
	LDR	r10, =gic_init				@ inicializo el GIC, funcion en C, me preparo para el salto
	MOV	lr, pc
	BX	r10

	CPSIE i							@ habilita las irq @ esta funcion es de modo thumb, agregar '-mthumb' en CFLAGS del makefile

/* Inicializar el Timer */
	LDR	r10, =timer_init			@ inicializo el timer, funcion en C, me preparo para el salto
	MOV	lr, pc
	BX	r10

	MOV	r10, #0						@ borro el registro r10, queda limpio porque lo tengo que usar de contador con el timer, las veces que ingresó





	// SETEAMOS EL LR Y PC para empezar a correr desde la zona de memoria RAM, despues de los handlers, en .kernel 'Inicializado:'
	LDR lr,  =__HANDLERS_END_VMA
	LDR pc,  =__HANDLERS_END_VMA

