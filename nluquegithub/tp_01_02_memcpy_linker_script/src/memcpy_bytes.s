// memcpy_bytes.s 2024.04.09
// 2024.05.25 probado en DDD y GDB ok
// COPIAR UN BLOQUE DE MEMORIA de a 1 byte memcpy

/* Simbolos de direcciones definidas externamente en otro archivo o en linker_script */
.extern __KERNEL_START_VMA      // PUNTERO_DESTINO
.extern __KERNEL_START_LMA      // PUNTERO_FUENTE
.extern __KERNEL_SIZE           // CANT_BYTES a copiar
.extern __PILA_SIZE    
.extern __BSS_SIZE      

/* Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global _start

/*---------------------------------------------------------------------------------------------------------  .memcpy_asm */

.section .memcpy_asm, "ax"            // Comienzo de seccion, no usamos ".text", que es lo mismo que decir que es sección de codigo, para dejarlo reservado
                                // "ax" son progbits flags para indicar que la seccion es "a" allocable (re-ubicable) y "x" ejecutable.
_start:                         // Simbolo que le indica al linker donde arranca el programa.

        LDR R0, =__KERNEL_START_VMA             // PUNTERO_DESTINO
        LDR R1, =__KERNEL_START_LMA             // PUNTERO_FUENTE
        LDR R2, =__KERNEL_SIZE                  // CANT_BYTES a copiar

        BL memcpy_byte
        B prueba             /* saltar al codigo de la section a ejecutar en VMA */

memcpy_byte:
        CMP R2, #0
        BEQ memcpy_end
memcpy_loop:
        LDRB R3, [R1], #1
        STRB R3, [R0], #1
        SUBS R2, R2, #1
        BNE memcpy_loop
memcpy_end:
        BX LR //r14


/*---------------------------------------------------------------------------------------------------------  .kernel */
.section .kernel, "ax"

prueba:
        LDR R0, =variable
        MOV R1, #4
        STR R1, [R0]
        B .


/*---------------------------------------------------------------------------------------------------------  .bss */
.section .bss   // Sección de datos no inicializados.
                // "w" -> se puede escribir.
variable:
        .space =__BSS_SIZE


/*---------------------------------------------------------------------------------------------------------  .pila */
.section .pila
_pila:
        .space =__PILA_SIZE        // Reservar una palabra para guardar el factorial.
                              /* el .space es como "saltearse" de a bytes, en este caso 4 bytes,
                              como reservar espacio para algo,
                              que en nuestro ejemplo es como reservar una variable vacia */
