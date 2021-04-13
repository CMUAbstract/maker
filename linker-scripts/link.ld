OUTPUT_ARCH( "riscv" )

ENTRY( reset_vector )

MEMORY
{
  NVRAM (wxa!ri)                  : ORIGIN = 0x80000000, LENGTH = 0x40000
  RAM (wxa!ri)                    : ORIGIN = 0x80040000, LENGTH = 0x10000
  HTIF (rw)                       : ORIGIN = 0x80200000, LENGTH = 0x10

  PROG_STATUS (r)                 : ORIGIN = 0x80200010, LENGTH = 0x4

  I2C_ADDR (rw)                   : ORIGIN = 0x80200014, LENGTH = 0x4
  I2C_DATA (rw)                   : ORIGIN = 0x80200018, LENGTH = 0x4
  I2C_PRER (rw)                   : ORIGIN = 0x8020001c, LENGTH = 0x4
  I2C_STATUS (rw)                 : ORIGIN = 0x80200020, LENGTH = 0x4

  PIN1_STATUS (rw)                : ORIGIN = 0x80200024, LENGTH = 0x4
  PIN2_STATUS (rw)                : ORIGIN = 0x80200028, LENGTH = 0x4
  PIN3_STATUS (rw)                : ORIGIN = 0x8020002c, LENGTH = 0x4
  PIN4_STATUS (rw)                : ORIGIN = 0x80200030, LENGTH = 0x4

  INFO_CONFIG (r)                 : ORIGIN = 0x80200034, LENGTH = 0x4

  STAT_STATUS (rw)                : ORIGIN = 0x80200038, LENGTH = 0x4
  STAT_CYCLE (r)                  : ORIGIN = 0x8020003c, LENGTH = 0x4
  STAT_CYCLE_OVERFLOW (r)         : ORIGIN = 0x80200040, LENGTH = 0x4
  STAT_INSN (r)                   : ORIGIN = 0x80200044, LENGTH = 0x4
  STAT_INSN_OVERFLOW (r)          : ORIGIN = 0x80200048, LENGTH = 0x4
  STAT_I_MISS (r)                 : ORIGIN = 0x8020004c, LENGTH = 0x4
  STAT_I_MISS_OVERFLOW (r)        : ORIGIN = 0x80200050, LENGTH = 0x4
  STAT_I_HIT (r)                  : ORIGIN = 0x80200054, LENGTH = 0x4
  STAT_I_HIT_OVERFLOW (r)         : ORIGIN = 0x80200058, LENGTH = 0x4
  STAT_D_MISS (r)                 : ORIGIN = 0x8020005c, LENGTH = 0x4
  STAT_D_MISS_OVERFLOW (r)        : ORIGIN = 0x80200060, LENGTH = 0x4
  STAT_D_HIT (r)                  : ORIGIN = 0x80200064, LENGTH = 0x4
  STAT_D_HIT_OVERFLOW (r)         : ORIGIN = 0x80200068, LENGTH = 0x4
  STAT_MM_READ (r)                : ORIGIN = 0x8020006c, LENGTH = 0x4
  STAT_MM_READ_OVERFLOW (r)       : ORIGIN = 0x80200070, LENGTH = 0x4
  STAT_MM_WRITE (r)               : ORIGIN = 0x80200074, LENGTH = 0x4
  STAT_MM_WRITE_OVERFLOW (r)      : ORIGIN = 0x80200078, LENGTH = 0x4
  STAT_VRF_READ (r)               : ORIGIN = 0x8020007c, LENGTH = 0x4
  STAT_VRF_WRITE (r)              : ORIGIN = 0x80200080, LENGTH = 0x4
  STAT_HAZARD_INSN (r)            : ORIGIN = 0x80200084, LENGTH = 0x4
  STAT_HAZARD_XDATA (r)           : ORIGIN = 0x80200088, LENGTH = 0x4
  STAT_HAZARD_FRF (r)             : ORIGIN = 0x8020008c, LENGTH = 0x4

  SMV_VECTOR_ADDR (rw)            : ORIGIN = 0x80200090, LENGTH = 0x4
  SMV_VECTOR_LEN (rw)             : ORIGIN = 0x80200094, LENGTH = 0x4
  SMV_ROW_ADDR (rw)               : ORIGIN = 0x80200098, LENGTH = 0x4
  SMV_COL_ADDR (rw)               : ORIGIN = 0x8020009c, LENGTH = 0x4
  SMV_COL_LEN (rw)                : ORIGIN = 0x802000a0, LENGTH = 0x4
  SMV_MAT_ADDR (rw)               : ORIGIN = 0x802000a4, LENGTH = 0x4
  SMV_DEST_ADDR (rw)              : ORIGIN = 0x802000a8, LENGTH = 0x4
  SMV_CLIP (rw)                   : ORIGIN = 0x802000ac, LENGTH = 0x4
  SMV_STATUS (rw)                 : ORIGIN = 0x802000b0, LENGTH = 0x4

  DCONV_SRC_ADDR (rw)             : ORIGIN = 0x802000b4, LENGTH = 0x4
  DCONV_FILTER_ADDR (rw)          : ORIGIN = 0x802000b8, LENGTH = 0x4
  DCONV_FILTER_COUNT (rw)         : ORIGIN = 0x802000bc, LENGTH = 0x4
  DCONV_FILTER_COLS (rw)          : ORIGIN = 0x802000c0, LENGTH = 0x4
  DCONV_DEST_ADDR (rw)            : ORIGIN = 0x802000c4, LENGTH = 0x4
  DCONV_DEST_COUNT (rw)           : ORIGIN = 0x802000c8, LENGTH = 0x4
  DCONV_DEST_COLS (rw)            : ORIGIN = 0x802000cc, LENGTH = 0x4
  DCONV_CLIP (rw)                 : ORIGIN = 0x802000d0, LENGTH = 0x4
  DCONV_STATUS (rw)               : ORIGIN = 0x802000d4, LENGTH = 0x4

  SORT_SRC_ADDR (rw)              : ORIGIN = 0x802000d8, LENGTH = 0x4
  SORT_SRC_LEN (rw)               : ORIGIN = 0x802000dc, LENGTH = 0x4
  SORT_TMP_ADDR (rw)              : ORIGIN = 0x802000e0, LENGTH = 0x4
  SORT_DEST_ADDR (rw)             : ORIGIN = 0x802000e4, LENGTH = 0x4
  SORT_STATUS (rw)                : ORIGIN = 0x802000e8, LENGTH = 0x4

  DMM_ROWS (rw)                   : ORIGIN = 0x802000ec, LENGTH = 0x4
  DMM_COLS (rw)                   : ORIGIN = 0x802000f0, LENGTH = 0x4
  DMM_DCOLS (rw)                  : ORIGIN = 0x802000f4, LENGTH = 0x4
  DMM_CLIP (rw)                   : ORIGIN = 0x802000f8, LENGTH = 0x4
  DMM_SRCA_ADDR (rw)              : ORIGIN = 0x802000fc, LENGTH = 0x4
  DMM_SRCB_ADDR (rw)              : ORIGIN = 0x80200100, LENGTH = 0x4
  DMM_DEST_ADDR (rw)              : ORIGIN = 0x80200104, LENGTH = 0x4
  DMM_STATUS (rw)                 : ORIGIN = 0x80200108, LENGTH = 0x4

  FFT_ROWS (rw)                   : ORIGIN = 0x8020010c, LENGTH = 0x4
  FFT_COLS (rw)                   : ORIGIN = 0x80200110, LENGTH = 0x4
  FFT_CLIP (rw)                   : ORIGIN = 0x80200114, LENGTH = 0x4
  FFT_SRC_REAL_ADDR (rw)          : ORIGIN = 0x80200118, LENGTH = 0x4
  FFT_SRC_IMAG_ADDR (rw)          : ORIGIN = 0x8020011c, LENGTH = 0x4
  FFT_DEST_REAL_ADDR (rw)         : ORIGIN = 0x80200120, LENGTH = 0x4
  FFT_DEST_IMAG_ADDR (rw)         : ORIGIN = 0x80200124, LENGTH = 0x4
  FFT_TWIDDLE_REAL_ADDR (rw)      : ORIGIN = 0x80200128, LENGTH = 0x4
  FFT_TWIDDLE_IMAG_ADDR (rw)      : ORIGIN = 0x8020012c, LENGTH = 0x4
  FFT_STATUS (rw)                 : ORIGIN = 0x80200130, LENGTH = 0x4
}

