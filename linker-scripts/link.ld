OUTPUT_ARCH( "riscv" )

ENTRY( reset_vector )

MEMORY
{
  NVRAM (wxa!ri)                  : ORIGIN = 0x80000000, LENGTH = 0x10000
  HTIF (rw)                       : ORIGIN = 0x80200000, LENGTH = 0x10

  I2C_ADDR (rw)                   : ORIGIN = 0x80200010, LENGTH = 0x04 
  I2C_DATA (rw)                   : ORIGIN = 0x80200014, LENGTH = 0x04 
  I2C_STATUS (rw)                 : ORIGIN = 0x80200018, LENGTH = 0x04

  PIN1_STATUS (rw)                : ORIGIN = 0x8020001C, LENGTH = 0x04
  PIN2_STATUS (rw)                : ORIGIN = 0x80200020, LENGTH = 0x04
  PIN3_STATUS (rw)                : ORIGIN = 0x80200024, LENGTH = 0x04
  PIN4_STATUS (rw)                : ORIGIN = 0x80200028, LENGTH = 0x04
  
  INFO_CONFIG (r)                 : ORIGIN = 0x8020002C, LENGTH = 0x04 
  
  STAT_CYCLE (r)                  : ORIGIN = 0x80200030, LENGTH = 0x04
  STAT_CYCLE_OVERFLOW (r)         : ORIGIN = 0x80200034, LENGTH = 0x04
  STAT_INSN (r)                   : ORIGIN = 0x80200038, LENGTH = 0x04 
  STAT_INSN_OVERFLOW (r)          : ORIGIN = 0x8020003C, LENGTH = 0x04 
  STAT_I_MISS (r)                 : ORIGIN = 0x80200040, LENGTH = 0x04 
  STAT_I_MISS_OVERFLOW (r)        : ORIGIN = 0x80200044, LENGTH = 0x04 
  STAT_I_HIT (r)                  : ORIGIN = 0x80200048, LENGTH = 0x04 
  STAT_I_HIT_OVERFLOW (r)         : ORIGIN = 0x8020004C, LENGTH = 0x04 
  STAT_D_MISS (r)                 : ORIGIN = 0x80200050, LENGTH = 0x04 
  STAT_D_MISS_OVERFLOW (r)        : ORIGIN = 0x80200054, LENGTH = 0x04 
  STAT_D_HIT (r)                  : ORIGIN = 0x80200058, LENGTH = 0x04
  STAT_D_HIT_OVERFLOW (r)         : ORIGIN = 0x8020005C, LENGTH = 0x04
  STAT_MM_READ (r)                : ORIGIN = 0x80200060, LENGTH = 0x04
  STAT_MM_READ_OVERFLOW (r)       : ORIGIN = 0x80200064, LENGTH = 0x04
  STAT_MM_WRITE (r)               : ORIGIN = 0x80200068, LENGTH = 0x04
  STAT_MM_WRITE_OVERFLOW (r)      : ORIGIN = 0x8020006C, LENGTH = 0x04
  STAT_VRF_READ (r)               : ORIGIN = 0x80200070, LENGTH = 0x04
  STAT_VRF_READ_OVERFLOW (r)      : ORIGIN = 0x80200074, LENGTH = 0x04
  STAT_VRF_WRITE (r)              : ORIGIN = 0x80200078, LENGTH = 0x04
  STAT_VRF_WRITE_OVERFLOW (r)     : ORIGIN = 0x8020007C, LENGTH = 0x04

  SMV_VECTOR_ADDR (rw)            : ORIGIN = 0x80200080, LENGTH = 0x04 
  SMV_VECTOR_LEN (rw)             : ORIGIN = 0x80200084, LENGTH = 0x04 
  SMV_ROW_ADDR (rw)               : ORIGIN = 0x80200088, LENGTH = 0x04 
  SMV_ROW_LEN (rw)                : ORIGIN = 0x8020008C, LENGTH = 0x04 
  SMV_COL_ADDR (rw)               : ORIGIN = 0x80200090, LENGTH = 0x04 
  SMV_COL_LEN (rw)                : ORIGIN = 0x80200094, LENGTH = 0x04 
  SMV_MAT_ADDR (rw)               : ORIGIN = 0x80200098, LENGTH = 0x04 
  SMV_DEST_ADDR (rw)              : ORIGIN = 0x8020009C, LENGTH = 0x04 
  SMV_STATUS (rw)                 : ORIGIN = 0x80200100, LENGTH = 0x04
  
  DCONV_SRC_ADDR (rw)             : ORIGIN = 0x80200104, LENGTH = 0x04 
  DCONV_SRC_ROWS (rw)             : ORIGIN = 0x80200108, LENGTH = 0x04 
  DCONV_SRC_COLS (rw)             : ORIGIN = 0x8020010C, LENGTH = 0x04 
  DCONV_FILTER_ADDR (rw)          : ORIGIN = 0x80200110, LENGTH = 0x04 
  DCONV_FILTER_ROWS (rw)          : ORIGIN = 0x80200114, LENGTH = 0x04 
  DCONV_FILTER_COLS (rw)          : ORIGIN = 0x80200118, LENGTH = 0x04 
  DCONV_DEST_ADDR (rw)            : ORIGIN = 0x8020011C, LENGTH = 0x04 
  DCONV_STATUS (rw)               : ORIGIN = 0x80200120, LENGTH = 0x04
  
  SORT_SRC_ADDR (rw)              : ORIGIN = 0x80200124, LENGTH = 0x04
  SORT_SRC_LEN (rw)               : ORIGIN = 0x80200128, LENGTH = 0x04
  SORT_DEST_ADDR (rw)             : ORIGIN = 0x8020012C, LENGTH = 0x04
  SORT_STATUS (rw)                : ORIGIN = 0x80200130, LENGTH = 0x04
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

  .i2c_addr        : { KEEP(*(.i2c_addr)) }     >I2C_ADDR : mmio
  .i2c_data        : { KEEP(*(.i2c_data)) }     >I2C_DATA : mmio
  .i2c_status      : { KEEP(*(.i2c_status)) }   >I2C_STATUS : mmio
  
  .pin1_status     : { KEEP(*(.pin1_status)) }  >PIN1_STATUS : mmio
  .pin2_status     : { KEEP(*(.pin2_status)) }  >PIN2_STATUS : mmio
  .pin3_status     : { KEEP(*(.pin3_status)) }  >PIN2_STATUS : mmio
  .pin4_status     : { KEEP(*(.pin4_status)) }  >PIN2_STATUS : mmio

  .info_config              : { KEEP(*(.info_config)) }     >INFO_CONFIG : mmio
  
  .stat_insn                : { KEEP(*(.stat_insn)) }       >STAT_INSN : mmio
  .stat_insn_overflow       : { KEEP(*(.stat_insn_overflow)) }
    >STAT_INSN_OVERFLOW : mmio
  .stat_cycle               : { KEEP(*(.stat_cycle)) }      >STAT_CYCLE : mmio
  .stat_cycle_overflow      : { KEEP(*(.stat_cycle_overflow)) }
    >STAT_CYCLE_OVERFLOW : mmio
  .stat_i_miss              : { KEEP(*(.stat_i_miss)) }     >STAT_I_MISS : mmio
  .stat_i_miss_overflow     : { KEEP(*(.stat_i_miss_overflow)) }
    >STAT_I_MISS_OVERFLOW : mmio
  .stat_i_hit               : { KEEP(*(.stat_i_hit)) }      >STAT_I_HIT : mmio
  .stat_i_hit_overflow      : { KEEP(*(.stat_i_hit_overflow)) }
    >STAT_I_HIT_OVERFLOW : mmio
  .stat_d_miss              : { KEEP(*(.stat_d_miss)) }     >STAT_D_MISS : mmio
  .stat_d_miss_overflow     : { KEEP(*(.stat_d_miss_overflow)) }
    >STAT_D_MISS_OVERFLOW : mmio
  .stat_d_hit               : { KEEP(*(.stat_d_hit)) }      >STAT_D_HIT : mmio
  .stat_d_hit_overflow      : { KEEP(*(.stat_d_hit_overflow)) }
    >STAT_D_HIT_OVERFLOW : mmio
  .stat_mm_read             : { KEEP(*(.stat_mm_read)) }    >STAT_MM_READ : mmio
  .stat_mm_read_overflow    : { KEEP(*(.stat_mm_read_overflow)) }    
    >STAT_MM_READ_OVERFLOW : mmio
  .stat_mm_write            : { KEEP(*(.stat_mm_write)) }   >STAT_MM_WRITE : mmio
  .stat_mm_write_overflow   : { KEEP(*(.stat_mm_write_overflow)) }    
    >STAT_MM_WRITE_OVERFLOW : mmio
  .stat_vrf_read            : { KEEP(*(.stat_vrf_read)) }   >STAT_VRF_READ : mmio
  .stat_vrf_read_overflow   : { KEEP(*(.stat_vrf_read_overflow)) }
    >STAT_VRF_READ_OVERFLOW : mmio
  .stat_vrf_write           : { KEEP(*(.stat_vrf_write)) }
    >STAT_VRF_WRITE : mmio
  .stat_vrf_write_overflow  : { KEEP(*(.stat_vrf_write_overflow)) }
    >STAT_VRF_WRITE_OVERFLOW : mmio
  
  .smv_vector_addr : { KEEP(*(.smv_vector_addr)) }  >SMV_VECTOR_ADDR : mmio
  .smv_vector_len  : { KEEP(*(.smv_vector_len)) }   >SMV_VECTOR_LEN : mmio
  .smv_row_addr    : { KEEP(*(.smv_row_addr)) }     >SMV_ROW_ADDR : mmio
  .smv_row_len     : { KEEP(*(.smv_row_len)) }      >SMV_ROW_LEN : mmio
  .smv_col_addr    : { KEEP(*(.smv_col_addr)) }     >SMV_COL_ADDR : mmio
  .smv_col_len     : { KEEP(*(.smv_col_len)) }      >SMV_COL_LEN : mmio
  .smv_mat_addr    : { KEEP(*(.smv_mat_addr)) }     >SMV_MAT_ADDR : mmio
  .smv_dest_addr   : { KEEP(*(.smv_dest_addr)) }    >SMV_DEST_ADDR : mmio
  .smv_status      : { KEEP(*(.smv_status)) }       >SMV_STATUS : mmio
  
  .dconv_src_addr    : { KEEP(*(.dconv_src_addr)) }    >DCONV_SRC_ADDR : mmio
  .dconv_src_rows    : { KEEP(*(.dconv_src_rows)) }    >DCONV_SRC_ROWS : mmio
  .dconv_src_cols    : { KEEP(*(.dconv_src_cols)) }    >DCONV_SRC_COLS : mmio
  .dconv_filter_addr : { KEEP(*(.dconv_filter_addr)) } >DCONV_FILTER_ADDR : mmio
  .dconv_filter_rows : { KEEP(*(.dconv_filter_rows)) } >DCONV_FILTER_ROWS : mmio
  .dconv_filter_cols : { KEEP(*(.dconv_filter_cols)) } >DCONV_FILTER_COLS : mmio
  .dconv_dest_addr   : { KEEP(*(.dconv_dest_addr)) }   >DCONV_DEST_ADDR : mmio
  .dconv_status      : { KEEP(*(.dconv_status)) }      >DCONV_STATUS : mmio
  
  .sort_src_addr   : { KEEP(*(.sort_src_addr)) }    >SORT_SRC_ADDR : mmio
  .sort_src_len    : { KEEP(*(.sort_src_len)) }     >SORT_SRC_LEN : mmio
  .sort_dest_addr  : { KEEP(*(.sort_dest_addr)) }   >SORT_DEST_ADDR : mmio
  .sort_status     : { KEEP(*(.sort_status)) }      >SORT_STATUS : mmio
}
