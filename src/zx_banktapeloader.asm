        extern  __BANK_0_head
        extern  __BANK_1_head
        extern  __BANK_2_head
        extern  __BANK_3_head
        extern  __BANK_4_head
        extern  __BANK_5_head
        extern  __BANK_6_head
        extern  __BANK_7_head
        extern  __BANK_0_tail
        extern  __BANK_1_tail
        extern  __BANK_2_tail
        extern  __BANK_3_tail
        extern  __BANK_4_tail
        extern  __BANK_5_tail
        extern  __BANK_6_tail
        extern  __BANK_7_tail

        section code_crt_init
        call    _bankedtapeloader

        section code_driver

IF  1
        defc    SV_BANKM=currentBank
ELSE    
        include "target/zx/def/sysvar.def"
ENDIF   
        include "defs.inc"

        public  _bankedtapeloader
_bankedtapeloader:
        pushall 
        ld      ix, __BANK_0_head
        ld      de, __BANK_0_tail-__BANK_0_head
        ld      c, MEM_BANK_ROM|0x0     ; Bank 0
        call    load_block
        ret     c
        ld      ix, __BANK_1_head
        ld      de, __BANK_1_tail-__BANK_1_head
        ld      c, MEM_BANK_ROM|0x1     ;Bank 1
        call    load_block
        ret     c
        ld      ix, __BANK_2_head
        ld      de, __BANK_2_tail-__BANK_2_head
        ld      c, MEM_BANK_ROM|0x2     ;Bank 2
        call    load_block
        ret     c
        ld      ix, __BANK_3_head
        ld      de, __BANK_3_tail-__BANK_3_head
        ld      c, MEM_BANK_ROM|0x3     ;Bank 3
        call    load_block
        ret     c
        ld      ix, __BANK_4_head
        ld      de, __BANK_4_tail-__BANK_4_head
        ld      c, MEM_BANK_ROM|0x4     ;Bank 4
        call    load_block
        ret     c
        ld      ix, __BANK_5_head
        ld      de, __BANK_5_tail-__BANK_5_head
        ld      c, MEM_BANK_ROM|0x5     ;Bank 5
        call    load_block
        ret     c
        ld      ix, __BANK_6_head
        ld      de, __BANK_6_tail-__BANK_6_head
        ld      c, MEM_BANK_ROM|0x6     ;Bank 6
        call    load_block
        ret     c
        ld      ix, __BANK_7_head
        ld      de, __BANK_7_tail-__BANK_7_head
        ld      c, MEM_BANK_ROM|0x7     ;Bank 7
        call    load_block
        di      
        ld      a, MEM_BANK_ROM
        ld      (SV_BANKM), a
        ld      bc, IO_BANK
        out     (c), a
        ei      
        popall  
        ret     

load_block:
        ld      a, d
        or      e
        ret     z                       ;Nothing to load
        ld      a, c
        di      
        ld      (SV_BANKM), a
        ld      bc, IO_BANK
        out     (c), a
        ei      
        ld      a, 255                  ;Data block
        scf                             ;Load
        call    0x556                   ; call the tape loader in ROM
        and     a
        ret     