PHDRS
{
  image PT_LOAD;
  volatile PT_LOAD;
  mmio PT_LOAD;
}

SECTIONS
{
  .text_init : {
    *(.text.init) 
  } > NVRAM : image

  .text     : { 
    __start_text = .; 
    *(.text .text.*) 
    __end_text = .;
  } > NVRAM : image
  
  .rodata   : { 
    __start_rodata = .;
    *(.rodata .rodata.*) 
    __end_rodata = .; 
  } > NVRAM : image
  
  .data     : {
    __start_data = .;
      *(.sdata .sdata.*) 
      *(.data .data.*)
    . = ALIGN(4);
    __end_data = .;
  } > NVRAM : image

  .persistent : { *(.persistent) *(.nv_vars) }            >NVRAM : image
  .stream     : { *(.stream) }                            >NVRAM : image
  .bss        : { *(.sbss .sbss.*) *(.bss .bss.*) }       >NVRAM : image
  .end        : { __nvram_end = .; }                      >NVRAM : image
  
  .volatile   : { 
    __start_volatile = .;
    *(.volatile) 
    __end_volatile = .;
  } > RAM : volatile

  __nvram_origin = ORIGIN(NVRAM);
  __ram_origin = ORIGIN(RAM);

  __nvram_size = LENGTH(NVRAM);
  __ram_size = LENGTH(RAM);

  __free_nvram = ORIGIN(NVRAM) + LENGTH(NVRAM) - __nvram_end; 
  __free_ram = ORIGIN(RAM) + LENGTH(RAM) - __start_volatile;

  .htif   : { . = ALIGN(1024); *(.htif) }                 >HTIF : mmio

  .prog_status            : { KEEP(*(.prog_status)) }             >PROG_STATUS : mmio

  .i2c_addr               : { KEEP(*(.i2c_addr)) }                >I2C_ADDR : mmio
  .i2c_data               : { KEEP(*(.i2c_data)) }                >I2C_DATA : mmio
  .i2c_prer               : { KEEP(*(.i2c_prer)) }                >I2C_PRER : mmio
  .i2c_status             : { KEEP(*(.i2c_status)) }              >I2C_STATUS : mmio

  .pin1_status            : { KEEP(*(.pin1_status)) }             >PIN1_STATUS : mmio
  .pin2_status            : { KEEP(*(.pin2_status)) }             >PIN2_STATUS : mmio
  .pin3_status            : { KEEP(*(.pin3_status)) }             >PIN3_STATUS : mmio
  .pin4_status            : { KEEP(*(.pin4_status)) }             >PIN4_STATUS : mmio

  .info_config            : { KEEP(*(.info_config)) }             >INFO_CONFIG : mmio

  .stat_status            : { KEEP(*(.stat_status)) }             >STAT_STATUS : mmio
  .stat_cycle             : { KEEP(*(.stat_cycle)) }              >STAT_CYCLE : mmio
  .stat_cycle_overflow    : { KEEP(*(.stat_cycle_overflow)) }     >STAT_CYCLE_OVERFLOW : mmio
  .stat_insn              : { KEEP(*(.stat_insn)) }               >STAT_INSN : mmio
  .stat_insn_overflow     : { KEEP(*(.stat_insn_overflow)) }      >STAT_INSN_OVERFLOW : mmio
  .stat_i_miss            : { KEEP(*(.stat_i_miss)) }             >STAT_I_MISS : mmio
  .stat_i_miss_overflow   : { KEEP(*(.stat_i_miss_overflow)) }    >STAT_I_MISS_OVERFLOW : mmio
  .stat_i_hit             : { KEEP(*(.stat_i_hit)) }              >STAT_I_HIT : mmio
  .stat_i_hit_overflow    : { KEEP(*(.stat_i_hit_overflow)) }     >STAT_I_HIT_OVERFLOW : mmio
  .stat_d_miss            : { KEEP(*(.stat_d_miss)) }             >STAT_D_MISS : mmio
  .stat_d_miss_overflow   : { KEEP(*(.stat_d_miss_overflow)) }    >STAT_D_MISS_OVERFLOW : mmio
  .stat_d_hit             : { KEEP(*(.stat_d_hit)) }              >STAT_D_HIT : mmio
  .stat_d_hit_overflow    : { KEEP(*(.stat_d_hit_overflow)) }     >STAT_D_HIT_OVERFLOW : mmio
  .stat_mm_read           : { KEEP(*(.stat_mm_read)) }            >STAT_MM_READ : mmio
  .stat_mm_read_overflow  : { KEEP(*(.stat_mm_read_overflow)) }   >STAT_MM_READ_OVERFLOW : mmio
  .stat_mm_write          : { KEEP(*(.stat_mm_write)) }           >STAT_MM_WRITE : mmio
  .stat_mm_write_overflow : { KEEP(*(.stat_mm_write_overflow)) }  >STAT_MM_WRITE_OVERFLOW : mmio
  .stat_vrf_read          : { KEEP(*(.stat_vrf_read)) }           >STAT_VRF_READ : mmio
  .stat_vrf_write         : { KEEP(*(.stat_vrf_write)) }          >STAT_VRF_WRITE : mmio
  .stat_hazard_insn       : { KEEP(*(.stat_hazard_insn)) }        >STAT_HAZARD_INSN : mmio
  .stat_hazard_xdata      : { KEEP(*(.stat_hazard_xdata)) }       >STAT_HAZARD_XDATA : mmio
  .stat_hazard_frf        : { KEEP(*(.stat_hazard_frf)) }         >STAT_HAZARD_FRF : mmio

  .smv_vector_addr        : { KEEP(*(.smv_vector_addr)) }         >SMV_VECTOR_ADDR : mmio
  .smv_vector_len         : { KEEP(*(.smv_vector_len)) }          >SMV_VECTOR_LEN : mmio
  .smv_row_addr           : { KEEP(*(.smv_row_addr)) }            >SMV_ROW_ADDR : mmio
  .smv_col_addr           : { KEEP(*(.smv_col_addr)) }            >SMV_COL_ADDR : mmio
  .smv_col_len            : { KEEP(*(.smv_col_len)) }             >SMV_COL_LEN : mmio
  .smv_mat_addr           : { KEEP(*(.smv_mat_addr)) }            >SMV_MAT_ADDR : mmio
  .smv_dest_addr          : { KEEP(*(.smv_dest_addr)) }           >SMV_DEST_ADDR : mmio
  .smv_clip               : { KEEP(*(.smv_clip)) }                >SMV_CLIP : mmio
  .smv_status             : { KEEP(*(.smv_status)) }              >SMV_STATUS : mmio

  .dconv_src_addr         : { KEEP(*(.dconv_src_addr)) }          >DCONV_SRC_ADDR : mmio
  .dconv_filter_addr      : { KEEP(*(.dconv_filter_addr)) }       >DCONV_FILTER_ADDR : mmio
  .dconv_filter_count     : { KEEP(*(.dconv_filter_count)) }      >DCONV_FILTER_COUNT : mmio
  .dconv_filter_cols      : { KEEP(*(.dconv_filter_cols)) }       >DCONV_FILTER_COLS : mmio
  .dconv_dest_addr        : { KEEP(*(.dconv_dest_addr)) }         >DCONV_DEST_ADDR : mmio
  .dconv_dest_count       : { KEEP(*(.dconv_dest_count)) }        >DCONV_DEST_COUNT : mmio
  .dconv_dest_cols        : { KEEP(*(.dconv_dest_cols)) }         >DCONV_DEST_COLS : mmio
  .dconv_clip             : { KEEP(*(.dconv_clip)) }              >DCONV_CLIP : mmio
  .dconv_status           : { KEEP(*(.dconv_status)) }            >DCONV_STATUS : mmio

  .sort_src_addr          : { KEEP(*(.sort_src_addr)) }           >SORT_SRC_ADDR : mmio
  .sort_src_len           : { KEEP(*(.sort_src_len)) }            >SORT_SRC_LEN : mmio
  .sort_tmp_addr          : { KEEP(*(.sort_tmp_addr)) }           >SORT_TMP_ADDR : mmio
  .sort_dest_addr         : { KEEP(*(.sort_dest_addr)) }          >SORT_DEST_ADDR : mmio
  .sort_status            : { KEEP(*(.sort_status)) }             >SORT_STATUS : mmio

  .dmm_rows               : { KEEP(*(.dmm_rows)) }                >DMM_ROWS : mmio
  .dmm_cols               : { KEEP(*(.dmm_cols)) }                >DMM_COLS : mmio
  .dmm_dcols              : { KEEP(*(.dmm_dcols)) }               >DMM_DCOLS : mmio
  .dmm_clip               : { KEEP(*(.dmm_clip)) }                >DMM_CLIP : mmio
  .dmm_srca_addr          : { KEEP(*(.dmm_srca_addr)) }           >DMM_SRCA_ADDR : mmio
  .dmm_srcb_addr          : { KEEP(*(.dmm_srcb_addr)) }           >DMM_SRCB_ADDR : mmio
  .dmm_dest_addr          : { KEEP(*(.dmm_dest_addr)) }           >DMM_DEST_ADDR : mmio
  .dmm_status             : { KEEP(*(.dmm_status)) }              >DMM_STATUS : mmio

  .fft_rows               : { KEEP(*(.fft_rows)) }                >FFT_ROWS : mmio
  .fft_cols               : { KEEP(*(.fft_cols)) }                >FFT_COLS : mmio
  .fft_clip               : { KEEP(*(.fft_clip)) }                >FFT_CLIP : mmio
  .fft_src_real_addr      : { KEEP(*(.fft_src_real_addr)) }       >FFT_SRC_REAL_ADDR : mmio
  .fft_src_imag_addr      : { KEEP(*(.fft_src_imag_addr)) }       >FFT_SRC_IMAG_ADDR : mmio
  .fft_dest_real_addr     : { KEEP(*(.fft_dest_real_addr)) }      >FFT_DEST_REAL_ADDR : mmio
  .fft_dest_imag_addr     : { KEEP(*(.fft_dest_imag_addr)) }      >FFT_DEST_IMAG_ADDR : mmio
  .fft_twiddle_real_addr  : { KEEP(*(.fft_twiddle_real_addr)) }   >FFT_TWIDDLE_REAL_ADDR : mmio
  .fft_twiddle_imag_addr  : { KEEP(*(.fft_twiddle_imag_addr)) }   >FFT_TWIDDLE_IMAG_ADDR : mmio
  .fft_status             : { KEEP(*(.fft_status)) }              >FFT_STATUS : mmio
}
