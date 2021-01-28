        public  _initISR
        public  ticks
        section code_user

        include "defs.asm"
        defc    VECTOR_TABLE_HIGH=0x80
        defc    VECTOR_TABLE=(VECTOR_TABLE_HIGH<<8)
        defc    JUMP_ADDR_BYTE=0x81
        defc    JUMP_ADDR=(JUMP_ADDR_BYTE<<8)|JUMP_ADDR_BYTE

_initISR:
        pushall 

        ld      hl, VECTOR_TABLE        ; Get vector table address
        ld      a, JUMP_ADDR_BYTE       ; High order byte of jump adress
        ld      (hl), a                 ; Store JUMP_ADDR in first byte of vector table
        ld      de, hl                  ; Fill the same data
        inc     de                      ; in the next 256
        ld      bc, 0x100               ; bytes of the vector table
        ldir    

        ld      a, JP_OPCODE            ; Store the opcode for JP
        ld      (JUMP_ADDR), a
        ld      de, isr                 ; Store the jump address which is the address of the
        ld      (JUMP_ADDR+1), de

        ld      a, VECTOR_TABLE_HIGH    ; Write the address of the vector table
        ld      i, a                    ; to the i register
        im      2                       ; Enable interrupt mode 2
        ei                              ; Enable interrupts

        popall  
        ret     

isr:
        ld      (isrTempSP), sp         ; Save the application stack pointer
        ld      sp, interruptStack      ; Load the interrupt stack pointer
        push    hl
        ;
        ; Increment the 16-bit ticks count
        ;
        ld      hl, (ticks)
        inc     hl
        ld      (ticks), hl
        pop     hl                      ; Restore the registers we used
isrTempSP   equ $+1
        ld      sp, 0x0000              ; Restore the application stack pointer
        ei                              ; Enable interrupts
        reti                            ; Acknowledge and return from interrupt

        section bss_user
ticks:
        dw      0

        ds      0x40, 0x55              ; 64 bytes for interrupt stack
interruptStack:
