#include "gic_c.h"

/*
	Funcion de inicializacion de GIC (Generic Interrupt Controller).
	Ver el header por las definiciones de constantes segun la implementacion especifica del SoC.
*/


__attribute__((section(".gic_init"))) void gic_init()
{

	_gicc_t *const GICC0 = (_gicc_t *)GICC0_ADDR;
	_gicd_t *const GICD0 = (_gicd_t *)GICD0_ADDR;

	GICC0->PMR = 0x000000F0; // Priority mask register. Por arriba de este valor, no pasa la señal de interrupcion al cpu. Hacia valor 0 mayor prioridad.
	/*Given an interrupt with id N, enabling it means setting the bit N % 32 in register N / 32, where integer division is used.
	For example, interrupt 45 would be bit 13 (45 % 32 = 13) in ISENABLER[1] (45 / 32 = 1).*/
	// TODO: crear una funcion para setear la prioridad de una IDx de interrupcion. Ahora con la F en PMR pasan todas.

	// TODO: cambiar este harcoding por una funcion que permita habilitar/deshabilitar el IDx
	GICD0->ISENABLER[1] |= 0x00000010; // Timer0-1		//ID 36, corresponde el bit 4 0b0000_0000_0000_0000_0000_0000_0001_0000 = 0x0000_0010
	// GICD0->ISENABLER[1] |= 0x00001000; //UART0		//ID 44, corresponde el bit 4 0b0000_0000_0000_0000_0001_0000_0000_0000 = 0x0000_1000
	GICC0->CTLR = 0x00000001; // habilita la señal a CPU Interface
	GICD0->CTLR = 0x00000001; // habilita el distribidor

	return;
}
