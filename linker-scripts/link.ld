OUTPUT_ARCH( "riscv" )

ENTRY( reset_vector )

MEMORY
{
  NVRAM (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 0x200000
  HTIF (wxa!ri) : ORIGIN = 0x80200000, LENGTH = 0x10
  I2CADDR (wxa!ri) : ORIGIN = 0x80200010, LENGTH = 0x04 
  I2CDATA (wxa!ri) : ORIGIN = 0x80200014, LENGTH = 0x04 
  I2CSTATUS (wxa!ri) : ORIGIN = 0x80200018, LENGTH = 0x04 
}

PHDRS
{
  image PT_LOAD;
  mmio PT_LOAD;
}

SECTIONS
{
  .text   : { *(.text.init) *(.text .text.*) }      >NVRAM : image
  .rodata : { 
  	*(.rodata .rodata.*) 
    __end_rodata = .;
  } > NVRAM : image
  .data   : {
  	__start_data = .;
  	*(.sdata .sdata.*) 
  	*(.data .data.*)
  	__end_data = .;
  } > NVRAM : image
  .persistent     : {
    *(.persistent)
    *(.nv_vars)
  } > NVRAM : image
  .bss    : { *(.sbss .sbss.*) *(.bss .bss.*) }     >NVRAM : image
  .htif   : { . = ALIGN(1024); *(.htif) }           >HTIF : mmio
  .i2c_addr_vec   : { KEEP(*(.i2c_addr_vec)) }      >I2CADDR : mmio
  .i2c_data_vec   : { KEEP(*(.i2c_data_vec)) }      >I2CDATA : mmio
  .i2c_status_vec : { KEEP(*(.i2c_status_vec)) }    >I2CSTATUS : mmio
}
