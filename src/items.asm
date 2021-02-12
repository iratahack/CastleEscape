        extern  _yPos
        extern  _xPos
        extern  _levels
        extern  _tileAttr
        extern  _tileMapX
        extern  _screenTab
        extern  _tile0
        extern  setAttr
        extern  clearAttr
        extern  clearChar

        public  _initItems
        public  displayItemAttr
        public  setCurrentItemTable
        public  displayItems
        public  checkItemCollision
        public  displayTile
        public  setTileAttr

        include "defs.asm"

        defc    ITEM_WIDTH=0x08
        defc    ITEM_HEIGHT=0x08

        section code_user
        ;
        ; Entry:
        ;		hl - Pointer to the item table
        ;		de - Pointer to the item list
        ;		a  - Tile ID of item being initialized
        ;
        ; This routine scans each level from top right to bottom left
        ; building up a table of items for each level. These tables
        ; are then used by animation routines and collision routines.
        ;
_initItems:
        pushall 

        ;
        ; Save parameters passed in registers
        ;
        ld      (itemID), a
        ld      (currentItem), de
        ld      (currentItemTable), hl

        ;
        ; Build a stack frame for our variables
        ;
        ld      (tempSP), sp
        ld      ix, -SIZEOF_vars
        add     ix, sp
        ld      sp, ix

        ;
        ; Initialize memory variables
        ;
        ld      (ix+levelY), MAX_LEVEL_Y
        ld      (ix+itemCount), 0

        ld      hl, _levels
levelYLoop:
        ld      (currentLevel), hl
        ld      (ix+levelX), MAX_LEVEL_X

levelXLoop:
        ld      hl, (currentItemTable)
        ld      de, (currentItem)
        ld      (hl), e
        inc     hl
        ld      (hl), d
        inc     hl
        ld      (currentItemTable), hl

        ld      hl, (currentLevel)
        ld      (ix+tileY), 3
        ld      c, LEVEL_HEIGHT

tileYLoop:
        ld      (ix+tileX), 0
        ld      b, SCREEN_WIDTH

tileXLoop:
        ld      a, (hl)                 ; Get tile ID
itemID  equ     $+1
        cp      0x00
        call    z, addItem
        inc     hl
        inc     (ix+tileX)
        djnz    tileXLoop

        ; Next row in the tilemap
        ld      de, SCREEN_WIDTH*MAX_LEVEL_X-SCREEN_WIDTH
        add     hl, de

        inc     (ix+tileY)
        dec     c
        jr      nz, tileYLoop

        ;
        ; Move the current level pointer to the next level to the right
        ;
        ld      hl, (currentLevel)
        ld      de, SCREEN_WIDTH
        add     hl, de
        ld      (currentLevel), hl

        ld      de, (currentItem)
        ; Flags, 0xff = end of list
        ld      a, 0xff
        ld      (de), a
        inc     de
        ld      (currentItem), de

        ;
        ; Decrement X counter and loop if not zero
        ;
        dec     (ix+levelX)
        jr      nz, levelXLoop

        ;
        ; Move the current level pointer to the next level down
        ;
        ld      hl, (currentLevel)
        ld      de, -SCREEN_WIDTH*MAX_LEVEL_X
        add     hl, de
        ld      de, SCREEN_WIDTH*MAX_LEVEL_X*LEVEL_HEIGHT
        add     hl, de
        ld      (currentLevel), hl

        ;
        ; Decrement Y counter and loop if not zero
        ;
        dec     (ix+levelY)
        jr      nz, levelYLoop

        ;
        ; Restore the stack frame
        ;
tempSP  equ     $+1
        ld      sp, 0x0000

        popall  
        ret     

        ;
        ; Add a coin to the coin table
        ;
addItem:
        ld      de, (currentItem)

        ; Flags, Bit0 = visible
        ld      a, 1
        ld      (de), a
        inc     de

        ; X screen position
        ld      a, (ix+tileX)
        ld      (de), a
        inc     de

        ; Y screen position
        ld      a, (ix+tileY)
        ld      (de), a
        inc     de

        ; Animation frame
        ld      a, (ix+itemCount)
        inc     (ix+itemCount)
        ld      (de), a
        inc     de

        ld      (currentItem), de

        ret     

        ;
        ; Calculate the value of the current item table based
        ; on the values of tileMapX and tileMapY and save it
        ; in .
        ;
        ; Entry:
        ;		hl - Pointer to current item table variable
        ; 		de - Pointer to item tables
        ;
setCurrentItemTable:
        ld      (currItemTab), hl
        ld      hl, (_tileMapX)         ; Get tileMapX & tileMapY
        ld      a, h
        ax      MAX_LEVEL_X*SIZEOF_ptr
        ld      h, a
        ld      a, l
        ax      SIZEOF_ptr
        add     h
        ld      l, a
        ld      h, 0
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
currItemTab equ $+2
        ld      (0x0000), de
        ret     

        ;
        ; Cycle through the specified item table if the item is
        ; visible, update the screen with the attribute for the item.
        ;
        ; Items themsleves are not displayed here.
        ;
        ; Entry:
        ;		hl - Pointer to the current item table
        ;		a  - ID of the item
        ;
displayItemAttr:
        ld      (itemID2), a
nextItem:
        ld      a, (hl)
        cp      0xff
        ret     z

        or      a
        jr      z, notVisible

        push    hl

        inc     hl
        ld      c, (hl)                 ; Item X position
        inc     hl
        ld      b, (hl)                 ; Item Y position

