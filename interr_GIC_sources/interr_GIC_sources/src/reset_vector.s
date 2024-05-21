/**
 * Archivo: reset_vector.s
 * Función: retorno a la zona post reset
 * Autor: Ferreyro
 **/

/* Le asignamos la sección a _reset_vector */
 .section .text_pub

/* Modo de funcionamiento: arm */
.code 32

.extern _start
.global _reset_vector

.section ._reset_vector_code

_reset_vector:
   @ ldr PC,=_start
   B _start

.end
