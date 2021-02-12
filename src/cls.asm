        extern  _screenTab
        public  _cls
        public  clearAttr
        public  setAttr
        public  clearChar
        section code_user

        include "defs.asm"

        ;
        ; Clear the screen bitmap and attr data.
        ;
        ; On entry, l contains the attribute to fill the attr memory.
        ;
_cls:
        push    af
        push    bc
        push    hl

        ld      a, l
        ld      (clsAttrib), a

        halt    

        di      
        ld      (clsTempSP), sp

        ld      sp, SCREEN_ATTR_END
        ld      h, l                    ; attr input parameter in l
        ; If we divide the attr length by 4 it will
        ; fit in 8 bits and we can use djnz
        ld      b, SCREEN_ATTR_LENGTH/4
loop2:
        ; Push 4 bytes into screen attr memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        djnz    loop2

        ld      hl, 0                   ; data to fill
        ; If we divide the screen length by 32 it will
        ; fit in 8 bits and we can use djnz
        ld      b, SCREEN_LENGTH/32
loop:
        ; Push 32 bytes of 0 into the screen memory
        ; Each push is 2 bytes
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        djnz    loop
clsTempSP   equ $+1
        ld      sp, 0x0000
        ei      

        pop     hl
        pop     bc
        pop     af
        ret     

        ;
        ; Set the screen attribute specified by 'bc' to
        ; the attribute used to last clear the screen.
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;
clearAttr:
        push    af
        ld      a, (clsAttrib)
        call    setAttr
        pop     af
        ret     

        ;
        ; Set the screen attribute specified by 'bc' to
        ; the attribute passed in 'a'.
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;		a - Attribute
        ;
setAttr:
        push    bc
        push    hl
        ld      l, b
        ld      h, 0
        hlx     32
        ld      b, 0
        add     hl, bc
        ld      bc, SCREEN_ATTR_START
        add     hl, bc
        ld      (hl), a
        pop     hl
        pop     bc
        ret     

        ;
        ; Clear the character position specified by 'bc'
        ;
        ; Entry:
        ;		b - Y location
        ;		c - X location
        ;
        ; Corrupts:
        ;		af, bc, hl
        ;
clearChar:
        ld      l, b                    ; Multiply the Y offset
        ld      h, 0                    ; by 16 to to use with
        hlx     16                      ; screenTab

        ld      de, _screenTab
        add     hl, de
        ld      a, (hl)                 ; Get low order screen address
        add     c                       ; Add X offset
        ld      e, a                    ; Store in 'e'
        inc     hl                      ; Get high order screen address
        ld      d, (hl)                 ; into 'd'
        xor     a                       ; Clear 'a'
        ld      b, 8                    ; Char height count
clearCharLoop:
        ld      (de), a
        inc     d
        djnz    clearCharLoop

        ret     

        section bss_user
clsAttrib:
        ds      1
