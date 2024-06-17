// kernel.s 

/* Definiciones */
@ .equ USR_MODE, 0x10


/* Symbols de direcciones definidas externamente en otro archivo o en linker_script */
@ .extern	__VECTOR_TABLE_BASE


/* Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global Inicializado

.code 32			//especificamos que la siguiente seccion es código de 32-bits



/*--------------------------------------------------------------------------------------------------------------------------------------- .kernel Inicializado */

.section .kernel, "ax"

/*	Esta seccion de assembler lleva el código a ejecutarse, una vez terminada la secuencia_reset, pero que debería haberse ya copiado desde su LMA a su VMA.
Es decir, es esperable que esta seccion se ejecute desde RAM.
 */

Inicializado:

	// Llamadas a SVC, cambia a modo supervisor y ejecuta un servicio en modo privilegiado
	SVC #1	@ ejemplo de un service_call definido
	SVC #5	@ ejemplo de un service_call NO definido, realiza una tarea por default_case

	@ // Code before entering the low-power mode
	@     // Insert the WFI instruction
	@ WFI
    @ 	// Code after an interrupt wakes up the processor

	B .		@ loop infinito en el mismo punto


/* NOTE! acá iría mi código main o el programa que sea */

