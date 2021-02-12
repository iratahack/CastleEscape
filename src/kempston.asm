        public  detectKempston
        public  readKempston

        include "defs.asm"

        section code_user
		;
		;	Input:
		;		None
		;
		;	Output:
		;		Z - No Kempston present
		;		NZ - Kempston present
detectKempston:
        halt    
        in      a, (IO_KEMPSTON)
        inc     a
        or      a
        ret     

		;
		; 	Input:
		;		e - Current direction bits
		;
		;	Output:
		;		e - Updated direction bits
		;
readKempston:
        in      a, (IO_KEMPSTON)
        and     JUMP|UP|DOWN|LEFT|RIGHT
        or      e
        ld      e, a
        ret     
