.extern suma_c
.extern _PUBLIC_STACK_INIT

.global _start

.code 32
.section .text
_start:
    LDR SP,=_PUBLIC_STACK_INIT

    MOV R0, #0x10
    MOV R1, #0x20

    /* B suma_c */

    LDR R10, =suma_c
    BLX R10

    B .
    
.end

