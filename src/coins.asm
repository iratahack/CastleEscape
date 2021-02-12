        extern  _screenTab
        extern  _tile0
        extern  addBCD
        extern  _displayScore
        extern  score
        extern  AFXPLAY
        extern  removeItem

        public  _animateCoins
        public  _coinTables
        public  coins
        public  currentCoinTable
        public  coinCollision

        include "defs.inc"

        section code_user

        ;
        ; Animate the visible coins on the current level.
        ;
_animateCoins:
        di      
        ld      (coinTableEnd+1), sp
        ld      de, (currentCoinTable)
nextCoin:
        ld      a, (de)                 ; Coin flags
        cp      0xff                    ; Check for end of coin table
        jp      z, coinTableEnd         ; done if true.
        or      a                       ; Is the coin visible?
        jp      z, notVisible

        inc     de

        ld      a, (de)                 ; Get x screen position
        rrca    
        rrca    
        rrca    
        and     %00011111
        ld      c, a                    ; Save for later
        inc     de

        ld      a, (de)                 ; Get y screen position
        ld      l, a
        ld      h, 0
        inc     de
        ld      a, c                    ; Restore x screen position

        hlx     2
        ld      sp, _screenTab
        add     hl, sp
        ld      sp, hl
        pop     bc                      ; Pop y screen address
        add     c
        ld      c, a

        ; Calculate the tile address using the animation index
        ld      a, (de)                 ; Animation index
        inc     a
        ld      (de), a
        inc     de
        and     0x03                    ; Only 4 animations 0-3
        add     ID_COIN                 ; Index of first animation

        ld      l, a
        ld      h, 0
        hlx     8
        ld      sp, _tile0
        add     hl, sp

        ld      sp, hl
        ld      hl, bc

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl), c                 ; 7
        inc     h                       ; Add 256 to screen address 4
        ld      (hl), b                 ; 7
        inc     h                       ; Add 256 to screen address 4

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of tile data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b

        jp      nextCoin
coinTableEnd:
        ld      sp, 0x0000
        ei      
        ret     

notVisible:
        ld      a, SIZEOF_item
        addde   
        jp      nextCoin

        ;
        ; Add 5 to the score and display it
        ;
coinCollision:
        call    removeItem              ; Remove the item from the screen

        ld      l, 0x05
        ld      de, score
        call    addBCD
        call    _displayScore
        ld      a, AYFX_COLLECT_COIN
        call    AFXPLAY
        ret     

        section bss_user

currentCoinTable:
        dw      0

_coinTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

coins:
        ds      SIZEOF_item*MAX_COINS*MAX_LEVEL_X*MAX_LEVEL_Y
