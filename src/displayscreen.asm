        extern  _screenTab
        extern  _tile0
        extern  _lanternList
        extern  displayTile
        extern  setTileAttr
        extern  _tileAttr

        public  _displayScreen

        include "defs.inc"

        section code_user
        ;
        ; Display a complete tile map
        ;
        ; On entry hl points to the tilemap to be displayed.
        ;
_displayScreen:
        ; Save the registers and setup ix to point to variable space
        pushall 

        ;
        ; Build a stack frame for our variables
        ;
        ld      (tempSP), sp
        ld      ix, -SIZEOF_vars
        add     ix, sp
        ld      sp, ix

        ld      de, _lanternList
        xor     a
        ld      (de), a                 ; Zero the lantern count
        inc     de
        ld      (lanternPtr), de        ; Initialize table pointer

        ld      (ix+yPos), 3            ; Starting y position of level

        ld      b, LEVEL_HEIGHT
yloop:
        push    bc

        ; Zero out the X character location
        ld      (ix+xPos), 0

        ld      b, SCREEN_WIDTH
xloop:
        ld      a, (hl)                 ; read the tile index
        cmp     ID_BLANK                ; Check for blank
        jr      z, nextTile             ; On to the next tile

        ;
        ; Don't display collectible items.
        ;
        cmp     ID_COIN
        jr      z, nextTile
        cmp     ID_EGG
        jr      z, nextTile
        cmp     ID_HEART
        jr      z, nextTile
        cmp     ID_SPIDER
        jr      z, nextTile

        ;
        ; Check for lanterns
        ;
        cmp     ID_LANTERN
        call    z, addLantern

        push    bc
        ld      b, (ix+yPos)
        ld      c, (ix+xPos)
        call    displayTile
        call    setTileAttr
        pop     bc

nextTile:
        inc     hl                      ; next tile

        ; next x location
        inc     (ix+xPos)

        djnz    xloop

        ld      de, TILEMAP_WIDTH-SCREEN_WIDTH
        add     hl, de

        ; next y location
        inc     (ix+yPos)

        pop     bc
        dec     b
        jp      nz, yloop

tempSP  equ     $+1
        ld      sp, 0x0000
        popall  
        ret     

        ;
        ; Add a lantern to the lantern list
        ; On entry:
        ;			a - Sprite ID of lantern
        ;
addLantern:
        push    af
        push    de
        push    hl

        ; Increment the lantern count
        ld      hl, _lanternList
        inc     (hl)

        ; Calculate the screen attribute address
        ld      l, (ix+yPos)
        ld      h, 0
        hlx     32
        ld      a, (ix+xPos)
        add     l
        ld      l, a
        ld      de, SCREEN_ATTR_START
        add     hl, de

lanternPtr  equ $+1
        ld      (0x0000), hl            ; Self modifying code
        ld      hl, lanternPtr
        inc     (hl)
        inc     (hl)

        pop     hl
        pop     de
        pop     af
        ret     

        defvars 0
        {       
            xPos        ds.b 1
            yPos        ds.b 1
        SIZEOF_vars 
        }       
