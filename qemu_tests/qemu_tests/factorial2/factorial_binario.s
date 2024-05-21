// Cálculo de factorial en binario.
// Si el factorial no entra en el buffer asignado,
// escribir ceros en ese buffer.
// Hecho por Dario Alpern el 6 de abril de 2023.
//
// Usar instrucción UMLAL RdLo, RdHi, Rm, Rs
// RdHi:RdLo <- RdHi:RdLo + Rm * Rs.
      .equ max_palabras, 20
      .global _start
      .section .text          // Sección de còdigo.
_start:                       // Símbolo que le indica al linker
                              //  donde arranca el programa.
      MOV R1, #1              // Inicializar factorial a 1 en "little endian".
      LDR R2, =factorial
      STR R1, [R2], #4
      MOV R1, #0
      MOV R0, #max_palabras - 1
ciclo_inicializacion_factorial:
      STR R1, [R2], #4
      SUBS R0, R0, #1         // Restar 1 y actualizar indicadores
                              // para que funcione el salto condicional.
      BNE ciclo_inicializacion_factorial

      LDR R2, =argumento      // Leer el argumento del factorial
      LDR R0, [R2]
      MOV R4, #1              // Cantidad de palabras significativas del factorial.
      CMP R0, #0
      BEQ factorial_calculado // No ejecutar ciclo si el argumento es cero.
ciclo_calculo_factorial:
      // En este ciclo hay que multiplicar el número almacenado en factorial por
      // el registro R0. El número indicado ocupa R4 palabras.
      LDR R2, =factorial
      MOV R3, R4              // Obtener cantidad de palabras a multiplicar.
      MOV R5, #0              // Inicializar parte baja del acumulador de
                              // multiplicaciones.
ciclo_multiplicaciones:
      LDR R7, [R2]            // Obtener palabra del número a multiplicar.
      MOV R6, #0              // Inicializar parte alta del acumulador de
                              // multiplicaciones.
      UMLAL R5, R6, R7, R0    // R6:R5 <- R6:R5 + R7 * R0.
      STR R5, [R2], #4        // Guardar parte baja del acumulador.
                              // y apuntar a la siguiente palabra.
      MOV R5, R6              // La parte alta del acumulador es la parte
                              // baja para la siguiente multiplicación.
      SUBS R3, R3, #1
      BNE ciclo_multiplicaciones
      CMP R5, #0
      BEQ multiplicacion_hecha
      ADD R4, R4, #1          // El producto tiene una palabra más.
      CMP R4, #max_palabras + 1  // Verificar si la nueva palabra entra
                                 // en el número.
      BEQ factorial_demasiado_grande

      STR R5, [R2]            // Almacenar nueva palabra.
multiplicacion_hecha:
      SUBS R0, R0, #1         // Decrementar el argumento.
      BNE ciclo_calculo_factorial // Si no es cero, continuar ciclo.
factorial_calculado:
      B fin
factorial_demasiado_grande:
      LDR R2, =factorial
      MOV R1, #0
      MOV R0, #max_palabras
ciclo_borrado_factorial:
      STR R1, [R2], #4
      SUBS R0, R0, #1         // Restar 1 y actualizar indicadores
                              // para que funcione el salto condicional.
      BNE ciclo_inicializacion_factorial
fin:
      B .
     .section .data           // Sección de datos inicializados.
argumento: .word 4            // Argumento del factorial.

     .section .bss            // Sección de datos no inicializados.
                              // "w" -> se puede escribir. 
factorial: .space max_palabras // Reservar espacio de memoria para el factorial.
