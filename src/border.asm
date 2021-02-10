        public  _border
        section code_user

        include "defs.inc"
        ;
        ; Change the border color. On entry, l contains the color.
        ;
_border:
        push    af                      ; Save the register we are using

        ld      a, l                    ; Get the input parameter which is the color
        and     0x07                    ; Only the lower 3 bits are used
        out     (IO_BORDER), a          ; Send it out the port

        pop     af                      ; Restore the register we used
        ret     
