        extern  _screenTab
        extern  setAttr

        public  print
        public  printAttr

        section code_user

        include "defs.inc"


		;
		; Display a string with attributes.
		;
		;	Entry:
		;		hl - Pointer to string
		;		b  - Y screen start position
		;		c  - X screen start position
		;		a  - Screen attributes
		;
		;	Exit:
		;		hl - Points to the memory location following the strings
		;			 null terminator.
		;		c  - Screen X position following the string
		;
printAttr:
        push    af
        push    de
        ld      e, a
L1b:
        ld      a, (hl)
        inc     hl
        or      a
        jr      z, L1f

        call    printChar

        ld      a, e
        call    setAttr

        inc     c
        jr      L1b
L1f:
        pop     de
        pop     af
        ret     

		;
		; Display a string.
		;
		;	Entry:
		;		hl - Pointer to string
		;		b  - Y screen start position
		;		c  - X screen start position
		;
		;	Exit:
		;		hl - Points to the memory location following the strings
		;			 null terminator.
		;		c  - Screen X position following the string
		;
print:
        push    af
L2b:
        ld      a, (hl)
        inc     hl
        or      a
        jr      z, L2f

        call    printChar

        inc     c
        jr      L2b
L2f:
        pop     af
        ret     

printChar:
        push    af
        push    bc
        push    de
        push    hl

        di      
        ld      (TempSP), sp

        sub     ' '                     ; Font data starts at SPACE
        ld      d, a                    ; Save char to be displayed

        ; Calculate the screen address
        ld      l, b                    ; Y screen position
        ld      h, 0
        hlx     16
        ld      sp, _screenTab
        add     hl, sp
        ld      sp, hl

        ld      a, c                    ; Get X offset
        pop     bc
        add     c                       ; Add it to the screen address
        ld      c, a

        ld      l, d                    ; Get char to display
        ld      h, 0
        hlx     8
        ld      sp, FONT
        add     hl, sp

        ; Point the stack at the font data
        ld      sp, hl
        ; Point hl at the screen address
        ld      hl, bc

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc                      ; 10
        ld      (hl), c                 ; 7
        inc     h                       ; Add 256 to screen address 4
        ld      (hl), b                 ; 7
        inc     h                       ; Add 256 to screen address 4

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b
        inc     h

        ; Pop 2 bytes of font data and store it
        ; to the screen.
        pop     bc
        ld      (hl), c
        inc     h
        ld      (hl), b

        ; Restore the stack pointer.
TempSP  equ     $+1
        ld      sp, 0x0000
        ei      

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     
