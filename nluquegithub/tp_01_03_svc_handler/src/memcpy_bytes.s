// memcpy_bytes.s

/*2. LINKER SCRIPTS 
 
Modificar el ejemplo del segundo test provisto en Gitlab en el item 2. de párrafo anterior, que 
en el vector de arranque pueda copiar una sección de código de lo que será el micro kernel de 
nuestro sistema operativo, en la dirección 0x70030000. Para tal fin implementar: 
void *td3_memcopy(void *destino, const void *origen, unsigned int num_bytes); 
Una vez que se copia esta sección, el programa en el vector de arranque debe saltar al código 
de la sección copiada, en donde quedará en un ciclo infinito. 
La pila debe ubicarse en 0x70020000. 
Las dos secciones de código deben quedar ensambladas una atrás de la otra. Para tal fin se 
sugiere utilizar un archivo de linker script de modo de gestionar las áreas de memoria durante 
el ensamblado del binario. */

/* Simbolos de direcciones definidas externamente en otro archivo o en linker_script */
@ .extern __KERNEL_START_VMA      // PUNTERO_DESTINO
@ .extern __KERNEL_START_LMA      // PUNTERO_FUENTE
@ .extern __KERNEL_SIZE           // CANT_BYTES a copiar
@ .extern __PILA_SIZE    
@ .extern __BSS_SIZE      

/* Explicitamos símbolos globales para que puedan ser vistos por otros archivos y por el mapa de memoria */
.global _start
.global memcpy_byte

/*---------------------------------------------------------------------------------------------------------  .memcpy_asm */

.section .memcpy_asm, "ax"            // Comienzo de seccion, no usamos ".text", que es lo mismo que decir que es seccion de codigo, para dejarlo reservado
                                // "ax" son progbits flags para indicar que la seccion es "a" allocable (re-ubicable) y "x" ejecutable.
@ _start:                         // Simbolo que le indica al linker donde arranca el programa.

        @ Tener en cuenta que deben ser cargados estos valores antes de llamar a la funcion
        @ LDR R0, =__KERNEL_START_VMA             // PUNTERO_DESTINO
        @ LDR R1, =__KERNEL_START_LMA             // PUNTERO_FUENTE
        @ LDR R2, =__KERNEL_SIZE                  // CANT_BYTES a copiar

        @ BL memcpy_byte
        @ @ BL clear_bss          // #TODO agregar una rutina de clear_bss para asegurar de poner esa zona de memoria en ceros
        @ B bubble_sort             /* saltar al codigo de la section a ejecutar en VMA */

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


