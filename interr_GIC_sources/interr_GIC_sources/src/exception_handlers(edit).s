/**
 * Archivo: exception_handlers.s
 * Función: manejadores de las excepciones
 * Autor: Ferreyro
 **/

.global UND_Handler
.global SVC_Handler
.global PREF_Handler
.global ABT_Handler
.global IRQ_Handler
.global FIQ_Handler

.section .text_handlers

UND_Handler:  
    LDR R10,=#0x0100
    RFEFD   SP!  

SVC_Handler:
    LDR R10,=#0x0200
    RFEFD   SP!

PREF_Handler:
    LDR R10,=#0x0300
    RFEFD   SP!

ABT_Handler:
    LDR R10,=#0x0400
    RFEFD   SP!

IRQ_Handler:
    LDR R10,=#0x0500
    RFEFD   SP!

FIQ_Handler:
    LDR R10,=#0x0600
    RFEFD   SP!


/* #TODO: revisar la ppt de furfaro para el uso correcto de RFEFD y el tema de los offset de retorno en LR */