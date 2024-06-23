#include "../gic/gic_c.h"
#include "../timer/timer.h"

/* Esta parte sólo se implemeta para ej4 del tp, para evidenciar las instancias de ecepciones y seguir la consigna, las coloco dentro de cada handler.
	No es realmente necesario ni aporta algo util para lo demás ejercicios. Luego puede comentarse o removerse porque puede confundir. */
// static uint32_t static_var_INV = 0x73788600;	//ascii para "INV" + ## (byte para contabilizar las entradas al handler)
// static uint32_t static_var_MEM = 0x77697700;	//ascii para "MEM" + ## (byte para contabilizar las entradas al handler)
// static uint32_t static_var_SVC = 0x83866700;	//ascii para "SVC" + ## (byte para contabilizar las entradas al handler)
// static uint32_t static_var_TMR = 0x84778200;	//ascii para "TMR" + ## (byte para contabilizar las entradas al handler)


/* Prototipos de funciones */

void und_inst_handler_c(void);
void prefetch_abt_handler_c(void);
void mem_abt_handler_c(void);
void svc_handler_c(void);

void trigger_und_inst_excep(void);
void trigger_prefetch_abt_excep(void);
void trigger_mem_abt_excep(void);



void irq_handler_c(void);
void timer0_handler_c(void);