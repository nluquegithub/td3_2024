.section .text
_start:
    MOV R2, #0x10
    MOV R1, #0x20

    B suma_assembler

    B .
    
suma_assembler:
    ADD R3, R1, R2 

    B .
