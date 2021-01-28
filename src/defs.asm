        module  defs

        extern  _font_8x8_cpc_system

        defvars 0
        {       
            itemFlags   ds.b 1
            itemX       ds.b 1
            itemY       ds.b 1
            imteFrame   ds.b 1
        SIZEOF_item 
        }       

        defc    SIZEOF_ptr=0x02
        defc    SIZEOF_byte=0x01

        defc    START_LIVES=0x03

        ;
        ; Tilemap definitions
        ;
        defc    MAX_LEVEL_X=0x04
        defc    MAX_LEVEL_Y=0x02

        defc    TILEMAP_WIDTH=0x20*MAX_LEVEL_X
        defc    LEVEL_HEIGHT=21

        ;
        ; Values numbers for control keys
        ;
        defc    JUMP=0x10
        defc    UP=0x08
        defc    DOWN=0x04
        defc    LEFT=0x02
        defc    RIGHT=0x01
        defc    JUMP_BIT=4
        defc    UP_BIT=3
        defc    DOWN_BIT=2
        defc    LEFT_BIT=1
        defc    RIGHT_BIT=0

        defc    JUMP_HEIGHT=24
        defc    LEFT_SPEED=-1
        defc    RIGHT_SPEED=1
        defc    JUMP_SPEED=-1
        defc    DOWN_SPEED=1
        defc    UP_SPEED=-1

        defc    PLAYER_WIDTH=16
        defc    PLAYER_HEIGHT=16
        defc    MAX_X_POS=256
        defc    MAX_Y_POS=192

		;
        ; Sprite ID's
        ;
        defc    ID_LANTERN=88
        defc    ID_BLANK=11
        defc    ID_COIN=74
        defc    ID_EGG=97
        defc    ID_EGG0=66
        defc    ID_HEART=98


        ;
        ; Screen addresses
        ;
        defc    SCREEN_START=0x4000
        defc    SCREEN_LENGTH=0x1800
        defc    SCREEN_END=(SCREEN_START+SCREEN_LENGTH)
        defc    SCREEN_ATTR_START=(SCREEN_START+SCREEN_LENGTH)
        defc    SCREEN_ATTR_LENGTH=0x300
        defc    SCREEN_ATTR_END=(SCREEN_ATTR_START+SCREEN_ATTR_LENGTH)
        defc    SCREEN_WIDTH=0x20
        defc    SCREEN_HEIGHT=0x18

        ;
        ; Screen attribute definitions
        ;
        defc    INK_BLACK=0x00
        defc    INK_BLUE=0x01
        defc    INK_RED=0x02
        defc    INK_MAGENTA=0x03
        defc    INK_GREEN=0x04
        defc    INK_CYAN=0x05
        defc    INK_YELLOW=0x06
        defc    INK_WHITE=0x07

        defc    PAPER_BLACK=0x00
        defc    PAPER_BLUE=0x08
        defc    PAPER_RED=0x10
        defc    PAPER_MAGENTA=0x18
        defc    PAPER_GREEN=0x20
        defc    PAPER_CYAN=0x28
        defc    PAPER_YELLOW=0x30
        defc    PAPER_WHITE=0x38

        defc    BRIGHT=0x40
        defc    FLASH=0x80

        ;
        ; Address of the font. If 0x3d00 is used this constant points
        ; to the font in the Spectrum ROM.
        ;
        defc    FONT=_font_8x8_cpc_system

        ;
        ; I/O Ports
        ;
        defc    IO_BORDER=0xfe
        defc    IO_BEEPER=0xfe
        defc    IO_BANK=0x7ffd
        defc    IO_KEMPSTON=0x1f

		;
		; OpCodes
		;
        defc    JP_OPCODE=0xc3
        defc    NOP_OPCODE=0x00

        ;
        ; Macros for use with asmpp.pl
        ;

		defc	MEM_BANK_ROM=0x10
        ;
        ; Bank select
        ;
bank    MACRO   num
        push    af
        push    bc
        ld      bc, IO_BANK
        ld      a, num
        or		MEM_BANK_ROM
        out     (c), a
        pop     bc
        pop     af
        endm    

        ;
        ; Multiply hl by times where times is 2, 4, 8, 16, 32, 64
        ;
hlx     MACRO   times
IF  times>=2
        add     hl, hl
ENDIF   
IF  times>=4
        add     hl, hl
ENDIF   
IF  times>=8
        add     hl, hl
ENDIF   
IF  times>=16
        add     hl, hl
ENDIF   
IF  times>=32
        add     hl, hl
ENDIF   
IF  times>=64
        add     hl, hl
ENDIF   
        endm    

ax      MACRO   times
IF  times>=2
        add     a
ENDIF   
IF  times>=4
        add     a
ENDIF   
IF  times>=8
        add     a
ENDIF   
IF  times>=16
        add     a
ENDIF   
IF  times>=32
        add     a
ENDIF   
IF  times>=64
        add     a
ENDIF   
        endm    

entry   MACRO   
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        ld      ix, 12                  ; the 6 pushes above plus return address
        add     ix, sp
        endm    

exit    MACRO   
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        endm    

        ;
        ; Push af-hl onto the stack
        ;
pushall MACRO   
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        push    iy
        endm    

        ;
        ; Pop hl-af off the stack
        ;
popall  MACRO   
        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        endm    

        ;
        ; Add 'a' to 'hl'
        ;
addhl   MACRO   
        add     l
        ld      l, a
        adc     h
        sub     l
        ld      h, a
        endm    

        ;
        ; Add 'a' to 'de'
        ;
addde   MACRO   
        add     e
        ld      e, a
        adc     d
        sub     e
        ld      d, a
        endm    

        ;
        ; Add 'a' to 'bc'
        ;
addbc   MACRO   
        add     c
        ld      c, a
        adc     b
        sub     c
        ld      b, a
        endm    

mod     MACRO   val
        LOCAL   modLoop
modLoop:
        sub     a, val
        jp      p, modLoop
        add     a, val
        endm    
