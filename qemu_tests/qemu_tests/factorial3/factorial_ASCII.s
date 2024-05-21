// Cálculo de factorial.
// El programa tiene dos rutinas. La generaciòn del factorial en binario
// debe estar en modo Thumb, mientras que la conversiòn a ASCII debe
// estar en modo ARM.
// No se deben usar los registros R8-R12.
// Si el factorial no entra en el buffer asignado,
// escribir ceros en ese buffer.
// 
// Hecho por Dario Alpern el 6 de abril de 2023.
//
// Usar instrucción UMLAL RdLo, RdHi, Rm, Rs
// RdHi:RdLo <- RdHi:RdLo + Rm * Rs.
      .equ max_palabras, 20
      .equ max_digitos, max_palabras * 10
      .global _start
      .section .text          // Sección de còdigo.
      .arm
_start:                       // Símbolo que le indica al linker
                              //  donde arranca el programa.
      LDR R13, =fin_pila      // Inicializar puntero de pila. 
      LDR R0, =factorial_en_binario + 1 // Encender bit 0 para indicar "thumb".
      BLX R0                  // Se debe usar BLX para cambiar de modo.
      BL convertir_a_ASCII
      B .

      .thumb
factorial_en_binario:
      MOV R1, #1              // Inicializar factorial a 1 en "little endian".
      LDR R2, =factorial_bin
      STR R1, [R2]            // Inicializar la palabra menos significativa con 1. 
      MOV R1, #0
      MOV R0, #max_palabras - 1
ciclo_inicializacion_factorial:
      ADD R2, #4              // Apuntar a la siguiente palabra.
      STR R1, [R2]            // Inicializar palabra con cero.
      SUB R0, #1              // Thumb no soporta SUBS R0, R0, #1
      CMP R0, #0
      BNE ciclo_inicializacion_factorial

      LDR R2, =argumento      // Leer el argumento del factorial
      LDR R0, [R2]
      MOV R4, #1              // Cantidad de palabras significativas del factorial.
      CMP R0, #0
      BEQ factorial_calculado // No ejecutar ciclo si el argumento es cero.
ciclo_calculo_factorial:
      // En este ciclo hay que multiplicar el número almacenado en factorial por
      // el registro R0. El número indicado ocupa R4 palabras.
      LDR R2, =factorial_bin
      MOV R3, R4              // Obtener cantidad de palabras a multiplicar.
      MOV R5, #0              // Inicializar parte baja del acumulador de
                              // multiplicaciones.
ciclo_multiplicaciones:
      LDR R7, [R2]            // Obtener palabra del número a multiplicar.
      MOV R6, #0              // Inicializar parte alta del acumulador de
                              // multiplicaciones.
      UMLAL R5, R6, R7, R0    // R6:R5 <- R6:R5 + R7 * R0.
      STR R5, [R2]            // Guardar parte baja del acumulador.
      ADD R2, #4              // Apuntar a la siguiente palabra.
      MOV R5, R6              // La parte alta del acumulador es la parte
                              // baja para la siguiente multiplicación.
      SUB R3, #1
      CMP R3, #0
      BNE ciclo_multiplicaciones
      CMP R5, #0
      BEQ multiplicacion_hecha
      ADD R4, #1               // El producto tiene una palabra más.
      CMP R4, #max_palabras + 1  // Verificar si la nueva palabra entra
                                 // en el número.
      BEQ factorial_demasiado_grande

      STR R5, [R2]               // Almacenar nueva palabra.
multiplicacion_hecha:
      SUB R0, #1                 // Thumb no soporta SUBS R0, R0, #1.
      CMP R0, #0
      BNE ciclo_calculo_factorial // Si no es cero, continuar ciclo.
factorial_calculado:
      B fin_rutina
factorial_demasiado_grande:
      MOV R4, #1                 // Indicar una sola palabra válida.
      LDR R2, =factorial_bin     // Borrar el buffer del factorial en binario.
      MOV R1, #0
      MOV R0, #max_palabras
ciclo_borrado_factorial:
      STR R1, [R2]
      ADD R2, #4
      SUB R0, #1                 // Thumb no soporta la instrucciòn SUBS R0, R0, #1.
      CMP R0, #0
      BNE ciclo_inicializacion_factorial
fin_rutina:
      BX lr                      // Fin del subrutina. Volver a modo ARM.

      .arm
