#include "timer.h"


__attribute__((section(".timer_init"))) void timer_init()
{

	_timer_t *const TIMER0 = (_timer_t *)TIMER0_ADDR;

	// Leer el valor actual del registro SYS_CTRL0
	uint32_t SYS_CTRL0_val = SYS_CTRL0;	// del bit 15 define si el clk es 1 MHz o 32.768kHz, solo lo agregue para verificar el clock

	// Verificar el estado del bit TMR0_CLOCK_REF (bit 15), segun su valor usaria un valor de Timer1Load distinto
	uint32_t TIMCLK_val = (SYS_CTRL0_val >> TMR0_CLOCK_REF) & 0x1;

	if (TIMCLK_val) {
		// El Timer 0 está habilitado y la referencia de tiempo es TIMCLK_val
	} else {
		// El Timer 0 está deshabilitado y la referencia de tiempo es REFCLK
	}


	/* Si la referncia de timer0 fuera REFCLK */
	// TIMER0->Timer1Load	= 327; 		// =327; 	// Periodo = 328 ticks / 32768 clk		~= 0.01 segundos 	@prescaler = 1
	// TIMER0->Timer1Load	= 163840; 	// =163840; // Periodo = 163840 ticks / 32768 clk	~= 5 segundos 		@prescaler = 1

	/* Pero en QEMU, se esta emulando directamente a TIMCLK_val @ 1MHz */
	// TIMER0->Timer1Load = LOAD_10ms;
	TIMER0->Timer1Load = LOAD_5s;		// NOTE! en mis pruebas uso un valor mucho mayor para experimentar
	TIMER0->Timer1Ctrl = 0x00000002; 	// Seleccionamos timer de 32-bit. PRESACALER bits = 00, div por 1
	TIMER0->Timer1Ctrl |= 0x00000040;	// Seleccionamos timer periodico
	TIMER0->Timer1Ctrl |= 0x00000020;	// Habilitamos interrupcion del timer
	TIMER0->Timer1Ctrl |= 0x00000080;	// Habilitamos el timer

	return;
}

/* El valor de recarga, depende del PRESCALER y de la frecuencia de clock como fuente del timer:
		https://developer.arm.com/documentation/dui0417/d/programmer-s-reference/timers
			"At reset, the timers are clocked by a 32.768kHz reference from an external oscillator module.
			Use the System Controller to change the timer reference from 32.768kHz to 1MHz."
		Para cambiar la fuente de clock:
		https://developer.arm.com/documentation/dui0351/e/programmer-s-reference/system-controller--sysctrl-/primecell-modifications?lang=en

		Hay dos fuentes posibles de clock:
			REFCLK	Cristal 32.768kHz 					Esta es la señal por default por la config de SYSCTRL
			TIMCLK_val	Señal de clock parametrizable. 		En placa PB-A8 Real View = 1MHz. <------ es lo que emula el QEMU

		El PRESCALER ademas viene por default en division por 1.

*/

/*	@Registro TimerControl:
		@   Bit 7: Habilita el temporizador
		@   Bit 6: Modo de operacion [0] Libre  [1] Periodico.
		@   Bit 5: Habilita de interrupcion
		@   Bit 4: Reservador. No usar/modificar
		@   Bits 3-2: Prescaler
		@	   [00] division por 1
		@	   [01] division por 16
		@	   [10] division por 256
		@	   [11] Reservador. No usar
		@   Bit 1: Tamaño de cuenta [0] 16 bits [1] 32 bits.
		@   Bit 0: [0] Modo recarga continua [1]: Detener en cuenta cero
*/