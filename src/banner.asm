
        extern  displayTile
        extern  setTileAttr

        public  displayBanner
        public  bannerData

        include "defs.inc"

        section code_user

        defc    BANNER_HEIGHT=0x03

		;
		; Display the in-game banner.
		;
displayBanner:
        push    af
        push    bc
        push    de
        push    hl

        ld      hl, bannerData
        ld      d, 0x00                 ; Initial y position
        ld      c, BANNER_HEIGHT
yLoop:
        ld      e, 0x00                 ; Initial x position
        ld      b, SCREEN_WIDTH
xLoop:
        push    bc                      ; Save the loop counts

        ld      bc, de                  ; Setup the y,x coords for displayTile
        ld      a, (hl)                 ; Get the tile ID
        call    displayTile
        call    setTileAttr

        pop     bc                      ; Restore loop counts

        inc     hl                      ; Point to next tile
        inc     e                       ; Increment x position
        djnz    xLoop

        inc     d                       ; Increment y position
        dec     c
        jr      nz, yLoop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

        section rodata_user
bannerData:
        include "banner.inc"
