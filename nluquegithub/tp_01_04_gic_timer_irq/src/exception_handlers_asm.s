// exception_handlers_asm.s 2024-06-21

/* 
- En este archivo esta el codigo de atencion basico para las excepciones (y tambien irq).
- Son los pasos escenciales para recalcular el retorno y guardar los registros por i hubiera re-entrancia.
- El codigo especifico que debe atender cada handler puede estar en otro archivo en C, o en asm.

Referencias:
https://developer.arm.com/documentation/dui0203/j/handling-processor-exceptions/armv6-and-earlier--armv7-a-and-armv7-r-profiles/types-of-exception


Direccion de retorno. Valores del Link Register
Excepcion					Direccion	Uso
Reset						-			Es un Reset. No esta definido
Data abort					lr - 8		Apunta a la instruccion que causo el Abort
Fast interrupt request		lr - 4		Retorna a la instruccion siguiente a la que recibio FIQ
Interrupt request			lr - 4		Retorna a la instruccion siguiente a la que recibio IRQ
Prefetch abort				lr - 4		Retorna a la instruccion que recibio Prefetch Abort
Software interrupt			lr			Regresa a la instruccion siguiente a SWI
Undefined instruction		lr			Regresa a la instruccion siguiente a la no definida

Alejandro Furfaro ARMv7 - Gestion de Interrupciones 20 de julio de 2020 pag 27/64
*/

/* Mascaras para modo Thumb o ARM bit (5) del CPSR/SPSR. */
.equ T_BIT,	0x20

/* Explicitamos simbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global SVC_Handler

.global Undefined_Handler
.global Prefetch_Handler
.global Data_Abort_Handler
.global IRQ_Handler


.section .exception_handlers, "ax"

/*-----------------------------------------------------------------------------------------------------------------------------  .exception_handlers SVC_Handler */
/*
- SVC se genera cuando se ejecuta la Instruccion SWI o SVC (SWI sigue implementada pero es considerada obsoleta por ARM desde 2007).
- Esta instruccion se ejecuta en codigo Modo User. Al ingresar al handler, el procesador establece en el registro CPSR el Modo Supervisor.
- Alejandro Furfaro ARMv7 - Gestion de Interrupciones 20 de julio de 2020 pag 25/64
*/