itemID2 equ     $+1
        ld      a, -1

        call    setTileAttr

        pop     hl
notVisible:
        ld      a, SIZEOF_item
        addhl   
        jr      nextItem

        ;
        ; Set the attribute for the tile at the specified location
        ;
        ; Entry:
        ;		bc - y,x screen position
        ;		a  - Tile ID
        ;
setTileAttr:
        push    af
        push    hl

        ld      hl, _tileAttr
        addhl   
        ld      a, (hl)

        call    setAttr

        pop     hl
        pop     af
        ret     

        ;
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;		a  - Tile ID of item
        ;
displayTile:
        push    af
        push    bc
        push    de
        push    hl

        ld      (itemID4), a
        ; Calculate the screen address
        ld      l, b                    ; Y screen position
        ld      h, 0
        hlx     16
        ld      de, _screenTab
        add     hl, de
        ld      a, (hl)                 ; Screen low byte address
        add     c                       ; Add X offset
        ld      c, a                    ; Store result in 'c'
        inc     hl
        ld      b, (hl)                 ; Screen high byte address

itemID4 equ     $+1
        ld      l, -1                   ; -1 is over written by the value of 'a' passed in
        ld      h, 0
        hlx     8
        ld      de, _tile0
        add     hl, de

        ; Display the tile. We are going to use the
        ; stack pointer to load a 16 bit value so
        ; we need to disable interrupts.
        di      
        ; Save the current stack pointer
        ld      (TempSP2), sp
        ; Point the stack at the tile data
        ld      sp, hl
        ; Point hl at the screen address
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

        ; Restore the stack pointer.
TempSP2 equ     $+1
        ld      sp, 0x0000
        ei      

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     
        ;
        ;
        ; Entry:
        ;		hl - Pointer to current item table
        ;		a  - ID of item
        ;
displayItems:
        ld      (itemID3), a
nextItem2:
        ld      a, (hl)                 ; Flags
        cp      0xff
        ret     z

        cp      0x00                    ; Is the item visible?
        jr      z, notVisible2

        push    hl

        inc     hl
        ld      c, (hl)                 ; Tile x position
        inc     hl
        ld      b, (hl)                 ; Tile y position
itemID3 equ     $+1
        ld      a, -1                   ; Tile ID
        call    displayTile             ; Display tile
        call    setTileAttr

        pop     hl                      ; Restore coin table pointer
notVisible2:
        ld      a, SIZEOF_item
        addhl   
        jr      nextItem2

        ;
        ; Check if the player has collided with an item. And if so,
        ; remove the item and attrinute from the level and call
        ; the user provided sub-routine to update socres, etc.
        ;
        ;	Entry:
        ;		hl - Pointer to current item table
        ;		de - Pointer to subroutine to call when collision is detected
        ;
checkItemCollision:
        ld      (updateScore), de
nextEgg:
        ld      a, (hl)
        cp      0xff
        ret     z

        cp      0x00                    ; Is the item visible?
        jr      z, notVisible3

        push    hl
        inc     hl

        ;
        ; Collision check here
        ;
        ld      a, (hl)                 ; X byte position
        rlca                            ; x2
        rlca                            ; x4
        rlca                            ; x8
        and     %11111000
        add     2                       ; Left side pixel offset (indented a little)
        ld      b, a
        add     ITEM_WIDTH-5            ; Right side pixel offset (pulled in a little)
        ld      c, a

        ld      a, (_xPos)              ; Player left side pixel position
        inc     a
        cp      c                       ; Compare with coin right side
        jr      nc, noCollision         ; 'nc' if 'c' <= 'a'

        add     PLAYER_WIDTH-4          ; Get right side pixel position
        cp      b                       ; Compare with coin left side
        jr      c, noCollision          ; 'c' if 'b' > 'a'

        inc     hl
        ld      a, (hl)                 ; Y byte position
        rlca                            ; x2
        rlca                            ; x4
        rlca                            ; x8
        and     %11111000
        add     2                       ; Top pixel offset pulled in a little
        ld      b, a
        add     ITEM_HEIGHT-5           ; Bottom pixel offset, pushed up a little
        ld      c, a

        ld      a, (_yPos)
        cp      c                       ; Compare with bottom
        jr      nc, noCollision         ; 'nc' if 'c' <= 'a'

        add     PLAYER_HEIGHT-1         ; Player bottom pixel position
        cp      b                       ; Compare with top
        jr      c, noCollision          ; 'c' if 'b' > 'a'

        ld      b, (hl)                 ; Y position
        dec     hl                      ; Back to the flags
        ld      c, (hl)                 ; X position
        dec     hl
        xor     a                       ; Zero flags
        ld      (hl), a

        push    bc
        call    clearAttr
        pop     bc
        call    clearChar

        ;
        ; USer provided function to update score, etc.
        ;
updateScore equ $+1
        call    -1
noCollision:
        pop     hl
notVisible3:
        ld      a, SIZEOF_item
        addhl   
        jp      nextEgg

        section bss_user
        defvars 0                       ; Define the stack variables used
        {       
            levelX      ds.b 1
            levelY      ds.b 1
            tileX       ds.b 1
            tileY       ds.b 1
            itemCount   ds.b 1
        SIZEOF_vars 
        }       

currentLevel:
        dw      0
currentItem:
        dw      0
currentItemTable:
        dw      0


