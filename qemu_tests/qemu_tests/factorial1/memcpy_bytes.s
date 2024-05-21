// COPIAR UN BLOQUE DE MEMORIA
// de a 1 byte memcpy
      .global _start
      .section .text          // Sección de còdigo.
_start:                       // Símbolo que le indica al linker
                              //  donde arranca el programa.
        LDR R0, =puntero_destino
        LDR R1, =puntero_fuente
        LDR R2, =cant_bytes

        B   memcpy_byte
        B   .

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


puntero_destino:    .word 0x70020000
puntero_fuente:     .word 0x70030000
cant_bytes:         .word 4
                              /* el .word 4 es como definir una constante */

                              
     .section .bss            // Sección de datos no inicializados.
                              // "w" -> se puede escribir. 
variables: .space 4   // Reservar una palabra para guardar el factorial.
                              /* el .space es como "saltearse" de a bytes, en este caso 4 bytes,
                              como reservar espacio para algo, 
                              que en nuestro ejemplo es como reservar una variable vacia */