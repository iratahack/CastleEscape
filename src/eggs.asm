        extern  display2BCD
        extern  addBCD
        extern  displayTile
        extern  decBCD
        extern  AFXPLAY

        public  eggTables
        public  eggs
        public  currentEggTable
        public  eggCollision
        public  eggCount
        public  updateEggImage
        public  decrementEggs

        include "defs.asm"

        section code_user
        ;
        ; Increment and display the egg count
        ;
eggCollision:
        ld      l, 0x10
        ld      de, eggCount
        call    addBCD
        ld      bc, 0x011a              ; y,x screen location
        ld      hl, eggCount            ; Point to eggCount
        call    display2BCD
        call    updateEggImage
        ld      a, AYFX_COLLECT_EGG
        call    AFXPLAY
        ret     

updateEggImage:
        ld      a, (eggCount)
        rrca                            ; divide by 2
        and     %00000111
        add     ID_EGG0
        ld      bc, 0x0119
        call    displayTile
        ret     

decrementEggs:
        push    af

        ld      a, (counter)
        and     a
        jr      nz, skip

        ld      a, (eggCount)
        and     a
        jr      z, noEggs

        push    bc
        push    de
        push    hl

        ld      de, eggCount
        call    decBCD
        ld      bc, 0x011a              ; x,y screen location
        ld      hl, eggCount            ; Point to eggCount
        call    display2BCD
        call    updateEggImage

        pop     hl
        pop     de
        pop     bc

noEggs:
        ld      a, 100
skip:
        dec     a
        ld      (counter), a
        pop     af
        ret     

        section bss_user
counter:
        db      0
eggCount:                               ; BCD
        dw      0x0000

currentEggTable:
        dw      0

eggTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*2

eggs:
        ds      SIZEOF_item*8*MAX_LEVEL_X*MAX_LEVEL_Y
