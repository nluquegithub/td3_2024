/* 
    Definiciones necesarias: formato de salida, arquitectura y punto de entrada
*/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)


/* 
    Definiciones de simbolos necesarios
*/
_PUBLIC_ROM_INIT = 0x00000000;
_PUBLIC_RAM_INIT = 0x70010000;
_PUBLIC_STACK_INIT = 0x70020000;
__PILA_SIZE = 16*1024;
__BSS_SIZE = 4 ;


/* 
    Definición del mapa de memoria
*/
MEMORY
{
    public_rom	: org = _PUBLIC_ROM_INIT, len = 0x1000
    public_ram	: org = _PUBLIC_RAM_INIT, len = 0x1000
    public_stack : org = _PUBLIC_STACK_INIT, len = __PILA_SIZE
    microKernel_vma : org = __KERNEL_VMA, len = 0x1000
}
REGION_ALIAS("microKernel_lma", public_ram);

/* 
    Definición de las secciones
*/
SECTIONS
{
    . = _PUBLIC_RAM_INIT; 
/*    .text : 
        { 
            *(.text*)
        }
*/

    .memcpy_out : 
        { 
            *(.memcpy_asm)
        } 


    /*	especifico VMA (donde se va a ejecutar) <> que LMA donde debe estar grabado o pegado por el programador usando funcion memcpy */
    .kernel_out :
        { 
            __KERNEL_VMA = . ;
            *(.kernel*)
        } AT> microKernel_lma /*region_lma*/ > microKernel_vma /*region_vma*/
    
	__KERNEL_SIZE = SIZEOF(.kernel_out) ;
    __KERNEL_LMA = LOADADDR(.kernel_out) ;
    
    .data : 
        { 
            *(.data*) 
        } AT> public_ram > public_ram /* #TODO cuando usemos la memoria ROM tengo que modificar la LMA  */

    .bss : 
        {
            . = ALIGN(4);
            __bss_start__ = .;
            *(.bss*)
            __bss_end__ = .;
        } > public_ram
    

    .pila_out : 
        {
            . = ALIGN(4);
            __PILA_START = .;
            *(.pila*)
            __PILA_END = .;
        } > public_stack

}