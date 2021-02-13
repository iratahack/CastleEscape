        ; -Minimal ayFX player v0.15 06.05.06 ---------------------------;
        ;                                       ;
        ; The simplest effects player. Plays effects on one AY,;
        ; without music in the background. Channel selection priority: if available;
        ; free channels, one of them is selected. If free;
        ; no channels, the longest sounding one is selected. Procedure;
        ; playback uses registers AF, BC, DE, HL, IX. ;
        ;                                       ;
        ; Initialization:                       ;
        ; ld hl, effect bank address            ;
        ; call AFXINIT                          ;
        ;                                       ;
        ; Effect launch:                        ;
        ; ld a, effect number (0..255)          ;
        ; call AFXPLAY                          ;
        ;                                       ;
        ; In the interrupt handler:             ;
        ; call AFXFRAME                         ;
        ;                                       ;
        ; ------------------------------------------------- -------------;

        public  AFXINIT
        public  AFXPLAY
        public  AFXFRAME
        public  afxEnable
        public  AFXSTOP

        ; channel descriptors, 4 bytes per channel:
        ; +0 (2) current address (channel is free if high byte = # 00)
        ; +2 (2) effect sounding time
        ; ...
        section bss_user

afxChDesc:
        DS      3*4
afxEnable:
        db      0

        section code_user

        ; ------------------------------------------------- -------------;
        ; Effects player initialization.        ;
        ; Turns off all channels, sets variables. ;
        ; Input: HL = Effects bank address      ;
        ; ------------------------------------------------- -------------;

AFXINIT:
        inc     hl
        ld      (afxBnkAdr+1), hl       ; save the address of the offset table
AFXSTOP:
        ld      hl, afxChDesc           ; mark all channels as empty
        ld      de, #00ff
        ld      bc, #03fd				; Original value was 0cfd looks like a bug. Changed to 03fd
afxInit0:
        ld      (hl), d
        inc     hl
        ld      (hl), d
        inc     hl
        ld      (hl), e
        inc     hl
        ld      (hl), e
        inc     hl
        djnz    afxInit0

        ld      hl, #ffbf               ; initialize AY
        ld      e, #15
afxInit1:
        dec     e
        ld      b, h
        out     (c), e
        ld      b, l
        out     (c), d
        jr      nz, afxInit1

        ld      (afxNseMix+1), de       ; reset the player variables

        ret     



        ; ------------------------------------------------- -------------;
        ; Play the current frame.               ;
        ; Has no parameters.                    ;
        ; ------------------------------------------------- -------------;

AFXFRAME:
        ld      bc, #03fd
        ld      ix, afxChDesc

afxFrame0:
        push    bc

        ld      a, 11
        ld      h, (ix+1)               ; compare high byte of address by <11
        cp      h
        jr      nc, afxFrame7           ; channel is not playing, skip
        ld      l, (ix+0)

        ld      e, (hl)                 ; take the value of the information byte
        inc     hl

        sub     b                       ; select the volume register:
        ld      d, b                    ; (11-3 = 8, 11-2 = 9, 11-1 = 10)

        ld      b, #ff                  ; display volume value
        out     (c), a
        ld      b, #bf
        ld      a, e
        and     #0f
        out     (c), a

        bit     5, e                    ; will there be a tone change?
        jr      z, afxFrame1            ; tone does not change

        ld      a, 3                    ; select the tone registers:
        sub     d                       ; 3-3 = 0, 3-2 = 1, 3-1 = 2
        add     a, a                    ; 0 * 2 = 0, 1 * 2 = 2, 2 * 2 = 4

        ld      b, #ff                  ; print tone values
        out     (c), a
        ld      b, #bf
        ld      d, (hl)
        inc     hl
        out     (c), d
        ld      b, #ff
        inc     a
        out     (c), a
        ld      b, #bf
        ld      d, (hl)
        inc     hl
        out     (c), d

afxFrame1:
        bit     6, e                    ; will there be a noise change?
        jr      z, afxFrame3            ; noise does not change

        ld      a, (hl)                 ; read noise value
        sub     #20
        jr      c, afxFrame2            ; less than # 20, play on
        ld      h, a                    ; otherwise end of effect
        ld      b, #ff
		; Line below changed from ld b,c -> ld c,b
        ld      c, b                    ; in BC we enter the longest time
        jr      afxFrame6

afxFrame2:
        inc     hl
        ld      (afxNseMix+1), a        ; store the noise value

afxFrame3:
        pop     bc                      ; restore the loop value to B
        push    bc
        inc     b                       ; number of offsets for TN flags

        ld      a, %01101111            ; mask for TN flags
afxFrame4:
        rrc     e                       ; move flags and mask
        rrca    
        djnz    afxFrame4
        ld      d, a

        ld      bc, afxNseMix+2         ; save flag values
        ld      a, (bc)
        xor     e
        and     d
        xor     e                       ; E is masked with D
        ld      (bc), a

afxFrame5:
        ld      c, (ix+2)               ; increase the time counter
        ld      b, (ix+3)
        inc     bc

afxFrame6:
        ld      (ix+2), c
        ld      (ix+3), b

        ld      (ix+0), l               ; save the changed address
        ld      (ix+1), h

afxFrame7:
        ld      bc, 4                   ; go to next channel
        add     ix, bc
        pop     bc
        djnz    afxFrame0

        ld      hl, #ffbf               ; print noise and mixer values
afxNseMix:
        ld      de, 0                   ; +1 (E) = noise, +2 (D) = mixer
        ld      a, 6
        ld      b, h
        out     (c), a
        ld      b, l
        out     (c), e
        inc     a
        ld      b, h
        out     (c), a
        ld      b, l
        out     (c), d

        ret     



        ; ------------------------------------------------- -------------;
        ; Triggers an effect on an unused channel. With absence ;
        ; the most recent sounding channel is selected. ;
        ; Input: A = effect number 0..255       ;
        ; ------------------------------------------------- -------------;

AFXPLAY:
        push    af
        push    bc
        push    de
        push    hl
        push    ix

        ld      de, 0                   ; in DE, longest search time
        ld      h, e
        ld      l, a
        add     hl, hl
afxBnkAdr:
        ld      bc, 0                   ; address of effect offset table
        add     hl, bc
        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        add     hl, bc                  ; effect address received in hl
        push    hl                      ; save the address of the effect on the stack

        ld      hl, afxChDesc           ; search for empty channel
        ld      b, 3
afxPlay0:
        inc     hl
        inc     hl
        ld      a, (hl)                 ; compare the channel time with the longest
        inc     hl
        cp      e
        jr      c, afxPlay1
        ld      c, a
        ld      a, (hl)
        cp      d
        jr      c, afxPlay1
        ld      e, c                    ; remember the longest time
        ld      d, a
        push    hl                      ; remember the channel address + 3 in IX
        pop     ix
afxPlay1:
        inc     hl
        djnz    afxPlay0

        pop     de                      ; pop the effect address from the stack
        ld      (ix-3), e               ; enter into channel descriptor
        ld      (ix-2), d
        ld      (ix-1), b               ; set the sound time to zero
        ld      (ix-0), b

        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     
