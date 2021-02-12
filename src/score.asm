        extern  display2BCD

        public  _displayScore
        public  score

        include "defs.asm"
        section code_user

        ;
        ; Display the current score
        ;
_displayScore:
        push    bc
        push    hl

        ld      bc, 0x0103              ; y,x screen location
        ld      hl, score+1             ; Point to 1000's/100's
        call    display2BCD
        ld      c, 0x05                 ; x screen location
        ld      hl, score               ; Point to 10's/1's
        call    display2BCD

        pop     hl
        pop     bc
        ret     

        section bss_user
score:                                  ; Score in BCD
        dw      0x0000
