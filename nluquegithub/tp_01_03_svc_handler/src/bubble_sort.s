// bubble_sort 2024.05.26
/*
Escribir un código en ensamblador capaz de ordenar un array de enteros. 
Para ello generar un espacio de 10 enteros inicializados y un espacio de 10 enteros para ubicar 
el resultado ordenado. */

/* Simbolos de direcciones definidas externamente en otro archivo o en linker_script */
@ .extern __KERNEL_START_VMA      // PUNTERO_DESTINO
@ .extern __KERNEL_START_LMA      // PUNTERO_FUENTE
@ .extern __KERNEL_SIZE           // CANT_BYTES a copiar
@ .extern __PILA_SIZE    
@ .extern __BSS_SIZE      

/* Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
@ .global _start
.global bubble_sort


/*---------------------------------------------------------------------------------------------------------  .kernel bubble_sort */
.section .kernel, "ax"


bubble_sort:                            // ordenar 10 enteros, asumimos que el orden deseado es ascendente
        LDR R0, =variables_no_init      // puntero donde volcar el array ordenado
        LDR R1, =variables_init         // puntero a array desordenado
        MOV R2, #40                     // cant de elementos a ordenar (*4 para ser words)
        BL memcpy_byte                  // copiamos al destino aunque este desordenado

bubble_start:
        LDR R0, =variables_no_init      // R0 = index_0 del array a ordenar
        ADD R1, R0, #4                  // R1 = index_1, los siguientes 4 bytes es el siguiente word o entero
        MOV R2, #9                      // R2 es la cant de pasadas por el array, revisando sus comparaciones y haciendo swaps necesarios
        MOV R3, #9                      // R3 es la cant de comparaciones entre 2 elementos internos (igual a cant elementos -1)
        MOV R7, #0      @ R7 sirve para contar y detectar si hubo swap en la pasada
        MOV R8, #0      @ R8 acumulara el total de swaps
        /* #FIXME 
                [x] falta contar con r3, como contador interno de elementos, con cada comparacion r3-- hasta cero
                [x] falta contar con r2, como contador externo de pasadas, cuando r3==0, recargar r3 (pero con un valor inferior al R3 de la pasada anterior), y r2--, hasta cero.       porque con cada pasada, el ultimo par de esa pasada quedo ordenado
                [-] para asegurar los registros, agregar al inicio y fin el push y pop a la pila
                [x] debug
        */


compare:
        LDR R5, [R0]                    // cargo lo apuntado a otros registros auxiliares
        LDR R6, [R1]    
        CMP R5, R6                      // CMP [R1], [R0] no se puede acceder con el puntero. CMP <Rn>, <Rm> hace la diferencia Rn - Rm, y actualiza los flags NZCV del cpsr
        BGT swap_values                 // *R0 > *R1, hay que cambiarlos de lugar

next_in:                                // *R0 < *R1, ok entonces me preparo para la siguiente comparacion
        SUBS R3, R3, #1                 // decremento el contador interno
        BEQ next_out                    // R3 quedo en cero, asi que se completo una pasada por el array
next_in_set:                            // R3 no quedo en cero, sigo dentro de la pasada actual
        ADD R0, R0, #4                  // incrementar el puntero R0, elemento izq de la siguiente comparacion dentro de la pasada actual
        ADD R1, R1, #4                  // incrementar el puntero R1, elemento der de la siguiente comparacion dentro de la pasada actual
        B compare       

next_out:                               // R3 quedo en cero, tengo que prepararme para la siguiente pasada externa por el array
        CMP R7, #0              @ si, R7==0 no hubo swaps, y termino una pasada, asumimos que quedo todo ordenado y salimos anticipadamente
        BEQ bubble_end
        ADD R8, R8, R7          @ agregamos los R7 swaps de esta pasada que termino, al R8 acumulador de swaps totales
        SUBS R2, R2, #1                 // decremento el contador externo
        BEQ bubble_end                  // R2 quedo en cero, asi que termino todas las pasadas por el array
next_out_set:                           // R2 no quedo en cero, preparo los valores para la siguiente pasada del array
        LDR R0, =variables_no_init      // recargo R0 con el valor inicial
        ADD R1, R0, #4                  // recargo R1 con el valor inicial
        MOV R3, R2                      // recargo R3, pero no con el mismo valor inicial, ahora sera una comparacion menos que la pasada anterior, igual que R2 contador externo
        MOV R7, #0
        B compare

swap_values:
        MOV R4, R6                      // R4  el aux para pivotear valores del swap
        MOV R6, R5
        MOV R5, R4
        /* valores auxiliares cambiados, ahora escribo en la memoria */
        STR R5, [R0]
        STR R6, [R1]
        ADD R7, R7, #1
        B next_in                       // me preparo para la siguiente comparacion

bubble_end:
        B .



/*---------------------------------------------------------------------------------------------------------  .data */
.section .data   // Seccion de datos inicializados.

variables_init:
        @ .space =__DATA_SIZE
        .word 1, 3, 2, 8, 9, 10, 5, 6, 4, 7      // 10 elementos enteros inicializados, desordenados
/*---------------------------------------------------------------------------------------------------------  .bss */
.section .bss   // Seccion de datos no inicializados.

variables_no_init:
        .space 40

