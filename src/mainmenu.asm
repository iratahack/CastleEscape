        extern  bannerData
        extern  _border
        extern  _cls
        extern  displayTile
        extern  setAttr
        extern  print
        extern  _attribEdit
        extern  _tile0
        extern  _tileAttr
        extern  waitKey
        extern  newGame


        public  mainMenu

        section code_user

        include "defs.asm"

        defc    BORDER_COLOR=INK_YELLOW
		;
		; Display the game main menu. Options to configure and start
		; the game are on this screen.
		;
mainMenu:
        screen  1

getKey:
        call    waitKey

        cp      '1'
        call    z, noop

        cp      '2'
        jr      nz, opt0
        ld      hl, _tileAttr
        push    hl
        ld      hl, _tile0
        push    hl
        screen  0
        call    _attribEdit
        pop     hl
        pop     hl

opt0:
        cp      '0'
        call    z, newGame

        jp      mainMenu
startGame:

        ret     

displayBorder:
        ld      hl, bannerData
        ld      de, 0x0000              ; Starting Y/X position
        call    displayRow

        ld      hl, bannerData+0x40
        ld      de, 0x1700              ; Starting Y/X position
        call    displayRow

        ld      b, SCREEN_HEIGHT-2
        ld      d, 0x01                 ; Starting Y position
sides:
        push    bc                      ; Save the loop counter

        ld      b, d                    ; Set Y position for displayTile

        ld      c, 0x00
        ld      a, 10*12                ; Left side tile ID
        call    displayTile             ; Display the tile
        ld      a, BORDER_COLOR
        call    setAttr                 ; Set the attribute for the tile

        ld      c, SCREEN_WIDTH-1
        ld      a, 10*12+5              ; Right side tile ID
        call    displayTile             ; Display the tile
        ld      a, BORDER_COLOR
        call    setAttr                 ; Set the attribute for the tile

        inc     d                       ; Increment Y screen position

        pop     bc                      ; Restore the loop counter
        djnz    sides

        ret     

		;
		; Display a row of tile data
		;
		;	Entry:
		;		hl - Pointer to tile data
		;		b  - Start screen Y position
		;		c  - Start screen X position
		;
displayRow:
        push    af
        push    bc
        push    de
        push    hl

        ld      b, SCREEN_WIDTH
display:
        push    bc

        ld      a, (hl)                 ; Get the tile ID
        inc     hl                      ; Point to next tile ID
        ld      bc, de                  ; Set Y/X position for displayTile
        call    displayTile             ; Display the tile
        ld      a, BORDER_COLOR
        call    setAttr                 ; Set the attribute for the tile
        inc     e                       ; Increment X screen position

        pop     bc
        djnz    display

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

		;
		; Dummy screen to be displayed when options are selected from main menu.
		;
noop:
		;
        ; Clear the screen and set the border color
        ;
        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls
        ld      l, INK_BLACK
        call    _border

        halt    

        call    displayBorder

        ld      bc, 0x0c05
        ld      hl, dummy
        call    print

        screen  0

        call    waitKey

        ret     

        section rodata_user

dummy:  db      "Press any key to return", 0x00
