#include <arch/zx.h>

extern unsigned char keyboardScan(void)
__z88dk_fastcall;
extern void cls(char attr)
__z88dk_fastcall;
extern unsigned char *screenTab[];

#define TILE_WIDTH      12
#define TILE_HEIGHT     14

/*
 * Current cursor location for displaying text to the screen.
 */
static char cursorX = 0;
static char cursorY = 0;

/*
 * Set the location for the next character printed to the screen.
 */
void setCursor(char x, char y)
{
    cursorX = x;
    cursorY = y;
}
/*
 * Address of the ROM font.
 */
const unsigned char *font = (const unsigned char*) 0x3d00;
/*
 * Start of the screen attribute memory.
 */
unsigned char *attr = (unsigned char*) 0x5800;

/*
 * Display a character using the ROM font at the specified x,y character
 * screen location.
 */
void printChar(unsigned char c, unsigned char x, unsigned char y)
{
    for (char n = 0; n < 8; n++)
    {
        *(screenTab[(y << 3) + n] + x) = font[((c - ' ') << 3) + n];
    }
}

/*
 * Output a string to the screen at the current x,y cursor position.
 */
void putString(unsigned char *string)
{
    while (*string)
    {
        if (*string == '\n')
        {
            cursorX = 0;
            cursorY++;
        }
        else
        {
            printChar(*string, cursorX++, cursorY);
        }
        string++;
    }
}

/*
 * Display the 12x12 tileset starting from the top left-hand side of the
 * screen.
 */
void displayTileset(const unsigned char *tiles)
{
    for (char y = 0; y < TILE_HEIGHT; y++)
    {
        for (char x = 0; x < TILE_WIDTH; x++)
        {
            unsigned char *screenAddr = screenTab[y * 8] + x;
            for (char n = 0; n < 8; n++)
            {
                *screenAddr = *tiles++;
                screenAddr += 0x100;
            }
        }
    }
}

/*
 * Bitmap for the box cursor.
 */
const unsigned char cursor[8] =
{ 0xff, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0xff };

/*
 * Display the box cursor at the current cursor location.
 */
void xorCursor(int x, int y)
{
    unsigned char *screenAddr = screenTab[y * 8] + x;

    for (char n = 0; n < 8; n++)
    {
        *screenAddr ^= cursor[n];
        screenAddr += 0x100;
    }
}

/*
 * Set the ink color for the current cursor location.
 */
void setInk(int x, int y, unsigned char key)
{
    attr[(y * 32) + x] = key - '0';
}

/*
 * Toggle the flash or bright attribute for the current cursor location.
 */
void toggleAttrib(int x, int y, unsigned char attrib)
{
    attr[(y * 32) + x] ^= attrib;
}

/*
 * Save the attributes from the screen to the specified location.
 */
void saveAttrib(unsigned char *dest)
{
    int x;
    int y;

    for (y = 0; y < TILE_HEIGHT; y++)
    {
        for (x = 0; x < TILE_WIDTH; x++)
        {
            *dest++ = attr[(y * 32) + x];
        }
    }
}

/*
 * Load attributes to screen memory from the specified location.
 */
void loadAttrib(unsigned char *src)
{
    int x;
    int y;

    for (y = 0; y < TILE_HEIGHT; y++)
    {
        for (x = 0; x < TILE_WIDTH; x++)
        {
            attr[(y * 32) + x] = *src & 0xc7;
            src++;
        }
    }
}

/*
 * Entry point for tile attribute editing in realtime.
 */
void attribEdit(unsigned char *tileset, unsigned char *attrib)
{
    int x = 0;
    int y = 0;
    unsigned char key;

    cls(INK_WHITE | PAPER_BLACK);
    setCursor(0, TILE_HEIGHT);
    putString("Up          - 'q'\n");
    putString("Down        - 'a'\n");
    putString("Left        - 'o'\n");
    putString("Right       - 'p'\n");
    putString("Bright      - 'b'\n");
    putString("Flash       - 'f'\n");
    putString("Reset       - 'r'\n");
    putString("Ink color   - 0 - 7\n");
    putString("Exit        - <SPACE>\n");

    loadAttrib(attrib);

    displayTileset(tileset);

    xorCursor(x, y);

    do
    {
        // Wait for key press
        while ((key = keyboardScan()) == 0)
            ;

        switch (key)
        {
        case 'P':                           // Right
            xorCursor(x, y);
            if (x < (TILE_WIDTH-1))
                x++;
            xorCursor(x, y);
            break;
        case 'O':                           // Left
            xorCursor(x, y);
            if (x > 0)
                x--;
            xorCursor(x, y);
            break;
        case 'Q':                           // Up
            xorCursor(x, y);
            if (y > 0)
                y--;
            xorCursor(x, y);
            break;
        case 'A':                           // Down
            xorCursor(x, y);
            if (y < (TILE_HEIGHT-1))
                y++;
            xorCursor(x, y);
            break;
        default:
            if (key >= '0' && key <= '7')   // Colors
            {
                setInk(x, y, key);
            }
            else if (key == 'B')            // Bright
            {
                toggleAttrib(x, y, BRIGHT);
            }
            else if (key == 'F')            // Flash
            {
                toggleAttrib(x, y, FLASH);
            }
            else if (key == 'R')            // Reset
            {
                loadAttrib(attrib);
            }
            break;
        }

        // Wait for key release
        while (keyboardScan() != 0)
            ;
    } while (key != ' ');                   // SPACE to exit
    /*
     * Copy the attributes to spare memory so they can be dumped.
     */
    saveAttrib((unsigned char*) 0xb000);

    /*
     * Copy the attributes back to their original location so
     * they can be reflected in the game.
     */
    saveAttrib(attrib);
}
