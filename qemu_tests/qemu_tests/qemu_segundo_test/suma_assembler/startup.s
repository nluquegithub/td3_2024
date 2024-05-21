.section .text
.global _start
_start:
    MOV R2, #0x10
    MOV R1, #0x20
    BL suma_assembler

    //B .

	MOV R2, #0x40
	MOV R1, #0X50

	BL suma_assembler
	B .
    
suma_assembler:
    ADD R3, R1, R2 
    BX	R14				// volver con el registro LR a linea 13
