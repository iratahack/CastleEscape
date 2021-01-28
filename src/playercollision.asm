        extern  _xPos
        extern  _yPos
        extern  _xSpeed
        extern  _ySpeed
        extern  _currentTileMap
        extern  _setupScreen
        extern  _tileMapX
        extern  _tileMapY
        extern  _jumping
        extern  _falling

        public  checkXCol
        public  checkYCol

        include "defs.asm"
        section code_user

        defc    ID_SOLID_TILE=139
        ;
        ; Check for player colliding with solid platforms on
        ; the X axis and if the player is going off the screen
        ; to the left or right display the next or previous
        ; screen.
        ;
        ; Entry:
        ;		a - xSpeed
        ;
checkXCol:
        ld      b, a                    ; Save xSpeed
        ld      hl, (_yPos)             ; Get the yPos it has already been updated by checkYCol
        ld      a, -24                  ; Subtract the delta between the screen offset and the level offset
        add     l                       ; Add the current y position
        ld      c, a                    ; save it in 'c'

        and     %11111000               ; Remove the pixel offset within the byte (lower 3 bits)
        ld      l, a
        hlx     TILEMAP_WIDTH/8         ; Divide by 8 to get byte offset and multiply by 128 (width of tilemap)

        ld      de, (_xPos)             ; Get the X pixel offset
        ld      a, b                    ; speed may be positive or negative
        or      a                       ; Update flags
        jp      p, pos2                 ; If positive
        dec     d                       ; else negative, subtract 1 from hi-order byte
pos2:
        addde                           ; Add 'a'

        ld      a, b                    ; Get speed again
        or      a                       ; Update flags
        jp      m, neg1                 ; If negative
        ld      a, PLAYER_WIDTH-1       ; else add player width
        addde   
neg1:
        ; Divide by 8 to get byte offset
        ld      a, e
        sra     d                       ; SRA leaves the sign bit (bit-7) intact. Good for signed shifts.
        rra     
        sra     d
        rra     
        sra     d
        rra     
        ld      e, a
        add     hl, de                  ; Add X byte offset to tile map Y index

        ld      de, (_currentTileMap)
        add     hl, de
        ld      a, (hl)
        cp      ID_SOLID_TILE
        ret     nc                      ; 'nc' if a >= 144

        ; Check the bottom half of the sprite
        ld      de, TILEMAP_WIDTH
        add     hl, de
        ld      a, (hl)
        cp      ID_SOLID_TILE
        ret     nc                      ; 'nc' if a >= 144

        ld      a, c                    ; Restore yPos + ySpeed
        and     %00000111               ; If the lower 3 bits are zero player has not shifted into
        jr      z, checkXDone           ; the next row down, return.
        add     hl, de                  ; Next row down

        ld      a, (hl)
        cp      ID_SOLID_TILE
        ret     nc                      ; 'nc' if a >= 144

checkXDone:
        ld      a, (_xPos)              ; Get the X pixel offset
        add     b                       ; Add speed
        cp      0xff                    ; If new xPos is negative
        jr      z, previousXLevel       ; display previous level.
        cp      MAX_X_POS-PLAYER_WIDTH+1
        jr      nc, nextXLevel          ; 'nc' if a > MAX_X_POS - PLAYER_WIDTH
        ld      (_xPos), a
        ret     

previousXLevel:
        ld      a, (_tileMapX)
        or      a
        ret     z
        dec     a
        ld      (_tileMapX), a
        ld      a, MAX_X_POS-PLAYER_WIDTH
        jr      changeXLevel
nextXLevel:
        ld      a, (_tileMapX)
        cp      MAX_LEVEL_X-1
        ret     z
        inc     a
        ld      (_tileMapX), a
        xor     a
changeXLevel:
        ld      (_xPos), a
        call    _setupScreen
        ret     

        ;
        ; Check for player colliding with solid platforms on
        ; the Y axis and if the player is going off the screen
        ; to the top or bottom display the next or previous
        ; screen.
        ;
        ; Entry:
        ;
        ;
checkYCol:
        ld      a, (_ySpeed)            ; If jumping up ySpeed is negative,
        or      a                       ; there is no gravity,
        jp      m, moveUp               ; move up.

        ld      a, (_yPos)
        add     PLAYER_HEIGHT-24        ; Subtract the delta between the screen offset and the level offset
        and     %11111000               ; Remove the pixel offset within the byte (lower 3 bits)
        ld      l, a
        ld      h, 0
        hlx     TILEMAP_WIDTH/8         ; Divide by 8 to get byte offset and multiply by width of tilemap

        ld      a, (_xPos)              ; Get the X pixel offset
        ld      b, a                    ; Save pixel offset for later
        rrca                            ; Divide by 8 to get the byte offset
        rrca                            ; Faster to do rrca followed by AND rather than srl
        rrca    
        and     %00011111
        addhl                           ; Add X byte offset to tile map Y index

        ld      de, (_currentTileMap)
        add     hl, de

        ld      a, (hl)                 ; Get tile ID
        cp      ID_SOLID_TILE
        jr      nc, landed              ; 'nc' if a >= 144

        inc     hl                      ; Next tile to the right
        ld      a, (hl)                 ; Get tile ID
        cp      ID_SOLID_TILE
        jr      nc, landed              ; 'nc' if a >= 144

        ld      a, b                    ; Restore X pixel offset
        and     %00000111               ; Check if any of the lower 3 bits are set
        jr      z, gravity              ; if not we are done
        inc     hl                      ; Check the tile to the right
        ld      a, (hl)
        cp      ID_SOLID_TILE
        jr      c, gravity              ; 'c' if a < 144

landed:
        ;
        ; Reset ySpeed and jumping count and falling flag
        ;
        xor     a
        ld      (_ySpeed), a
        ld      (_jumping), a
        ld      (_falling), a
        ret     

gravity:
        ld      a, (_jumping)           ; Check if player is in
        or      a                       ; downward jump and
        jr      nz, moveDown            ; if so just return.

        ;
        ; Transition to falling.
        ;  Clear X movement.
        ;  set ySpeed to 1 (down).
        ;  set the falling flag.
        xor     a
        ld      (_xSpeed), a
        inc     a
        ld      (_ySpeed), a
        ld      (_falling), a
moveDown:
        ld      a, (_yPos)
        inc     a
        cp      MAX_Y_POS-PLAYER_HEIGHT-1
        jr      nc, nextYLevel
        ld      (_yPos), a
        ret     

moveUp:
        ld      a, (_yPos)
        dec     a
        cp      24
        jr      c, previousYLevel       ; 'c' if 'a' < 24

        add     -24                     ; Subtract the delta between the screen offset and the level offset
        and     %11111000               ; Remove the pixel offset within the byte (lower 3 bits)
        ld      l, a
        ld      h, 0
        hlx     TILEMAP_WIDTH/8         ; Divide by 8 to get byte offset and multiply by width of tilemap

        ld      a, (_xPos)              ; Get the X pixel offset
        ld      b, a                    ; Save pixel offset for later
        rrca                            ; Divide by 8 to get the byte offset
        rrca                            ; Faster to do rrca followed by AND rather than srl
        rrca    
        and     %00011111
        addhl                           ; Add X byte offset to tile map Y index

        ld      de, (_currentTileMap)
        add     hl, de

        ld      a, (hl)                 ; Get tile ID
        cp      ID_SOLID_TILE
        ret     nc                      ; 'nc' if a >= 144

        inc     hl                      ; Next tile to the right
        ld      a, (hl)                 ; Get tile ID
        cp      ID_SOLID_TILE
        ret     nc                      ; 'nc' if a >= 144

        ld      a, b                    ; Restore X pixel offset
        and     %00000111               ; Check if any of the lower 3 bits are set
        jr      z, up                   ; if not we are done
        inc     hl                      ; Check the tile to the right
        ld      a, (hl)
        cp      ID_SOLID_TILE
        ret     nc                      ; 'nc' if a >= 144

up:
        ld      a, (_yPos)
        dec     a
        ld      (_yPos), a
        ret     

previousYLevel:
        ld      a, (_tileMapY)
        or      a
        ret     z
        ;
        ; Check for a gap in the tiles above
        ;
        ld      de, (_currentTileMap)
        ld      hl, -TILEMAP_WIDTH      ; Get previous tile row
        add     hl, de

        ld      a, (_xPos)              ; Get the X pixel offset
        ld      b, a                    ; Save pixel offset for later
        rrca                            ; Divide by 8 to get the byte offset
        rrca                            ; Faster to do rrca followed by AND rather than srl
        rrca    
        and     %00011111
        addhl                           ; Add X byte offset to tile map Y index

        ld      a, (hl)                 ; Get tile ID
        cp      144
        ret     nc                      ; 'nc' if a >= 144

        inc     hl
        ld      a, (hl)                 ; Get tile ID
        cp      144
        ret     nc                      ; 'nc' if a >= 144

        ld      a, b                    ; Restore X pixel offset
        and     %00000111               ; Check if any of the lower 3 bits are set
        jr      z, prev                 ; if not we are done
        inc     hl                      ; Check the tile to the right
        ld      a, (hl)
        cp      144
        ret     nc                      ; 'nc' if a >= 144
prev:
        ld      a, (_tileMapY)
        dec     a
        ld      (_tileMapY), a
        ld      a, MAX_Y_POS-PLAYER_HEIGHT
        jr      changeYLevel
nextYLevel:
        ld      a, (_tileMapY)
        cp      MAX_LEVEL_Y-1
        ret     z
        inc     a
        ld      (_tileMapY), a
        ld      a, 24
changeYLevel:
        ld      (_yPos), a
        call    _setupScreen
        ret     
