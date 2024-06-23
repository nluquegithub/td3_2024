/* 
	Definiciones necesarias: formato de salida, arquitectura y punto de entrada
*/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)


/* 
	Definiciones de simbolos necesarios
*/
__VECTOR_TABLE_BASE = 0x00000000;
__PUBLIC_ROM_INIT = 0x70010000;
__PUBLIC_STACK_INIT = 0x70020000;
__PUBLIC_RAM_INIT = 0x70030000;
__KERNEL_START_VMA = 0x70040000;

/* __BSS_SIZE = 10*4 ;
__DATA_SIZE = 10*4 ; */

/* Inicializo el tamaño de los stack de los diferentes modos  */
__SYS_STACK_SIZE = 4K;
__IRQ_STACK_SIZE = 4K;
__FIQ_STACK_SIZE = 4K;
__SVC_STACK_SIZE = 4K;
__ABT_STACK_SIZE = 4K;
__UND_STACK_SIZE = 4K;
__GAP_SIZE = 4K; 			/* para cuando paginemos, hay que dejar un gap del tamaño de 1 pagina, o sea 4k, y llenar con zeros para tener excepciones fault entry */


/* 
	Definición del mapa de memoria
*/
MEMORY
{
	vector_rom		: org = __VECTOR_TABLE_BASE, /* 0x00000000 */   len = 0x10000   /* copiar vector_table */
	public_rom		: org = __PUBLIC_ROM_INIT,   /* 0x70010000 */   len = 0x10000   /* NOTE! <------------------------------- aca arranca qemu */
	public_ram		: org = __PUBLIC_RAM_INIT,   /* 0x70030000 */   len = 0x10000   /* ejecuta secuencia_reset solo en startup */
	public_stack	: org = __PUBLIC_STACK_INIT, /* 0x70020000 */   len = 0x10000   /* zona de pilas segun los modos y tareas */
	microKernel_vma : org = __KERNEL_START_VMA,  /* 0x70040000 */   len = 0x10000   /* copiar kernel durante reset, luego saltar para ejecutarlo */
}
REGION_ALIAS("microKernel_lma", public_rom);

/* 
	Definición de las secciones
*/
SECTIONS
{
	. = __PUBLIC_RAM_INIT; 
/*	.text : 
		{ 
			*(.text*)
		}  >region_vma AT>region_lma 
*/


	._startup_out : 
		{ 
			__STARTUP_START_VMA = . ;
				*(._startup)
			__STARTUP_END_VMA = . ;
		} >public_rom AT>public_rom /*>region_vma*/ /*AT>region_lma*/ 


	/*	especifico VMA (donde se va a ejecutar) <> que LMA donde debe estar grabado o pegado por el programador usando funcion memcpy */

	.vector_table_out : 
		{
			__VECTOR_TABLE_START_VMA = . ;
				*(.vector_table)
			__VECTOR_TABLE_END_VMA = . ; 
		} >vector_rom AT>public_rom

	__VECTOR_TABLE_SIZE = SIZEOF(.vector_table_out) ;
	__VECTOR_TABLE_START_LMA = LOADADDR(.vector_table_out) ;

	/* seccion con inicializaciones */

	.reset_out :
		{
			__RESET_START_VMA = . ;
				*(.reset)
				*(.memory_func)
				*(.gic_init)
				*(.timer_init)
			__RESET_END_VMA = . ;
		} >public_ram AT>public_rom

	__RESET_SIZE = SIZEOF(.reset_out) ;
	__RESET_START_LMA = LOADADDR(.reset_out) ;


	.kernel_out :
		{ 
		. = ALIGN(4);
			/*__KERNEL_START_VMA = . ;*/ /* aqui hubiera estado el star vma por el location counter, pero definimos el simbolo antes manualmente */
			__HANDLERS_START_VMA = . ;
				*(.exception_handlers*)
			__HANDLERS_END_VMA = . ;
		. = ALIGN(4);
				*(.kernel_1)
				*(.kernel*)
			__KERNEL_END_VMA = . ;
		} >microKernel_vma AT>microKernel_lma /*>region_vma*/ /*AT>region_lma*/ 
		
	__KERNEL_SIZE = SIZEOF(.kernel_out) ;
	__KERNEL_START_LMA = LOADADDR(.kernel_out) ;
		

	.data_out : 
		{ 
		. = ALIGN(4);
			__data_start__ = .;
				*(.data*) 
			__data_end__ = .;
		} >public_ram AT>public_ram
		
	__DATA_SIZE = SIZEOF(.data_out) ;
	__DATA_START_LMA = LOADADDR(.data_out) ;


	.bss_out : 
		{
		. = ALIGN(4);
			__bss_start__ = .;
				*(.bss*)
			__bss_end__ = .;
		} >public_ram
		
	__BSS_SIZE = SIZEOF(.bss_out) ;
	__BSS_START_LMA = LOADADDR(.bss_out) ;

	/* .pila_out : 
		{
			. = ALIGN(4);
			__PILA_START = .;
			*(.pila*)
			__PILA_END = .;
		} >public_stack */


	.stacks_out :
	{
	. = ALIGN(4);
		
		__ARM_STACKS_START_VMA = .;

		__SYS_STACK_START = .;
		. += __SYS_STACK_SIZE;
		__SYS_STACK_END = .;
		. += __GAP_SIZE;

		__IRQ_STACK_START = .;
		. += __IRQ_STACK_SIZE;
		__IRQ_STACK_END = .;
		. += __GAP_SIZE;

		__FIQ_STACK_START = .;
		. += __FIQ_STACK_SIZE;
		__FIQ_STACK_END = .;
		. += __GAP_SIZE;

		__SVC_STACK_START = .;
		. += __SVC_STACK_SIZE;
		__SVC_STACK_END = .;
		. += __GAP_SIZE;

		__ABT_STACK_START = .;
		. += __ABT_STACK_SIZE;
		__ABT_STACK_END = .;
		. += __GAP_SIZE;

		__UND_STACK_START = .;
		. += __UND_STACK_SIZE;
		__UND_STACK_END = .;
		. += __GAP_SIZE;

		__ARM_STACKS_END_VMA = .;

	} >public_stack

	__ARM_STACKS_SIZE = SIZEOF(.stacks_out) ;
	__ARM_STACKS_START_LMA = LOADADDR(.stacks_out) ;

}