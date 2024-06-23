// clear_bytes.s

/* Symbols de direcciones definidas externamente en otro archivo o en linker_script */
@ .extern	__bss_start__
@ .extern	__bss_end__


/* Explicitamos simbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global clear_bytes
.global memcpy_bytes
.global memcpy_8w

/*---------------------------------------------------------------------------------------------------------  .clear_bytes */

.section .memory_func, "ax"            

clear_bytes:

/*---  como deben precargarse los registros antes de llamar esta funcion */
		@ LDR r0, =0x00000000	    @ valor 0 zero para borrar, pero si esta funcion fuera set
		@ LDR r1, =__bss_start__	@ _dir_inicio_data_borrar
		@ LDR r2, =__bss_end__		@ _dir_final_data_borrar
		@ BL clear_bytes

clear_loop:
	CMP r1, r2                  @ comparamos si el indice es menor que el final
	BEQ clear_end				@ si fueran iguales las dir inicio y fin, no hay nada que hacer, salgo
	STRLT r0, [r1], #4          @ si es menor, debemos grabarlo y aumentar el puntero r1
	BLT clear_loop              @ si es menor, volvemos al loop para volver a comparar
clear_end:
	MOV	pc, lr                  @ si no es menor, termino de recorrer el indice, volvemos al branch with link BL que lo llamo



/*---  como deben precargarse los registros antes de llamar esta funcion */
        @ LDR R0, =variables_no_init		// puntero donde volcar el array ordenado			@ _dir_inicio_data_copiar
        @ LDR R1, =variables_init 			// puntero a array desordenado						@ _dir_inicio_data_pegar
        @ MOV R2, #40						// cant de elementos a ordenar (*4 para ser words)	@ _largo_data_copiar ; inicio + largo = _final_data_copiar
        @ BL memcpy_bytes					// copiamos al destino aunque este desordenado

memcpy_bytes:
        CMP R2, #0
        BEQ memcpy_end
memcpy_loop:
        LDRB R3, [R1], #1
        STRB R3, [R0], #1
        SUBS R2, R2, #1
        BNE memcpy_loop
memcpy_end:
        BX LR //r14





/*---  como deben precargarse los registros antes de llamar esta funcion */
		@ LDR r0, =__KERNEL_START_LMA		@ _dir_inicio_data_copiar
		@ LDR r1, =__KERNEL_START_VMA		@ _dir_inicio_data_pegar
		@ LDR r2, =__KERNEL_SIZE			@ _largo_data_copiar ; inicio + largo = _final_data_copiar
		@ BL	memcpy_rom

memcpy_8w:
							    @ tenemos que tener previamente los punteros _inicio_data_copiar en r0, y _inicio_data_pegar en r1
							    @ asi el bloque de codigo en r0 = _inicio_data_copiar, se copiara en r1 = _inicio_data_pegar en adelante
	ADD r2, r2, r0 			    @  r2 = _largo_data_copiar + _inicio_data_copiar
	copy_8w:
		LDMIA	r0!, {r3 - r10}	@ load memory increment after. carga lo que hay desde r0 inclusive a r3 , luego incrementar r0 y cargarlo en r4,....
								@ hasta cargar en r10, = desde la pos r0 cargar 8*4bytes, o sea lo que esta en r0 y los siguientes 7 words
		STMIA	r1!, {r3 - r10}	@ store memory increment after, al final de todo en r0 quedo el ultimo valor de direccion donde termino la copia
		CMP	r0, r2 				@ compara la ultima direccion de copia que quedo en r0, contra el contenido de r2 (r2 = _final_data_copiar por el primer add)
		BLE	copy_8w
	MOV	pc, lr                  @ volvemos al branch with link BL que lo llamo
	