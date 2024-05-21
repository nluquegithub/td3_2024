// Cálculo de factorial en binario usando una palabra.
// Hecho por Dario Alpern el 6 de abril de 2023.
      .global _start
      .section .text          // Sección de còdigo.
_start:                       // Símbolo que le indica al linker
                              //  donde arranca el programa.
      MOV R1, #1              // Inicializar factorial.
      LDR R2, =argumento      // Leer el argumento del factorial
      LDR R0, [R2]
      CMP R0, #0
      BEQ factorial_calculado // No ejecutar ciclo si el argumento es cero.
ciclo_calculo_factorial:
      MUL R3, R1, R0          // R3 <- R1 * R0. El registro destino debe ser
                              // diferente que los registros fuente.
      MOV R1, R3              // Almacenar producto.
      SUBS R0, R0, #1         // Decrementar el argumento.
      BNE ciclo_calculo_factorial // Si no es cero, continuar ciclo.
factorial_calculado:
      LDR R2, =factorial      // Escribir el factorial en memoria.
      STR R1, [R2]
      B .

     .section .data           // Sección de datos inicializados.
argumento: .word 4            // Argumento del factorial.
                              /* el .word 4 es como definir una constante */
     .section .bss            // Sección de datos no inicializados.
                              // "w" -> se puede escribir. 
factorial: .space 4   // Reservar una palabra para guardar el factorial.
                              /* el .space es como "saltearse" de a bytes, en este caso 4 bytes,
                              como reservar espacio para algo, 
                              que en nuestro ejemplo es como reservar una variable vacia */