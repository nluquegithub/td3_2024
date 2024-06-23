#include "exception_handlers.h"



__attribute__((section(".exception_handlers"))) void irq_handler_c()
{
	_gicc_t* const GICC0 = (_gicc_t*)GICC0_ADDR;
	_timer_t* const TIMER0 = ( _timer_t* )TIMER0_ADDR;
		

	uint32_t interrup_id;
	interrup_id = GICC0->IAR;

	switch (interrup_id)
	{
		case GIC_SOURCE_TIMER0:

			TIMER0->Timer1IntClr = 0x01;	// borramos el flag de esta irq source respecto del modulo del timer
			timer0_handler_c();			 	// antendemos la irq especifica
			break;

		default:
			break;

	}
	GICC0->EOIR= interrup_id;	   // borramos el flag de esta irq source respecto del modulo del gic
	return;

}



__attribute__((section(".exception_handlers"))) void timer0_handler_c()
{
	static uint32_t static_var_TMR = 0x84778200;	//ascii para "TMR" + ## (byte para contabilizar las entradas al handler)
	
	//en vez de escribir en r10, usaremos una variable local que acumule las veces que ingreso y lo colgamos de r10 momentaneamente
	//asm("ADD r10, r10, #1");	
	static_var_TMR++;
	asm volatile (
		"ldr r10, %0\n"	// Cargar el valor de static_var_TMR en r10
		:
		: "m" (static_var_TMR)
		: "r10"
	);
	
	return;
}













/* Estas funciones solo son para evidenciar que hubo entrada a cada handler */



__attribute__((section(".exception_handlers"))) void und_inst_handler_c()
{
	static uint32_t static_var_INV = 0x73788600;	//ascii para "INV" + ## (byte para contabilizar las entradas al handler)

	static_var_INV++;
	//asm("LDR r10, =static_var_TMR"); //esta forma no funciona
	asm volatile (
		"ldr r10, %0\n"	// Cargar el valor de static_var_TMR en r10
		:
		: "m" (static_var_INV)
		: "r10"
	);
	return;
}

__attribute__((section(".exception_handlers"))) void mem_abt_handler_c()
{
	static uint32_t static_var_MEM = 0x77697700;	//ascii para "MEM" + ## (byte para contabilizar las entradas al handler)

	static_var_MEM++;
	//asm("LDR r10, =static_var_TMR"); //esta forma no funciona
	asm volatile (
		"ldr r10, %0\n"	// Cargar el valor de static_var_TMR en r10
		:
		: "m" (static_var_MEM)
		: "r10"
	);
	return;
}

__attribute__((section(".exception_handlers"))) void prefetch_abt_handler_c()
{
	static uint32_t static_var_PRF = 0x50524600;	//ascii para "PRF" + ## (byte para contabilizar las entradas al handler)

	static_var_PRF++;
	//asm("LDR r10, =static_var_TMR"); //esta forma no funciona
	asm volatile (
		"ldr r10, %0\n"	// Cargar el valor de static_var_TMR en r10
		:
		: "m" (static_var_PRF)
		: "r10"
	);
	return;
}

__attribute__((section(".exception_handlers"))) void svc_handler_c()
{
	static uint32_t static_var_SVC = 0x83866700;	//ascii para "SVC" + ## (byte para contabilizar las entradas al handler)

	static_var_SVC++;
	//asm("LDR r10, =static_var_TMR"); //esta forma no funciona
	asm volatile (
		"ldr r10, %0\n"	// Cargar el valor de static_var_TMR en r10
		:
		: "m" (static_var_SVC)
		: "r10"
	);
	return;
}


/* TRIGGERS: funciones de prueba de los handlers */

__attribute__((section(".exception_handlers"))) void trigger_und_inst_excep()
{
	// Execute an undefined instruction (not a valid ARM instruction)

	asm("NOP");		// con "nop" espero corregir la alineacion a 4 bytes
	asm("UDF #0");	//cualquier instruccion que sirva para disparar la excepcion de undefined instruction

	return;
}

__attribute__((section(".exception_handlers"))) void trigger_prefetch_abt_excep()
{

	asm("BKPT");	// esta instruccion en modo Thumb me deja desalineado el codigo
	asm("NOP");		// con "nop" espero corregir la alineacion a 4 bytes

	return;
}


__attribute__((section(".exception_handlers"))) void trigger_mem_abt_excep()
{
	// Acceder a una direccion invalida
	asm("LDR r0, =0xFFFFFFFF"	);
	asm("LDR r0, [r0]"			);

	return;
}