OUTPUT_ARCH( "riscv" )

ENTRY( reset_vector )

MEMORY
{
  NVRAM (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 0x200000
  MEMIO (wxa!ri) : ORIGIN = 0x80200000, LENGTH = 0x400
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
  } > NVRAM : data
  .persistent     : {
    *(.persistent)
    *(.nv_vars)
  } > NVRAM
  .bss    : { *(.sbss .sbss.*) *(.bss .bss.*) }     >NVRAM
  .htif   : { . = ALIGN(1024); *(.htif) }           >MEMIO
}
