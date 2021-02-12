        section CODE
        ;
        ; Fill the stack with a known pattern so
        ; we can see how much we are using.
        ;
        ; Interrupts should be disabled so no need to worry
        ; about ISR accessing the stack.
        ;
        ; The top of the stack is 0x8181 and it is 0x80 bytes deep
        defc    STACK_SIZE=0x80
        defc    FILL_WORD=0x5555
fillStack:
        ld      hl, sp                  ; Save the current stack address
        ld      de, FILL_WORD           ; Word to fill
        ld      b, STACK_SIZE/2         ; Stack size in words
fillStackLoop:
        push    de                      ; Push data to stack
        djnz    fillStackLoop           ; Loop for all words
        ld      sp, hl                  ; Restore saved stack address
