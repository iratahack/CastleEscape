#include <stdio.h>
#include <intrinsic.h>
#include <arch/zx.h>

#define ATTRIB_EDIT
#ifdef ATTRIB_EDIT
extern const unsigned char tile0[];
extern const unsigned char tileAttr[];
extern void attribEdit(unsigned char *tileset, unsigned char *attrib);
extern  void setupScreen();
#endif

extern unsigned char keyboardScan(void);

extern void gameMain(void)
__z88dk_fastcall;
extern void gameLoop()
__z88dk_fastcall;

int main()
{
    char key = 0;

    gameMain();

    while ((key = keyboardScan()) != '\n')
    {
        gameLoop();

#ifdef ATTRIB_EDIT
        if (key == 'S')
        {
            attribEdit(tile0, tileAttr);
            setupScreen();
        }
#endif
    }

    intrinsic_di();
    return (0);
}
