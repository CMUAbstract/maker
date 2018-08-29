OUTPUT_ARCH( "riscv" )

ENTRY( reset_vector )

MEMORY
{
  NVRAM (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 0x40000
  RAM   (wxa!ri) : ORIGIN = 0x80040000, LENGTH = 0x10000
}

PHDRS
{
  data PT_LOAD;
}

SECTIONS
{
  .text   : { *(.text.init) *(.text .text.*) }      >NVRAM
  .rodata : { 
  	*(.rodata .rodata.*) 
  	__end_rodata = .;
  } > NVRAM
  .data   : {
  	__start_data = .;
  	*(.sdata .sdata.*) 
  	*(.data .data.*)
  	__end_data = .;
  } >RAM AT > NVRAM : data
  .persistent     : {
    *(.persistent)
    *(.nv_vars)
  } > NVRAM
  .htif   : { . = ALIGN(1024); *(.htif) }           >NVRAM
  .bss    : { *(.sbss .sbss.*) *(.bss .bss.*) }     >RAM
}