SVC_Handler:
	/* Guardar el estado del contexto si es necesario */  /*------------------------------ PREAMBULO (guardar contexto)*/
		/* En caso de un nuevo SVC call, se perderian si no lo guardamos en la pila */
	STMFD   sp!, {r0-r3, r12, lr}	// Store registers
					// Push onto a Full Descending Stack

		/* Obtener puntero a los parametros que sean necesarios, guardados por el usuario en el stack */
	MOV	 r1, sp				 // Set pointer to parameters
	MRS	 r0, spsr			   // Get spsr
	STMFD   sp!, {r0, r3}		  // Store spsr onto stack and another register to maintain 8-byte-aligned stack.
								   // Only required for nested SVCs.

	/* Mascara para determinar en que modo estaba antes de SVC */
	TST	 r0, #T_BIT			 // Occurred in Thumb state?

	/* Obtener el numero de SVC que esta embebido en la instruccion.*/
		/* Por eso buscamos la direccion en que quedo el anterior pc (o sea el lr) y...*/
	LDRNEH  r0, [lr,#-2]		   // Yes: Load halfword and...	/*  -2 posiciones es la instruccion, en modo Thumb */
	BICNE   r0, r0, #0xFF00		// ...extract comment field	/*		filtramos el SVC_number */
	LDREQ   r0, [lr,#-4]		   // Load word and...		/*  -4 posiciones es la instruccion, en modo ARM */
	BICEQ   r0, r0, #0xFF000000	// ...extract comment field	/*		filtramos el SVC_number */

	// r0 now contains SVC_number
	// r1 now contains pointer to stacked registers	/*------------------------------------ PREAMBULO (contexto guardado)*/

	// Implemento una JUMP_TABLE para atender al service_call segun el SVC_number.
			/* 	Es similar a lograr un SWITCH_CASE pero cada CASE definido tiene que ser un valor consecutivo del anterior, sin dejar huecos de casos sin definir.
				Todos los casos NO definidos se atenderan por default_case. Es mas rapido la ejecucion que un switch case en #C que tenga casos huecos, 
				hace menos comprobaciones y salta directamente a la etiqueta que debe atender.*/
	LSL r0, r0, #2		@ Multiplica el valor por 4 para obtener el desplazamiento correcto
	LDR	r2, rango_jump_table	@ rango de tabla permitida para SVC_number saltos de jump_table
	CMP r0, r2			@ Compara el offset de salto r0 con el rango permitido en la jump_table
	BGE default_case	@ Salta a default_case si la dir de salto es >= a default, o sea que el SVC_number no tenia un caso definido
	LDR	r2, =jump_table	@ Cargamos en r2 la dir base para el salto (coincide con case_0 )
	LDR r0, [r2, r0]	@ Carga la direccion de salto correspondiente de la jump table
	BX r0		   	@ Salta a la direccion de salto cargada si tenemos identificado un case correcto

	case_0:					@ Codigo para case 0
		b exit

	case_1:					@ Codigo para case 1
		LDR r4, str1	// carga r4 con la var str1
		b exit

	case_2:					@ Codigo para case 2
		BL svc_handler_c
		b exit

	case_3:					@ Codigo para case 3
		b exit

	default_case:			@ Codigo para casos no definidos
		LDR r4, str2	// carga r4 con la var str2
		b exit

	exit:					@ Codigo de salida en comun a todos los case, de ser necesario

													/*------------------------------------ EPILOGO (devolver contexto)*/
	LDMFD   sp!, {r0, r3}		  // Get spsr from stack
	MSR	 spsr, r0			   // Restore spsr
	LDMFD   sp!, {r0-r3, r12, pc}^ // Restore registers and return
									// Pop from a Full Descending Stack
	/*The ^ qualifier specifies that the CPSR is restored from the SPSR. It must be used only from a privileged mode.*/
													/*------------------------------------ EPILOGO (contexto devuelto)*/

	jump_table:
		case_0_addr:		.word case_0		 @ Direccion de la etiqueta case_0
		case_1_addr:		.word case_1		 @ Direccion de la etiqueta case_1
		case_2_addr:		.word case_2		 @ Direccion de la etiqueta case_2
		case_3_addr:		.word case_3		 @ Direccion de la etiqueta case_3
		default_case_addr:	.word default_case   @ Direccion de salto por defecto

	str1: 	.word 	0xAACCAA01
	str2: 	.word 	0xAACCAA05

	rango_jump_table:		.word (default_case_addr - case_0_addr) @ para evaluar si el salto esta permitido





/* Implementar excepciones. Cada excepcion se debe generar por una funcion especifica.
[x] INV Invalid instructions and trap exceptions 	-> Prefetch_Handler
[x] MEM Memory accesses								-> Data_Abort_Handler		// #BUG no logro disparar la excepcion sin MMU, pendiente de probarlo
[ ] probar IRQ por el timer
 */

/*-----------------------------------------------------------------------------------------------------------------------------  .exception_handlers Undefined_Handler */
/*
- 'Undefined Instruction' se genera en la fase de ejecucion del pipe-line cuando la instruccion no corresponde al set de instrucciones ARM Thumb o Thumb2 y no hay 
coprocesadores disponibles, y si los hay tampoco corresponde a sus instrucciones.
- 'Undefined Instruction' y SWI nunca pueden por razones obvias ocurrir al mismo tiempo. Por eso tienen la misma prioridad.
Alejandro Furfaro ARMv7 - Gestion de Interrupciones 20 de julio de 2020 pag 26/64
 */

Undefined_Handler:
	CPSID i 					@ deshabilita las interrupciones IRQ
								@ no recalcula LR, Regresa a la instruccion siguiente a la no definida
	STMFD	sp!, {r0-r12,lr}	@ PUSH a la pila los registros
	MOV		r7,sp				@ copia el stack pointer actual a r7
	MRS		r8, spsr			@ copia el actual SPSR en r8
	STMFD	sp!, {r7,r8}		@ PUSH a la pila el SP y SPSR para resguardo de contexto

	MOV		r0,sp   			@ colocamos en r0 el stack pointer, para cumplir con la ABI, si necesitaramos algo del contexto en la funcion en C#
	BL	und_inst_handler_c		
	
	LDMFD	sp!, {r7,r8}		@ POP de la pila para restaurar contexto previo a la atencion de IRQ
	MSR		spsr, r8
	MOV		sp, r7
	CPSIE i						@ habilita las interrupciones IRQ
	LDMFD	sp!, {r0-r12, pc}^	@ POP de los demas registros y salida de este IRQ_Handler

	/*The ^ qualifier specifies that the CPSR is restored from the SPSR. It must be used only from a privileged mode.*/




/*-----------------------------------------------------------------------------------------------------------------------------  .exception_handlers Prefetch_Handler */
/*
- Se genera Prefetch Abort cuando se intenta un Fetch de una instruccion en una direccion invalida de memoria.
- Esta excepcion se genera cuando la instruccion responsable del Fallo ingresa a la etapa de ejecucion del pipeline,
  siempre que no se hayan activado en el transcurso FIQ, y/o IRQ (recordar el caracter asincronico y no deterministico de las interrupciones de hardware). 
- Si esto hubiese ocurrido se atendera la interrupcion o ambas interrupciones (segun corresponda) en el orden de priori-dad establecido.
- Cuando se vectoriza Prefetch Abort, se deshabilita IRQ. 
- El handler de Prefetch Abort, se suspende si ingresa FIQ, o IRQ, si se habilito en algun momento durante la ejecucion del handler.
Alejandro FurfaroARMv7 - Gestion de Interrupciones20 de julio de 2020 pag 24/64
*/

Prefetch_Handler:
	CPSID i 					@ deshabilita las interrupciones IRQ
/*generalmente se haria la resta, con el handler corregimos el problema que genero la excepcion, 
y luego volvemos al mismo punto antes de exception para poder ejecutar lo que no se podia. */
	@ SUB	lr,lr, #4			@ resta 4 que en LR Retorne a la instruccion que recibio Prefetch Abort
/* #HACK pero en la consigna, solo debo escribir en r10, y luego continuar con la ejecucion normal, asi que debo dejarlo como esta en vez de restar <----	solo ej4, luego descomentar*/

	STMFD	sp!, {r0-r12,lr}	@ PUSH a la pila los registros
	MOV		r7,sp				@ copia el stack pointer actual a r7
	MRS		r8, spsr			@ copia el actual SPSR en r8
	STMFD	sp!, {r7,r8}		@ PUSH a la pila el SP y SPSR para resguardo de contexto
	
	MOV		r0,sp   			@ colocamos en r0 el stack pointer, para cumplir con la ABI, si necesitaramos algo del contexto en la funcion en C#
	BL	prefetch_abt_handler_c
	
	LDMFD	sp!, {r7,r8}		@ POP de la pila para restaurar contexto previo a la atencion de IRQ
	MSR		spsr, r8
	MOV		sp, r7
	CPSIE i						@ habilita las interrupciones IRQ
	LDMFD	sp!, {r0-r12, pc}^	@ POP de los demas registros y salida de este IRQ_Handler

	/*The ^ qualifier specifies that the CPSR is restored from the SPSR. It must be used only from a privileged mode.*/
	
	


/*-----------------------------------------------------------------------------------------------------------------------------  .exception_handlers Abort_Handler */
/*
- Data Abort es generada por la MMU. Escenarios mas comunes: 
	- Cuando se intenta acceder a una direccion de memoria invalida (sino hay memoria fisica asignada a esa direccion de memoria).
	- Cuando se intenta acceder a una direccion de memoria para la cual no se dispone de los permisos necesarios.
- Sin embargo no hay problemas en suspender la atencion de un Data Abort para vectorizar el handler de una FIQ. 
	- Eventualmente una vez que termina el handler de FIQ se retorna al de Data Abort y se continua con su resolucion.
	- Decimos que Data Abort soporta anidamiento con FIQ.
Alejandro Furfaro ARMv7 - Gestion de Interrupciones 20 de julio de 2020 pag 22/64
 */

Data_Abort_Handler:	
	CPSID i 					@ deshabilita las interrupciones IRQ
	SUB	lr,lr, #8				@ resta 8 que en LR Apunte a la instruccion que causo el Abort

	STMFD	sp!, {r0-r12,lr}	@ PUSH a la pila los registros
	MOV		r7,sp				@ copia el stack pointer actual a r7
	MRS		r8, spsr			@ copia el actual SPSR en r8
	STMFD	sp!, {r7,r8}		@ PUSH a la pila el SP y SPSR para resguardo de contexto

	MOV		r0,sp   			@ colocamos en r0 el stack pointer, para cumplir con la ABI, si necesitaramos algo del contexto en la funcion en C#
	BL	mem_abt_handler_c		
	
	LDMFD	sp!, {r7,r8}		@ POP de la pila para restaurar contexto previo a la atencion de IRQ
	MSR		spsr, r8
	MOV		sp, r7
	CPSIE i						@ habilita las interrupciones IRQ
	LDMFD	sp!, {r0-r12, pc}^	@ POP de los demas registros y salida de este IRQ_Handler

	/*The ^ qualifier specifies that the CPSR is restored from the SPSR. It must be used only from a privileged mode.*/




/*-----------------------------------------------------------------------------------------------------------------------------  .exception_handlers IRQ_Handler */
IRQ_Handler:
	CPSID i 					@ deshabilita las interrupciones IRQ

	SUB	lr,lr, #4				@ resta 4 que en LR Retorne a la instruccion siguiente a la que recibio IRQ

	STMFD	sp!, {r0-r12,lr}	@ PUSH a la pila los registros
	MOV		r7,sp				@ copia el stack pointer actual a r7
	MRS		r8, spsr			@ copia el actual SPSR en r8
	STMFD	sp!, {r7,r8}		@ PUSH a la pila el SP y SPSR para resguardo de contexto
	
	//--- revisar aca si falta algo para poder cubrir la re-entrancia de interrupciones, mientras tanto lo dejo deshabilitado hasta el final ---///

	MOV		r0,sp   			@ colocamos en r0 el stack pointer, para cumplir con la ABI, si necesitaramos algo del contexto en la funcion en C#
	BL		irq_handler_c
	
	LDMFD	sp!, {r7,r8}		@ POP de la pila para restaurar contexto previo a la atencion de IRQ
	MSR		spsr, r8
	MOV		sp, r7
	CPSIE i						@ habilita las interrupciones IRQ
	LDMFD	sp!, {r0-r12, pc}^	@ POP de los demas registros y salida de este IRQ_Handler

	/*The ^ qualifier specifies that the CPSR is restored from the SPSR. It must be used only from a privileged mode.*/

/*--------------------------------------------------------------------------------------------------------- hasta aca todos los handlers  que no sean _reset */