// vector_table.s
/* Defino etiquetas para luego hacer los cambios de modo */
@ .equ USR_MODE, 0x10

/* Symbols de direcciones definidas externamente en otro archivo o en linker_script */
@ .extern	__KERNEL_VMA
.extern Reset_Handler
.extern Undefined_Handler
.extern SVC_Handler
.extern Prefetch_Handler
.extern Abort_Handler
.extern IRQ_Handler

// Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria
.global Vector_Table		/* #FIXME CAMBIAR vector_reset por vector_table en el .ld */
.global FIQ_Handler

@ .code 32			//especificamos que la siguiente seccion es código de 32-bits, no lo he visto en otros ejemplos, quizás sólo es explícito



/*--------------------------------------------------------------------------------------------------------- .vector_table */
.section .vector_table, "ax"			//comienzo de sección, no usamos ".text", que es lo mismo que decir que es sección de código, para dejarlo reservado

Vector_Table:
                LDR pc, Reset_Addr
                LDR pc, Undefined_Addr
                LDR pc, SVC_Addr
                LDR pc, Prefetch_Addr
                LDR pc, Abort_Addr
                NOP                    @ Reserved vector
                LDR pc, IRQ_Addr
	FIQ_Handler:
	               // FIQ handler code - max 4kB in size

	Reset_Addr:      .long Reset_Handler
	Undefined_Addr:  .long Undefined_Handler
	SVC_Addr:        .long SVC_Handler
	Prefetch_Addr:   .long Prefetch_Handler
	Abort_Addr:      .long Abort_Handler
	IRQ_Addr:        .long IRQ_Handler

