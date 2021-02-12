        extern  heartCount
        extern  subBCD
        extern  display2BCD
        extern  _falling
        extern  gameOver

        public  die

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

		;
		; If the heart count is zero, game over!
		;
        ld      a, (heartCount)
        or      a
        jp      z, gameOver

        ld      a, 1
        ld      (_falling), a




        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     