// La conversiòn a ASCII se realiza dividiendo el nùmero en binario
// sucesivamente por el valor 10 y el resto se convierte a ASCII.
// De esta manera se generan los dìgitos de derecha a izquierda.
// Ejemplo: para el número 234, 234/10 = 23 resto 4,
//          23/10 = 2 resto 3 y 2/10 = 0 resto 2.
convertir_a_ASCII:
      LDR R7, =factorial_ASCII + max_digitos - 1
      MOV R0, #0              // Procesar la cadena de salida de der. a izq.
      STRB R0, [R7], #-1      // Almacenar el terminador de cadena.
      LSL R4, #1              // Operar con medias palabras
                              // para usar la instrucciòn de división.
      // Si la media palabra más significativa vale cero, decrementar
      // la cantidad de medias palabras significativas.
      LDR R2, =factorial_bin - 2 
      MOV R3, R4, LSL #1      // Convertir medias palabras en offset
                              // multiplicando por 2.
      LDRH R1, [R2, R3]       // Obtener la media palabra más significativa.
      CMP R1, #0              // Saltar si no es cero.
      BNE ciclo_digitos
      SUB R4, #1              // Decrementar cantidad de medias palabras.
ciclo_digitos:
      PUSH {R7}               // Preservar puntero a digitos ASCII.
      MOV R0, #0              // Inicializar resto a cero.
      MOV R3, R4, LSL #1
ciclo_divisiones:
      LDRH R1, [R2, R3]       // Obtener parte baja del dividendo.
      ADD R1, R0, LSL #16     // Agregar el resto de la divisiòn anterior
                              // como parte alta del dividendo.
      // La instrucciòn de división se encuentra en pocos procesadores ARM,
      // así que se utilizan multiplicaciones para simular la divisiòn.
      // Para dividir por 10 usamos la fórmula (c = cociente, d = dividendo):
      //  c <- ((d - (d >> 30)) * 429496730) >> 32
      LDR R7, =429496730
      SUB R6, R1, R1, LSR #30 // R6 <- d - (d << 30)
      UMULL R7, R6, R7, R6    // R6:R7 <- R6 * R7. El cociente es R6.

      STRH R6, [R2, R3]       // Guardar cociente.
      MOV R7, #10
      MUL R5, R6, R7          // Hallar el resto. R5 <- cociente (R6) * 10 (R7).
      SUB R0, R1, R5          // R0 <- dividendo (R1) - cociente (R6) * 10 (R7).
      SUBS R3, R3, #2
      BNE ciclo_divisiones
      ADD R0, R0, #0x30       // Convertir dígito del resto a ASCII.
      POP {R7}                // Obtener de la pila el puntero a dígitos ASCII.
      STRB R0, [R7], #-1      // Almacenar dígito en buffer de salida.
      // Si la media palabra más significativa vale cero, restar uno a la
      // cantidad de medias palabras significativas.
      MOV R3, R4, LSL #1
      LDRH R1, [R2, R3]       // Obtener la media palabra más significativa.
      CMP R1, #0
      BNE ciclo_digitos       // Continuar ciclo si dicha palabra no es cero.
      SUBS R4, R4, #1         // Restar uno a la cantidad de medias
                              // palabras significativas.
      BNE ciclo_digitos       // Continuar ciclo si todavía hay medias
                              // palabras significativas.
      // Descartar ceros no significativos que estèn a la izquierda.
ciclo_ceros:
      LDRB R0, [R7, #1]!      // Obtener dìgito ASCII de la izquierda.
                              // La instrucciòn primero incrementa R8 y luego lee.
      CMP R0, #0x30           // Verificar si es cero.
      BEQ ciclo_ceros 
      LDR R6, =factorial_ASCII
ciclo_mover_a_izquierda:
      LDRB R0, [R7], #1       // Leer byte de origen e incrementar puntero.
      STRB R0, [R6], #1       // Escribir en destino e incrementar puntero.
      CMP R0, #0              // Continuar ciclo si no se encontró el
      BNE ciclo_mover_a_izquierda  // caràcter de finalización de cadena.
      BX R14                  // Fin de la subrutina que convierte a ASCII.
     .section .data           // Sección de datos inicializados.
argumento: .word 4            // Argumento del factorial.

     .section .bss            // Sección de datos no inicializados.
factorial_bin: .space max_palabras // Reservar espacio de memoria para el factorial.
factorial_ASCII: .space max_digitos + 1 // Salida en ASCII. Incluir carácter nulo.

     .section .stack
pila: .space 4096             // Pila.
fin_pila:
