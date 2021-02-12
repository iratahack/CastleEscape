        extern  AFXPLAY
        extern  die
        extern  rand
        extern  _currentTileMap

        public  spiderCollision
        public  spiderTables
        public  spiders
        public  currentSpiderTable
        public  updateSpiderPos

        include "defs.inc"

        section code_user

updateSpiderPos:
        ld      hl, (currentSpiderTable)
        ld      a, (changeSpiderDir)
        inc     a
        ld      (changeSpiderDir), a
        cp      25
        jr      c, updatePosition

        xor     a
        ld      (changeSpiderDir), a

nextSpider:
        ld      a, (hl)                 ; Flags
        cp      0xff
        ret     z

        push    hl

        call    rand
        ld      a, l

        cp      110
        jr      nc, down
		; a >= val
        ld      b, UP<<4
        jr      done
down:
        cp      220
        jr      nc, stop
		; a >= val
        ld      b, DOWN<<4
        jr      done
stop:
		; a < val
        ld      b, 0
done:
        pop     hl

        ld      a, (hl)                 ; OR the direction bits
        and     %00001111               ; into the item flags
        or      b                       ; and save the flags.
        ld      (hl), a

        ld      de, SIZEOF_item
        add     hl, de
        jr      nextSpider

updatePosition:
        ld      a, (hl)                 ; Flags
        cp      0xff                    ; Check for end of list
        ret     z                       ; return if true.

        push    hl                      ; Save item pointer

        inc     hl                      ; Skip flags
        ld      c, (hl)                 ; Get x position
        inc     hl
        ld      b, (hl)                 ; Get y position

        bit     UP_BIT+4, a
        jr      z, down2
        ld      a, 24                   ; If the spider is at the top
        cp      b                       ; of the screen it can't move
        jr      z, collision            ; up any more, same as a collision.

        ld      a, -1-24
        add     b

        call    checkCollision
        jr      nz, collision

        ld      a, -1
        jr      done2
down2:
        bit     DOWN_BIT+4, a
        jr      z, stop2
        ld      a, MAX_Y_POS-8          ; IF the spider is at the bottom
        cp      b                       ; of the screen it can't move
        jr      z, collision            ; treat same as collision.

        ld      a, 8-24
        add     b

        call    checkCollision
        jr      nz, collision

        ld      a, 1
        jr      done2
stop2:
        ld      a, 0
done2:
        add     (hl)                    ; move
        ld      (hl), a                 ; Store y position
collision:
        pop     hl
        ld      de, SIZEOF_item
        add     hl, de
        jr      updatePosition

		;
		; Check if a spider has collided with a tile.
		;
		; Entry:
		;		a - Spider y pixel position
		;		c - Spider x pixel position
		;
		; Exit:
		;		nz - Collision detected.
		;
checkCollision:
        push    hl
        srl     c
        srl     c
        srl     c

        rrca    
        rrca    
        rrca    
        and     %00011111

        ld      l, a
        ld      h, 0
		;
		; Multiply by TILEMAP_WIDTH
		;
        hlx     TILEMAP_WIDTH
        ld      de, (_currentTileMap)
        add     hl, de
        ld      b, 0
        add     hl, bc                  ; Add the X character offset

        ld      a, (hl)                 ; Read tile ID
        cp      ID_BLANK                ; If it's blank, there is no collision
        jr      z, noCollision
        cp      ID_SPIDER               ; IF not blank is it a spider?
noCollision:
        pop     hl
        ret     

spiderCollision:
        call    die
        ret     

        section bss_user
changeSpiderDir:
        db      0

currentSpiderTable:
        dw      0

spiderTables:
        ds      MAX_LEVEL_X*MAX_LEVEL_Y*SIZEOF_ptr

spiders:
        ds      SIZEOF_item*MAX_SPIDERS*MAX_LEVEL_X*MAX_LEVEL_Y
