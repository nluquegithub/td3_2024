// handler_svc.s 2024-06-04
/*3. INTERRUPCIONES BÁSICAS - SWI 
 
Se pide continuar el ejercicio anterior incorporando un sistema básico de atención de 
interrupciones/excepciones. 
 
Para tal fin, se deberá definir un “handler” genérico para atender la interrupción SVC. 
 
Para  corroborar  su funcionamiento, debemos  poder  llamar a  la  instrucción  SWI  y  validar  que 
atendemos el pedido correctamente.
*/

/* Máscaras para modo Thumb o ARM bit (5) del CPSR/SPSR. */
.equ T_BIT,    0x20

/* Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global SVC_Handler

.global Undefined_Handler
.global Prefetch_Handler
.global Abort_Handler
.global IRQ_Handler

/*---------------------------------------------------------------------------------------------------------  .exception_handlers SVC_Handler */

.section .exception_handlers, "ax"

SVC_Handler:


	/* Guardar el estado del contexto si es necesario */  /*------------------------------ PREAMBULO (guardar contexto)*/
		/* En caso de un nuevo SVC call, se perderían si no lo guardamos en la pila */
    STMFD   sp!, {r0-r3, r12, lr}	// Store registers
					// Push onto a Full Descending Stack

		/* Obtener puntero a los parámetros que sean necesarios, guardados por el usuario en el stack */
    MOV     r1, sp                 // Set pointer to parameters
    MRS     r0, spsr               // Get spsr
    STMFD   sp!, {r0, r3}          // Store spsr onto stack and another register to maintain 8-byte-aligned stack.
                                   // Only required for nested SVCs.

	/* Máscara para determinar en qué modo estaba antes de SVC */
	TST     r0, #T_BIT             // Occurred in Thumb state?

	/* Obtener el número de SVC que está embebido en la instruccion.*/
		/* Por eso buscamos la dirección en que quedó el anterior pc (o sea el lr) y...*/
    LDRNEH  r0, [lr,#-2]           // Yes: Load halfword and...	/*  -2 posiciones es la instrucción, en modo Thumb */
    BICNE   r0, r0, #0xFF00        // ...extract comment field	/*		filtramos el SVC_number */
    LDREQ   r0, [lr,#-4]           // Load word and...		/*  -4 posiciones es la instrucción, en modo ARM */
    BICEQ   r0, r0, #0xFF000000    // ...extract comment field	/*		filtramos el SVC_number */

    // r0 now contains SVC_number
    // r1 now contains pointer to stacked registers	/*------------------------------------ PREAMBULO (contexto guardado)*/

	// Implemento una JUMP_TABLE para atender al service_call según el SVC_number.
			/* 	Es similar a lograr un SWITCH_CASE pero cada CASE definido tiene que ser un valor consecutivo del anterior, sin dejar huecos de casos sin definir.
				Todos los casos NO definidos se atenderan por default_case. Es más rápido la ejecución que un switch case en #C que tenga casos huecos, 
				hace menos comprobaciones y salta directamente a la etiqueta que debe atender.*/
    LSL r0, r0, #2		@ Multiplica el valor por 4 para obtener el desplazamiento correcto
	LDR	r2, rango_jump_table	@ rango de tabla permitida para SVC_number saltos de jump_table
    CMP r0, r2			@ Compara el offset de salto r0 con el rango permitido en la jump_table
    BGE default_case	@ Salta a default_case si la dir de salto es >= a default, o sea que el SVC_number no tenía un caso definido
    LDR	r2, =jump_table	@ Cargamos en r2 la dir base para el salto (coincide con case_0 )
    LDR r0, [r2, r0]	@ Carga la dirección de salto correspondiente de la jump table
    BX r0           	@ Salta a la dirección de salto cargada si tenemos identificado un case correcto

	case_0:					@ Código para case 0
	    b exit

	case_1:					@ Código para case 1
	    LDR r4, str1	// carga r4 con la var str1
	    b exit

	case_2:					@ Código para case 2
	    b exit

	case_3:					@ Código para case 3
	    b exit

	default_case:			@ Código para casos no definidos
	    LDR r4, str2	// carga r4 con la var str2
	    b exit

	exit:					@ Código de salida en comun a todos los case, de ser necesario

													/*------------------------------------ EPILOGO (devolver contexto)*/
    LDMFD   sp!, {r0, r3}          // Get spsr from stack
    MSR     spsr, r0               // Restore spsr
    LDMFD   sp!, {r0-r3, r12, pc}^ // Restore registers and return
									// Pop from a Full Descending Stack
	/*The ^ qualifier specifies that the CPSR is restored from the SPSR. It must be used only from a privileged mode.*/
													/*------------------------------------ EPILOGO (contexto devuelto)*/

	jump_table:
		case_0_addr:		.word case_0	     @ Dirección de la etiqueta case_0
		case_1_addr:		.word case_1    	 @ Dirección de la etiqueta case_1
		case_2_addr:		.word case_2    	 @ Dirección de la etiqueta case_2
		case_3_addr:		.word case_3    	 @ Dirección de la etiqueta case_3
		default_case_addr:	.word default_case   @ Dirección de salto por defecto

	str1: 	.word 	0xAACCAA01
	str2: 	.word 	0xAACCAA05

	rango_jump_table:		.word (default_case_addr - case_0_addr) @ para evaluar si el salto está permitido


/* #TODO comentar las etiquetas de los handlers quese vayan implementando */
Undefined_Handler:	B .
Prefetch_Handler:	B .
Abort_Handler:		B .
IRQ_Handler:		B .
