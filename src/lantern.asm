        public  _lanternFlicker
        public  _lanternList
        extern  ticks
        include "defs.asm"

        section code_user
        ;
        ; On entry:
        ;			hl - Pointer to lantern table
        ;
_lanternFlicker:
        ;        push    af

        ld      a, (hl)                 ; Number of lanterns
        or      a
        jr      z, done                 ; No lanterns

        ;        push    bc                      ; Save the rest of the registers
        ;        push    hl

        inc     hl                      ; Point to first attribute address

        di      
        ld      (tempSP), sp            ; Save stack pointer
        ld      sp, hl                  ; Point stack at attribute address table

        ld      b, a                    ; Set loop count

        ld      hl, colors              ; Pointer to color table
        ld      a, (ticks)              ; Use ticks as the color table index
        and     0x07                    ; Bottom 3 bits only
        addhl   
        ld      a, (hl)                 ; Read attribute

loop:
        pop     hl                      ; Pop the attribute address
        ld      (hl), a                 ; and update the attribute value
        djnz    loop                    ; Loop for all lanterns

tempSP  equ     $+1
        ld      sp, 0x0000              ; Restore the stack
        ei      

        ;        pop     hl
        ;        pop     bc
done:
        ;        pop     af
        ret     

        section rodata_user
colors:
        db      INK_YELLOW
        db      INK_RED
        db      (INK_YELLOW|BRIGHT)
        db      (INK_RED|BRIGHT)
        db      (INK_YELLOW|BRIGHT)
        db      (INK_RED|BRIGHT)
        db      INK_YELLOW
        db      INK_RED

        section bss_user
_lanternList:                           ; Max of 8 lanterns on any screen
        db      0
        dw      0x0000, 0x0000, 0x0000, 0x0000
        dw      0x0000, 0x0000, 0x0000, 0x0000
