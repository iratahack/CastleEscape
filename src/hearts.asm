        extern  addBCD
        extern  display2BCD
        extern  AFXPLAY


        public  heartCount
        public  currentHeartTable
        public  heartTables
        public  hearts
        public  heartCollision

        include "defs.asm"

        section code_user
        ;
        ; Increment and display the egg count
        ;
heartCollision:
        ld      l, 0x01
        ld      de, heartCount
        call    addBCD
        ld      bc, 0x011d              ; y,x screen location
        ld      hl, heartCount          ; Point to 1000's/100's of score
        call    display2BCD
        ld      a, AYFX_COLLECT_HEART
        call    AFXPLAY
        ret     

        section bss_user
heartCount:                             ; BCD
        dw      0x0000

currentHeartTable:
        dw      0

heartTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*2

hearts:
        ds      SIZEOF_item*8*MAX_LEVEL_X*MAX_LEVEL_Y
