        extern  _screenTab

        public  _copyScreen
        public  _pasteScreen
        public  _displaySprite
        public  playerSprite

        include "defs.inc"

        section code_user

		;
		; Entry:
		;		de - Pointer to buffer
		;		b  - Start screen y location
		;		c  - Start screen x location
		;
_copyScreen:
        di      
        ld      (copyTempSP), sp        ; Optimization, self modifying code

        calculateRow    b

        srl     c                       ; Divide the screen x pixel
        srl     c                       ; position by 8 to get the
        srl     c                       ; byte address.
        ld      b, PLAYER_HEIGHT
copyloop:
        pop     hl                      ; get screen row source adress
        ld      a, l
        add     c                       ; add x offset
        ld      l, a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here
        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here

        ld      a, (hl)
        ld      (de), a
        inc     de
        djnz    copyloop

copyTempSP  equ $+1
        ld      sp, 0x0000
        ei      
        ret     

		;
		; Entry:
		;		de - Pointer to buffer
		;		b  - Start screen y location
		;		c  - Start screen x location
		;
_pasteScreen:
        di      
        ld      (pasteTempSP), sp       ; Optimization, self modifying code

        calculateRow    b

        ex      de, hl                  ; Buffer address into hl

        srl     c                       ; Divide the screen x pixel
        srl     c                       ; position by 8 to get the
        srl     c                       ; byte address.
        ld      b, PLAYER_HEIGHT
pasteloop:
        pop     de                      ; get screen row destination adress
        ld      a, e
        add     c                       ; add x offset
        ld      e, a

        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here
        ldi                             ; Optimization to save 4 cycles
        inc     bc                      ; The ldi will decrement bc so increment it here

        ld      a, (hl)
        ld      (de), a
        inc     hl
        djnz    pasteloop

pasteTempSP equ $+1
        ld      sp, 0x0000
        ei      

        ret     

        ;
        ; Entry:
		;		b  - Screen y location
		;		c  - Screen x location
        ;
_displaySprite:
        di      
        ld      (displaySpriteSP), sp

        ; Calculate the offset into the screen table
        ld      l, b
        ld      h, 0
        add     hl, hl                  ; multiply by 2
        ld      de, _screenTab
        add     hl, de
        push    hl
        exx     
        pop     hl
        exx     

        ld      a, c
        and     0x07                    ; Get the sprite shift index
        ld      l, a
        ld      h, 0
        ; Multiple by 96
        hlx     32
        ld      de, hl                  ; Save 32x
        hlx     2                       ; 64x
        add     hl, de                  ; Add 32x
        ld      de, (playerSprite)
        add     hl, de
        ld      (spriteStore), hl

        srl     c                       ; Divide the screen x pixel
        srl     c                       ; position by 8 to get the
        srl     c                       ; byte address.
        ld      b, PLAYER_HEIGHT
loop2:
        exx     
        ld      sp, hl
        inc     hl
        inc     hl
        exx     
        pop     hl
        ld      a, l
        add     c                       ; add x offset
        ld      l, a

spriteStore equ $+1
        ld      sp, 0x0000              ; Get the sprite pointer

        pop     de                      ; Pop sprite data
        ld      a, (hl)                 ; Read the screen contents
        and     e                       ; and with mask
        or      d                       ; or with sprite data
        ld      (hl), a                 ; save it back to the screen
        inc     l                       ; Next screen position to the right

        pop     de
        ld      a, (hl)
        and     e
        or      d
        ld      (hl), a
        inc     l

        pop     de
        ld      a, (hl)
        and     e
        or      d
        ld      (hl), a

        ld      (spriteStore), sp

        djnz    loop2
displaySpriteSP equ $+1
        ld      sp, 0x0000
        ei      

        ret     

        section bss_user
playerSprite:
        dw      0
