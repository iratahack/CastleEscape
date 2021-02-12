        extern  heartCount
        extern  subBCD
        extern  display2BCD
        extern  gameOver
        extern  AFXPLAY
        extern  xyPos
        extern  xyStartPos
        extern  _jumping

        public  die

        include "defs.inc"

        section code_user

		;
		; Routine called when plater dies.
		;
die:
        push    af
        push    bc
        push    de
        push    hl
		;
		; Decrement the heart count
		;
        ld      l, 0x01
        ld      de, heartCount
        call    subBCD
        ld      bc, 0x011d              ; y,x screen location
        ex      de, hl
        call    display2BCD

        ld      a, AYFX_DIE
        call    nc, AFXPLAY

        delay   50

		;
		; If the heart count is zero, game over!
		;
        ld      a, (heartCount)
        or      a
        jp      z, gameOver

		; Set player X/Y position to where
		; they entered the level.
        ld      hl, (xyStartPos)
        ld      (xyPos), hl
        xor     a
        ld      (_jumping), a

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     
