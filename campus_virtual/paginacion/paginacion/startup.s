// Traducción de direcciones virtuales a físicas
// 0x70010000 - 0x7001FFFF -> 0x70010000 - 0x7001FFFF       son iguales, identity mapping
// 0x80000000 - 0x8000FFFF -> 0x70800000 - 0x7080FFFF       re-mapeo 64kib
// El resto de las direcciones virtuales deben ser inválidas.
// Hecho por Darío Alpern el 6 de junio de 2023.

// Más info en https://developer.arm.com/documentation/den0013/d/Boot-Code/Booting-a-bare-metal-system

// Primera traducción: dir virtual 700 10 000
// Indice 0x700 de primer nivel,
// Indice 0x10 de segundo nivel.

// Segunda traducción: dir virtual 800 00 000
// Indice 0x800 de primer nivel,
// Indice 0x00 de segundo nivel.

// Valores a escribir:
// En tabla de primer nivel TTL1:
// Primera traducción: dir 0x70081C00 => 0x70090001 base de TTL2_1 traducida +1, los bits más bajos ..01 son de attr, o sea descriptor "Page Table"
/* ver https://www.notion.so/nluque-utn-frba/Paginaci-n-3daef3376aca4785a16c056a8f2aca2b?pvs=4#26ccd95334ff4766862b8e77160ca877
0x70081C00 = 0x70080000 dir base de TTBR0 + ((0x700 index L1,  * 4 para tener el offset)= 0x1c00)*/
// Segunda traducción: dir 0x70082000 => 0x700A0001 base de TTL2_2 traducida +1
/* idem anterior
0x70082000 = 0x70080000 dir base de TTBR0 + ((0x800 index L1,  * 4 para tener el offset)= 0x2000)*/
// En primera tabla de segundo nivel:
// dir 0x70090040 => 0x70010032

// En segunda tabla de segundo nivel:
// dir 0x700A0000 => 0x70800032
/* estas direcciones, para el tp deberiamos armarlas con symbols en el linker_script */
      .equ tabla_primer_nivel, 0x70080000       /* la base de TTL1 tiene que estar alineada a 16k */
      .equ tabla_segundo_nivel1, 0x70090000     /* la base de TTL2_i tiene que estar alineada a 1k */
      .equ tabla_segundo_nivel2, 0x700A0000
      .equ DIR_FISICA1, 0x70010000
      .equ DIR_FISICA2, 0x70800000
      .equ longitud_tablas, tabla_segundo_nivel2 + 0x10000 - tabla_primer_nivel     /* servira para saber cuanto espacio de memoria uso, y luego debo borrar a zero todo antes de escribir los valores que necesito, de esta manera todos los demas punteros al tener zero en su atributo son entries invalidas, o sda page fault, salta una excepcion */
      .global _start

_start:

// Para probar la paginación, escribir 0x12345678 en la
// dirección física PA 0x70800000. Luego de la habilitación
// de la MMU, deberíamos leer este valor en la dirección:
// VA 0x80000000.
      LDR R0, =DIR_FISICA2
      LDR R1, =0x12345678
      STR R1, [R0]

// Borrar las tablas de paginación.       // conceptualmente 'memset' o 'memzero'
      LDR R1, = tabla_primer_nivel
      LDR R2, = longitud_tablas     // agregar (/4) para trabajar con words en vez de bytes
      MOV R0, #0
ciclo_borrado:
      STRB R0, [R1], #1 //cambiar el #1 a #4, y borrar el ..B de la instruccion para trabajar de a word en vez de byte
      SUBS R2, #1
      BNE ciclo_borrado

// Inicializar ambas entradas de la tabla de primer nivel.
// Índice 0x700 apunta a tabla de páginas.
      LDR R0, =tabla_primer_nivel + 0x700*4
      /* NOTE! atributos, attr TTL1 */
      // Bits 31-10: BADDR (dirección base tabla nivel 2)
      // 9: No usado
      // 8-5: dominio         //client, manager, ... del registro DACR cp15
      // 4: cero,
      // 3: NS (no seguro),
      // 2: PXN (no ejecución=0)      //separar codigo de datos, o sea una pag de .text =0, en las .data=1, .bss=1, .rodata=1, y los stacks=1 (no ejecutar)
      // 1: cero,  bits[1:0]=0b01 para indicar que es descriptor de Page Table
      // 0: uno.
      LDR R1, =tabla_segundo_nivel1 + 1
      STR R1, [R0]

