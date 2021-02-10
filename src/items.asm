        extern  _yPos
        extern  _xPos
        extern  _levels
        extern  _tileAttr
        extern  _tileMapX
        extern  _screenTab
        extern  _tile0
        extern  setAttr
        extern  clearAttr

        public  _initItems
        public  setCurrentItemTable
        public  displayItems
        public  checkItemCollision
        public  displayTile
        public  setTileAttr
        public  removeItem
        public  displayItems_pixel

        include "defs.inc"

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
        ld      (itemID+1), a
        ld      (currentItemTable), hl

        ;
        ; Build a stack frame for our variables
        ;
        ld      (tempSP+1), sp
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
        ld      (ix+levelX), MAX_LEVEL_X

levelXLoop:
        push    hl
        ld      hl, (currentItemTable)
        ld      (hl), e
        inc     hl
        ld      (hl), d
        inc     hl
        ld      (currentItemTable), hl
        pop     hl

        push    hl                      ; Save level pointer

        ld      (ix+tileY), 3
        ld      c, LEVEL_HEIGHT
tileYLoop:
        ld      (ix+tileX), 0
        ld      b, SCREEN_WIDTH
tileXLoop:
        ld      a, (hl)                 ; Get tile ID
itemID:
        cp      -1
        call    z, addItem
        inc     hl
        inc     (ix+tileX)
        djnz    tileXLoop

        ; Next row in the tilemap
        push    bc
        ld      bc, SCREEN_WIDTH*MAX_LEVEL_X-SCREEN_WIDTH
        add     hl, bc
        pop     bc

        inc     (ix+tileY)
        dec     c
        jr      nz, tileYLoop

        pop     hl                      ; Restore level pointer

        ;
        ; Move the current level pointer to the next level to the right
        ;
        ld      bc, SCREEN_WIDTH
        add     hl, bc

        ; Flags, 0xff = end of list
        ld      a, 0xff
        ld      (de), a
        inc     de

        ;
        ; Decrement X counter and loop if not zero
        ;
        dec     (ix+levelX)
        jr      nz, levelXLoop

        ;
        ; Move the current level pointer to the next level down
        ;
        ld      bc, -SCREEN_WIDTH*MAX_LEVEL_X
        add     hl, bc
        ld      bc, SCREEN_WIDTH*MAX_LEVEL_X*LEVEL_HEIGHT
        add     hl, bc

        ;
        ; Decrement Y counter and loop if not zero
        ;
        dec     (ix+levelY)
        jr      nz, levelYLoop

        ;
        ; Restore the stack frame
        ;
tempSP:
        ld      sp, -1

        popall  
        ret     

        ;
        ; Add a coin to the coin table
        ;
addItem:
        ; Flags, Bit0 = visible
        ld      a, 1
        ld      (de), a
        inc     de

        ; X screen position
        ld      a, (ix+tileX)
        rlca                            ; x2
        rlca                            ; x4
        rlca                            ; x8
        and     %11111000
        ld      (de), a
        inc     de

        ; Y screen position
        ld      a, (ix+tileY)
        rlca                            ; x2
        rlca                            ; x4
        rlca                            ; x8
        and     %11111000
        ld      (de), a
        inc     de

        ; Animation frame
        ld      a, (ix+itemCount)
        inc     (ix+itemCount)
        ld      (de), a
        inc     de

        ret     

        ;
        ; Calculate the value of the current item table based
        ; on the values of tileMapX and tileMapY and save it
        ; to the memory location pointed to by 'hl'.
        ;
        ; Entry:
        ;		hl - Pointer to current item table variable
        ; 		de - Pointer to item tables
        ;
setCurrentItemTable:
        ld      (currItemTab+2), hl
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
currItemTab:
        ld      (-1), de
        ret     

        ;
        ; Set the attribute for the tile at the specified location
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;		a - Tile ID of item
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
        ; Display the specified tile at the specified location.
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

        di      
        ; Save the current stack pointer
        ld      (TempSP2+1), sp

        ld      d, a                    ; Save the tile ID
        ; Calculate the screen address
        ld      l, b                    ; Y screen position
        ld      h, 0
        hlx     16
        ld      sp, _screenTab
        add     hl, sp
        ld      sp, hl
        ld      a, c
        pop     bc
        add     c                       ; Add X offset
        ld      c, a                    ; Store result in 'c'

        ld      l, d                    ; Tile ID
        ld      h, 0
        hlx     8
        ld      de, _tile0
        add     hl, de

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
TempSP2:
        ld      sp, -1
        ei      

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

        ;
        ; Display the visible items pointed to by hl. Typically
        ; called when the level changes to display the items
        ; which have not yet been collected or to display items
        ; in their new position if they are moving.
        ;
        ; Entry:
        ;		hl - Pointer to item table
        ;		a  - Tile ID of item
        ;
displayItems:
        ld      d, a                    ; Save tile ID
nextItem2:
        ld      a, (hl)                 ; Flags
        cp      0xff
        ret     z

        cp      0x00                    ; Is the item visible?
        jr      z, notVisible2

        push    hl

        inc     hl
        ld      a, (hl)                 ; Tile x position
        rrca    
        rrca    
        rrca    
        and     %00011111
        ld      c, a
        inc     hl
        ld      a, (hl)                 ; Tile y position
        rrca    
        rrca    
        rrca    
        and     %00011111
        ld      b, a
        ld      a, d                    ; Tile ID
        call    displayTile             ; Display tile
        call    setTileAttr

        pop     hl                      ; Restore coin table pointer
notVisible2:
        ld      a, SIZEOF_item
        addhl   
        jr      nextItem2

        ;
        ; Clear the visible items pointed to by hl. Typically
        ; called to remove the items from the screen before
        ; their position is updating.
        ;
        ; Entry:
        ;		hl - Pointer to item table
        ;		a  - Tile ID
        ;
displayItems_pixel:
        ld      d, a                    ; Save tile ID
nextItem3:
        ld      a, (hl)                 ; Flags
        cp      0xff
        ret     z

        cp      0x00                    ; Is the item visible?
        jr      z, notVisible4

        push    hl

        inc     hl
        ld      a, (hl)                 ; Item x pixel position
        rrca    
        rrca    
        rrca    
        and     %00011111
        ld      c, a

        inc     hl
        ld      b, (hl)                 ; Tile y pixel position

        push    de

        di      
        ld      (clearTileSP+1), sp

        calculateRow    b

        ld      a, d
        cp      ID_BLANK
        jr      z, blankTile

        ld      a, b
        and     %00000001
        add     d

        ld      l, a                    ; Tile ID
        ld      h, 0
        hlx     8
        ld      de, _tile0
        add     hl, de
        jr      other

blankTile:
        ld      l, d                    ; Tile ID
        ld      h, 0
        hlx     8
        ld      de, _tile0
        add     hl, de

other:
        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

        pop     de
        ld      a, e
        add     c
        ld      e, a
        ld      a, (hl)
        ld      (de), a
        inc     hl

clearTileSP:
        ld      sp, -1
        ei      
        pop     de

;        call    setTileAttr

        pop     hl                      ; Restore coin table pointer
notVisible4:
        ld      a, SIZEOF_item
        addhl   
        jp      nextItem3

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
        ld      (itemCollision+1), de
nextItem:
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
        srl     b
        srl     b
        srl     b
        dec     hl                      ; Back to the flags
        ld      c, (hl)                 ; X position
        srl     c
        srl     c
        srl     c
        dec     hl                      ; hl points to item flags

        ;
        ; User provided function to update score, etc.
        ;
itemCollision:
        call    -1
noCollision:
        pop     hl
notVisible3:
        ld      a, SIZEOF_item
        addhl   
        jp      nextItem

		;
		; Remove an item from the screen and change
		; it's flags so that it is no longer visible.
		;
		;	Entry:
		;		hl - Pointer to items flags
		;		b  - Screen y character position
		;		c  - screen x character position
		;
removeItem:
        xor     a                       ; Zero flags
        ld      (hl), a                 ; Save in item table
        call    clearAttr               ; Remove the item and attribute
        ld      a, ID_BLANK
        call    displayTile
        ret     

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

currentItemTable:
        dw      0


