        extern  bannerData
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
        extern  LOAD_SONG
        extern  PLAYER_OFF
        extern  afxEnable
        extern  _lanternFlicker
        extern  currentCoinTable
        extern  _animateCoins
        extern  bank7Screen
        extern  defineKeys

        public  mainMenu
        public  rotateCount
        public  displayBorder
        public  rotateCount
        public  animateMenu
        public  waitReleaseKey

        section BANK_5

        include "defs.inc"

        defc    BORDER_COLOR=INK_YELLOW
		;
		; Display the game main menu. Options to configure and start
		; the game are on this screen.
		;
mainMenu:
        ;
        ; Start main menu song
        ;        pop     hl

        LD      A, MAIN_MENU_MUSIC
        CALL    LOAD_SONG

        ;
        ; Setup the coin table for the main menu
        ;
        ld      hl, coinTable
        ld      (currentCoinTable), hl

        ;
        ; Reset counter used for coin rotation
        ;
        xor     a
        ld      (rotateCount), a
displayScreen:
        ;
        ; Patch the animate coins routine to access
        ; memory @ 0xc000
        ;
        ld      hl, 0xf8cb              ; set 7, b
        ld      (bank7Screen), hl

        ;
        ; Point the ULA at screen 1
        ;
        screen  1

        ;
        ; Page in the memory bank with the main menu screen
        ; to 0xc000
        ;
        bank    7
getKey:
        ld      hl, lanternList
        call    animateMenu

        call    keyboardScan            ; Read the keyboard
        or      a                       ; If a key has been presses
        jr      nz, keyPressed          ; jump to process it.

        ld      a, (kjPresent)          ; Check if the kempston joystick
        or      a                       ; is present, if not
        jr      z, getKey               ; continue polling.

        ld      e, 0                    ; No direction keys pressed
        call    readKempston            ; Read the joystick
        ld      a, e                    ; Check if fire has been pressed
        and     JUMP
        jr      z, getKey               ; If not, continue polling

        ld      a, '0'                  ; Force '0'
        jr      opt0                    ; Jump to process action when '0' is pressed
keyPressed:
        ld      hl, lanternList
        call    waitReleaseKey

        cp      '1'
        jr      nz, opt2
        call    defineKeys
        jr      displayScreen

opt2:
IFDEF   ATTRIB_EDIT
        cp      '2'
        jr      nz, opt0
		;
		; Page bank 0 to 0xc000 since it has the attributes
		;
        bank    0
        ld      hl, _tileAttr
        push    hl
        ld      hl, _tile0
        push    hl
        screen  0
        call    _attribEdit
        pop     hl
        pop     hl
        jp      displayScreen
ENDIF   
opt0:
        cp      '0'
        jp      nz, displayScreen
        call    PLAYER_OFF
        call    newGame
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
        ; Animate the menu items.
        ;
        ;   Input:
        ;       hl - Pointer to lantern list
        ;
        ;   Notes:
        ;       'hl' is preserved.
        ;
animateMenu:
        push    hl
        halt    

        call    _lanternFlicker

        ld      hl, rotateCount
        dec     (hl)
        jp      p, noRotate

        ld      a, ROTATE_COUNT
        ld      (hl), a
        call    _animateCoins
noRotate:
        pop     hl
        ret     

        ;
        ; Wait for a key to be released and animate the menu items.
        ;
        ;   Input:
        ;       hl - Pointer to the lantern list
        ;
        ;   Notes:
        ;       'af' is preserved.
waitReleaseKey:
        push    af
releaseKey:
        call    animateMenu
        call    keyboardScan            ; Read the keyboard
        or      a                       ; If a key is pressed
        jr      nz, releaseKey          ; continue looping
        pop     af
        ret     

;        section bss_user

        ;
        ; Counter so coins are not rotated every frame
        ;
rotateCount:
        db      0

;        section rodata_user

        ;
        ; List of lanterns on the main menu
        ;
lanternList:
        db      4
        dw      0x8000+SCREEN_ATTR_START+(7*32)+12
        dw      0x8000+SCREEN_ATTR_START+(7*32)+13
        dw      0x8000+SCREEN_ATTR_START+(7*32)+18
        dw      0x8000+SCREEN_ATTR_START+(7*32)+19

        ;
        ; List of coins on the main menu
        ; Specified by y/x pixel addresses
        ;
coinTable:
        db      0x01, 0x16*8, 0x06*8, 0x00
        db      0x01, 0x17*8, 0x06*8, 0x01
        db      0x01, 0x18*8, 0x08*8, 0x02
        db      0xff
