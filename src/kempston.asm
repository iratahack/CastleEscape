        public  detectKempston
        public  readKempston
        public  kjPresent

        include "defs.inc"

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
        ld      (kjPresent), a
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

        section bss_user
kjPresent:
        db      0
