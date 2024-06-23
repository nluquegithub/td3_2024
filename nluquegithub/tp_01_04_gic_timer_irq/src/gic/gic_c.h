#ifndef __GIC_LIB_H
#define __GIC_LIB_H

#include <stddef.h>
#include <stdint.h>

/*
	Las siguientes definiciones dependen de la implementacion del SoC.
	En nuestro proyecto se trata de la placa PB-A9 Real View de ARM.
	Direcciones base:
	https://developer.arm.com/documentation/dui0417/d/programmer-s-reference/generic-interrupt-controller--gic
	ID de interrpciones:
	https://developer.arm.com/documentation/dui0417/d/programmer-s-reference/generic-interrupt-controller--gic/interrupt-signals?lang=en
*/

#define GICC0_ADDR 0x1E000000 //
#define GICD0_ADDR 0x1E001000 //
#define GICC1_ADDR 0x1E010000
#define GICD1_ADDR 0x1E011000
#define GICC2_ADDR 0x1E020000
#define GICD2_ADDR 0x1E021000
#define GICC3_ADDR 0x1E030000
#define GICD3_ADDR 0x1E031000

#define GIC_SOURCE_TIMER0 36
#define GIC_SOURCE_TIMER1 37
#define GIC_SOURCE_TIMER2 73
#define GIC_SOURCE_TIMER3 74

#define GIC_SOURCE_UART0 44
#define GIC_SOURCE_UART1 45
#define GIC_SOURCE_UART2 46
#define GIC_SOURCE_UART3 47

#define IAR_ID_MASK 0x3FF
#define EOIR_ID_MASK 0x3FF

/* Esta macro sirve para calcular el espacio de memoria reservado entre dos direcciones limite inferior y superior.
	x: indica el sub_indice de la zona de memoria reservada, como un gap reserved0, reserved1, .. reservedx
	y: offset para la direccion de inicio del gap
	z: offset para la direccion de fin del gap
*/
#define gic_reserved_bits(x, y, z) uint8_t reserved##x[z - y + 1];

/* Las siguientes estructuras tienen en cuenta la arquitectura generica del GIC.
	https://developer.arm.com/documentation/ihi0048/a/Programmers-Model/About-the-programmers-model?lang=en
*/

/* NOTE! 2024-06-23 19:40:00
	originalmente, pensaba que era necesario colocar el atributo (packed), para obligar al compilador
	a que estuviese optimizando su tamanno para que coincida exactamente con la disposicion de los registros en hardware, 
	sin espacio desperdiciado debido a la alineacion automática. Pero justamente, me quedaba desalineada y no se cargaban
	bien las configuraciones. Al dejarlo sin ese atributo, se mantiene la alineacion en pasos de 'uint32_t'.
*/

typedef volatile struct /* __attribute__((packed)) */
{
	uint32_t CTLR;
	uint32_t PMR;
	uint32_t BPR;
	uint32_t IAR;
	uint32_t EOIR;
	uint32_t RPR;
	uint32_t HPPIR;
} _gicc_t; // cpu interface

typedef volatile struct /* __attribute__((packed)) */
{
	uint32_t CTLR;
	uint32_t TYPER;
	gic_reserved_bits(0, 0x0008, 0x00FC);
	uint32_t ISENABLER[3];
	gic_reserved_bits(1, 0x010C, 0x017C);
	uint32_t ICENABLER[3];
	gic_reserved_bits(2, 0x018C, 0x01FC);
	uint32_t ISPENDR[3];
	gic_reserved_bits(3, 0x020C, 0x027C);
	uint32_t ICPENDR[3];
	gic_reserved_bits(4, 0x028C, 0x02FC);
	uint32_t ISACTIVER[3];
	gic_reserved_bits(5, 0x030C, 0x03FC);
	uint32_t IPRIORITYR[24];
	gic_reserved_bits(6, 0x0460, 0x07FC);
	uint32_t ITARGETSR[24];
	gic_reserved_bits(7, 0x860, 0x0BFC);
	uint32_t ICFGR[6];
	gic_reserved_bits(8, 0x0C18, 0x0EFC);
	uint32_t SGIR;
	gic_reserved_bits(9, 0x0F04, 0x0FFC);
} _gicd_t; // distributor

/* Prototipos de funciones */

void gic_init(void);

#endif // __GIC_LIB_H
