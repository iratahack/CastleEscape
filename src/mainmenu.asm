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
        extern  keyboardScan
        extern  readKempston
        extern  kjPresent


        public  mainMenu

        section code_user

        include "defs.inc"

        defc    BORDER_COLOR=INK_YELLOW
		;
		; Display the game main menu. Options to configure and start
		; the game are on this screen.
		;
mainMenu:
        screen  1                       ; Display the main menu

getKey:
        call    keyboardScan            ; Read the keyboard
        or      a                       ; If a key has been presses
        jr      nz, keyPressed          ; jump to process it.

        ld      a, (kjPresent)          ; Check if the kempston joystick
        or      a                       ; is present, if not
        jr      z, getKey               ; continue polling.

        call    readKempston            ; Read the joystick
        ld      a, e                    ; Check if fire has been pressed
        and     JUMP
        jr      z, getKey               ; If not, continue polling

        ld      a, '0'                  ; Force '0'
        jr      opt0                    ; Jump to process action when '0' is pressed
keyPressed:
        call    waitKey

        cp      '1'
        call    z, noop

IFDEF   ATTRIB_EDIT
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
ENDIF   
opt0:
        cp      '0'
        call    z, newGame

        jp      mainMenu

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
        push    af
		;
        ; Clear the screen
        ;
        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls

        call    displayBorder

        ld      bc, 0x0c05
        ld      hl, dummy
        call    print

        screen  0                       ; Now it's setup switch to screen 0

        call    waitKey                 ; Do nothing.

        pop     af
        ret     

        section rodata_user

dummy:  db      "Press any key to return", 0x00
