// kernel.s 

/* Definiciones */
@ .equ USR_MODE, 0x10


/* Symbols de direcciones definidas externamente en otro archivo o en linker_script */
@ .extern	__VECTOR_TABLE_BASE


/* Explicitamos simbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global Inicializado

.code 32			//especificamos que la siguiente seccion es codigo de 32-bits



/*--------------------------------------------------------------------------------------------------------------------------------------- .kernel Inicializado */

.section .kernel_1, "ax"

/*	Esta seccion de assembler lleva el codigo a ejecutarse, una vez terminada la secuencia reset, pero que deberia haberse ya copiado desde su LMA a su VMA.
Es decir, es esperable que esta seccion se ejecute desde RAM.
 */

Inicializado:

	BL	trigger_prefetch_abt_excep		/* -----  solo necesario en ej4 */
	BL	trigger_und_inst_excep			/* -----  solo necesario en ej4 */
	BL	trigger_mem_abt_excep			// #BUG no logro disparar la excepcion sin MMU, pendiente de probarlo. Se ejecuta la funcion y vuelve.

	
	@ /* Llamadas a SVC, cambia a modo supervisor y ejecuta un servicio en modo privilegiado */
	SVC #1	@ ejemplo de un service_call definido
	SVC #1	@ ejemplo de un service_call con handler en C
	SVC #5	@ ejemplo de un service_call NO definido, realiza una tarea por default_case

idle:
	/* Dejo el CPU en modo de alta impedancia, o modo de bajo consumo esperando despertar con una interrupcion */
	WFI		
	/* NOTE! 'break' en 'IRQ_Handler', 'continue' 1° vez para signal irq, 'continue' 2° vez y llega al handler
	en la sesion de debugging, al ejecutar WFI, se demora el tiempo de timer0 (porque es la unica irq habilitada)
	cuando corre 'continue' 1° vez, y con otro 'continue' 2° vez llega al handler */
	
	/* Retoma luego de atender la interrupcion que lo desperto */
	B idle


