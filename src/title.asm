        extern  printAttr
        extern  LOAD_SONG
        extern  PLAYER_OFF
        extern  _updateDirection
        extern  _lanternFlicker
        extern  rotateCount
        extern  currentCoinTable
        extern  _animateCoins

        public  titleScreen

        section code_user
        include "defs.inc"

titleScreen:
        ;
        ; Start the title song
        ;
        LD      A, GOTHIC
        CALL    LOAD_SONG

        ;
        ; Display the continue message
        ;
        ld      bc, 0x1505
        ld      hl, pressJumpMsg
        ld      a, PAPER_BLACK|INK_WHITE|BRIGHT|FLASH
        call    printAttr

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
waitJump:
        halt    

        ld      hl, rotateCount
        dec     (hl)
        jp      p, noAnimate

        ld      a, ROTATE_COUNT
        ld      (hl), a
        call    _animateCoins
noAnimate:

        ld      hl, lanternList
        call    _lanternFlicker

        call    _updateDirection
        ld      a, e
        or      a
        jr      z, waitJump

        call    PLAYER_OFF

waitNoJump:
        call    _updateDirection
        ld      a, e
        or      a
        jr      nz, waitNoJump

        ret     

        section rodata_user
pressJumpMsg:
        db      "Press Jump to Continue", 0x00

        ;
        ; List of lanterns on the title screen
        ;
lanternList:
        db      4
        dw      SCREEN_ATTR_START+(12*32)+9
        dw      SCREEN_ATTR_START+(12*32)+10
        dw      SCREEN_ATTR_START+(12*32)+22
        dw      SCREEN_ATTR_START+(12*32)+23

        ;
        ; List of coins on the title screen
        ; Specified by x/y pixel addresses
        ;
coinTable:
        db      0x01, 0x16*8, 0x0f*8, 0x00
        db      0x01, 0x17*8, 0x0f*8, 0x01
        db      0x01, 0x18*8, 0x11*8, 0x02
        db      0xff
