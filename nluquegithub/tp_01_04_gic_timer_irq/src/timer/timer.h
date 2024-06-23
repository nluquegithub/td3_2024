
#include <stddef.h>
#include <stdint.h>

#define LOAD_5s 0x004C4B40
#define LOAD_3s 0X002DC6C0
#define LOAD_1s 0X000F4240
#define LOAD_100ms 0X000186A0
#define LOAD_10ms 0X00002710

/* Esta macro sirve para calcular el espacio de memoria reservado entre dos direcciones limite inferior y superior.
	x: indica el sub_indice de la zona de memoria reservada, como un gap reserved0, reserved1, .. reservedx
	y: offset para la direccion de inicio del gap
	z: offset para la direccion de fin del gap
*/
#define timer_reserved_bits(x, y, z) uint8_t reserved##x[z - y + 1];

/* Direcciones base para los registros de timer. Ver más abajo la referencia del manual web del timer SP804 Dual-Timer */
#define TIMER0_ADDR 0x10011000
#define TIMER1_ADDR 0x10012000
#define TIMER2_ADDR 0x10018000
#define TIMER3_ADDR 0x10019000

/* NOTE! 2024-06-23 19:40:00
	originalmente, pensaba que era necesario colocar el atributo (packed), para obligar al compilador
	a que estuviese optimizando su tamanno para que coincida exactamente con la disposicion de los registros en hardware,
	sin espacio desperdiciado debido a la alineacion automática. Pero justamente, me quedaba desalineada y no se cargaban
	bien las configuraciones. Al dejarlo sin ese atributo, se mantiene la alineacion en pasos de 'uint32_t'.
*/

typedef volatile struct /* __attribute__((packed)) */
{
	uint32_t Timer1Load;   //
	uint32_t Timer1Value;  //
	uint32_t Timer1Ctrl;   //
	uint32_t Timer1IntClr; //
	uint32_t Timer1RIS;
	uint32_t Timer1MIS;
	uint32_t Timer1BGLoad;
	timer_reserved_bits(0, 0x001C, 0x001F);
	uint32_t Timer2Load;
	uint32_t Timer2Value;
	uint32_t Timer2Ctrl;
	uint32_t Timer2IntClr;
	uint32_t Timer2RIS;
	uint32_t Timer2MIS;
	uint32_t Timer2BGLoad;
	timer_reserved_bits(1, 0x003C, 0x0EFF);
	uint32_t TimerITCR;
	uint32_t TimerITOP;
	timer_reserved_bits(2, 0x0F08, 0x0FDF);
	uint32_t PeriphID[4];
	uint32_t PCellID[4];
} _timer_t;

// Definición de la dirección base del registro SYS_CTRL0
#define SYS_CTRL0_BASE_ADDR 0x10001000

// Definición de los bits relevantes en el registro SYS_CTRL0
#define TMR0_CLOCK_REF 15

// Macro para acceder al registro SYS_CTRL0
#define SYS_CTRL0 (*( (volatile uint32_t *) SYS_CTRL0_BASE_ADDR))

/*
	En la estructura hay dos timers, porque el módulo de timer implementado en la placa PB-A8 Real view es el SP804 Dual-Timer.
	https://developer.arm.com/documentation/dui0417/d/programmer-s-reference/timers

	At reset, the timers are clocked by a 32.768kHz reference from an external oscillator module. Use the System Controller to change the timer reference from 32.768kHz to 1MHz.

	Para cambiar la fuente de clock:
	https://developer.arm.com/documentation/dui0351/e/programmer-s-reference/system-controller--sysctrl-/primecell-modifications?lang=en
*/

/* Prototipos de funciones */

void timer_init();