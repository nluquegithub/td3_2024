// 2024-04-30 20:38:35
/*
    Escribir WORD R1 a partir de la dir apuntada por R4.
    En comunicacion de red, los paquetes vienen con sus capas una detras de la otra, pero en BIG-ENDIAN.
    Lo contrario en procesadores ARM, en su mayoría trabajan los datos por default en LITTLE-ENDIAN.
 */
        LDR R1, [R5]
        MOV R2, R1      //,LSR #24 deberia funcionar tambien
        LSR R2, #24
        STRB R2, [R4], #1
        MOV R2, R1, LSR #16
        STRB R2, [R4], #1
        MOV R2, R1, LSR #8
        STRB R2, [R4], #1
        STRB R1, [R4], #1