/* 
    Definiciones necesarias: formato de salida, arquitectura y punto de entrada
*/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

/* Direcciones base para MAPA DE MEMORIA, según la placa y  el SOC */
__VECTOR_TABLE_BASE = 0x00000000;
__PUBLIC_ROM_INIT = 0x70010000;
__KERNEL_VMA = 0x70030000;
__STACK_BASE = 0x70040000;

/* Inicializo el tamaño de los stack de los diferentes modos  */
__SYS_STACK_SIZE = 4K;
__IRQ_STACK_SIZE = 4K;
__FIQ_STACK_SIZE = 4K;
__SVC_STACK_SIZE = 4K;
__ABT_STACK_SIZE = 4K;
__UND_STACK_SIZE = 4K;
GAP_SIZE = 4K; 			/* #TODO, para cuando paginemos, hay que dejar un gap del tamaño de 1 pagina, o sea 4k, lleno con zeros para tener excepciones fault entry */

/* 
    Definición de las secciones
*/
SECTIONS
{
	/*	especifico diferente VMA (donde se va a ejecutar) <> que LMA donde debe estar grabado o pegado por el programador usando funcion memcpy */
	. = __VECTOR_TABLE_BASE ;
			
	.vector_table_out : 
		AT (__PUBLIC_ROM_INIT) 
		{
			__VECTOR_TABLE_START_VMA = . ;
				*(.vector_section)
			__VECTOR_TABLE_END_VMA = . ; 
		}  /* > VMA AT> LMA // only if MEMORY was declared*/


	__VECTOR_TABLE_SIZE = SIZEOF(.vector_table_out);		/* lo uso para hacer la copia a 0x0000_0000 luego en asm*/
	__VECTOR_TABLE_START_LMA = LOADADDR(.vector_table_out);
	__RESET_ROM_START_LMA =  __VECTOR_TABLE_SIZE + __VECTOR_TABLE_START_LMA ;

	
	.reset_rom_out __RESET_ROM_START_LMA :					/* aca estoy asignando a VMA el mismo valor que en LMA en .reset_rom_out*/
		AT ( __RESET_ROM_START_LMA )
		{
				*(.secuencia_reset)
		}

	__RESET_ROM_SIZE = SIZEOF(.reset_rom_out) ;
	__KERNEL_LMA = __RESET_ROM_SIZE + LOADADDR(.reset_rom_out) ;

	/*	especifico diferente VMA (donde se va a ejecutar) <> que LMA donde debe estar grabado o pegado por el programador usando funcion memcpy */
	.kernel_out __KERNEL_VMA :
		AT ( __KERNEL_LMA )
		{
			__HANDLERS_START = . ;
				*(.exception_handlers)
			__HANDLERS_END = . ;
				*(.kernel)
		}
	
	__KERNEL_SIZE = SIZEOF(.kernel_out) ;

	/* sección de stacks para determinar las direcciones top y poderlo inicializar en asm */
	. = __STACK_BASE ;
	
	.stacks_symbols :
		{
			. = ALIGN(4);
			
			__SYS_STACK_START = .;
			. += __SYS_STACK_SIZE;
			__SYS_STACK_END = .;
			. += GAP_SIZE;

			__IRQ_STACK_START = .;
			. += __IRQ_STACK_SIZE;
			__IRQ_STACK_END = .;
			. += GAP_SIZE;

			__FIQ_STACK_START = .;
			. += __FIQ_STACK_SIZE;
			__FIQ_STACK_END = .;
			. += GAP_SIZE;

			__SVC_STACK_START = .;
			. += __SVC_STACK_SIZE;
			__SVC_STACK_END = .;
			. += GAP_SIZE;

			__ABT_STACK_START = .;
			. += __ABT_STACK_SIZE;
			__ABT_STACK_END = .;
			. += GAP_SIZE;

			__UND_STACK_START = .;
			. += __UND_STACK_SIZE;
			__UND_STACK_END = .;
			. += GAP_SIZE;
		}
	
}