/* NOTE! sobre el stack
/////// esta zona, min 1 pag, de valores huella, o sea 4k, en zero para provocar un PAGE_FAULT por excepcion
PILA
/////// esta zona, min 1 pag, de valores huella, o sea 4k, en zero para provocar un PAGE_FAULT por excepcion
 */


// Índice 0x800 apunta a tabla de páginas.
      LDR R0, =tabla_primer_nivel + 0x800*4
      // Bits 31-10: BADDR (dirección base tabla nivel 2)
      // 9: No usado
      // 8-5: dominio
      // 4: cero,
      // 3: NS (no seguro),
      // 2: PXN (no ejecución)
      // 1: cero,
      // 0: uno.
      LDR R1, =tabla_segundo_nivel2 + 1
      STR R1, [R0]

// Inicializar entrada 0x10 de la primera tabla de segundo nivel.
// AP 011 significa acceso lectura/escritura.
      /* NOTE! atributos, attr TTL2 */
      LDR R0, =tabla_segundo_nivel1 + 0x10*4
      // Bits 31-12: BADDR (dir. base)
      // 11: nG (no global),              /* nG=1 cuando le permitimos que se borren, pero si nG=0, estamos marcando como global para que no se borren del cache de TLB (por ejemplo ciertas paginas del KERNEL) */
      // 10: S (memoria compartida)
            // bits del cache de los procesadores, permisos de escritura/lectura, etc, es la combinacion de AP2, TEX[1:0], AP1, AP0. los solemos poner en 0b00000 para usar el cache normalmente
                  // 9: AP2 (bits de permisos)
                  // 8-6: TEX (atributos de la región de memoria)
                  // 5-4: AP1, AP0 (bits de permisos)
            // NOTE! releer, el uso del cache, y como configurar los bits TEX, C, B. Cuando se trata de un device, como mapear el GIC, TIMER, etc, hay que usar una combinacion particular para que no se use cache, del tipo 'device'
      // 3: C (atributos de la región de memoria)
      // 2: B (atributos de la región de memoria)
      // 1: uno         // para indicar que es descriptor de Small-Page
      // 0: XN (la página no se puede ejecutar).
      LDR R1, =DIR_FISICA1 + 0x30 + 2
      STR R1, [R0, #0]

// Inicializar entrada 0x00 de la segunda tabla de segundo nivel.
// AP 011 significa acceso lectura/escritura.
      LDR R0, =tabla_segundo_nivel2 + 0x00*4
      // Bits 31-12: BADDR (dir. base)
      // 11: nG (no global),
      // 10: S (memoria compartida)
      // 9: AP2 (bits de permisos)
      // 8-6: TEX (atributos de la región de memoria)
      // 5-4: AP1, AP0 (bits de permisos)
      // 3: C (atributos de la región de memoria)
      // 2: B (atributos de la región de memoria)
      // 1: uno
      // 0: XN (la página no se puede ejecutar).
      LDR R1, =DIR_FISICA2 + 0x30 + 2
      STR R1, [R0, #0]

// TTBR0 debe apuntar a la tabla de directorio de páginas =  tabla de 1er nivel TTL1
      LDR R0,=tabla_primer_nivel
      MCR p15, 0, R0, c2, c0, 0     // escribe R0 en el registro TTBR0

// Todos los dominios van a ser cliente.
      LDR R0, =0x55555555           // valores 010101.. en binario, para los domain groups
      MCR p15, 0, R0, c3, c0, 0     // escribe R0 en el registro DACR

// Habilitar MMU
      MRC p15, 0,R1, c1, c0, 0    // Leer reg. control.
      ORR R1, R1, #0x1            // Bit 0 es habilitación de MMU.
      MCR p15, 0, R1, c1, c0, 0   // Escribir reg. control.

      B .
