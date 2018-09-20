/*************************************************************************************************
** This function draws a single ASCII character at the coord and colour specified
** it optionally ERASES the background colour pixels to the background colour
** This means you can use this to erase characters
**
** e.g. writing a space character with Erase set to true will set all pixels in the
** character to the background colour
**
*************************************************************************************************/
#include "OutGraphicsCharFont3.h"

void OutGraphicsCharFont3(int x, int y, int fontcolour, int backgroundcolour, int c, int Erase)
{
// using register variables (as opposed to stack based ones) may make execution faster
// depends on compiler and CPU

	register int row, row2 = 0, column, theX = x, theY = y ;
	register unsigned int pixels ;
	register char theColour = fontcolour  ;
	register int BitMask, theC = c ;

// if x,y coord off edge of screen don't bother
// XRES and YRES are #defined to be 800 and 480 respectively
    if(((short)(x) > (short)(XRES-1)) || ((short)(y) > (short)(YRES-1)))
        return ;


// if printable character subtract hex 20
	if(((short)(theC) >= (short)(' ')) && ((short)(theC) <= (short)('~'))) {
		theC = theC - 0x20 ;
		for(row = 0; row < 54; row = row +2)	{

// get the bit pattern for row 0 of the character from the software font
			pixels = (Font16x27[theC][row]<<8) | (Font16x27[theC][row+1]) ;
			BitMask = 8192 ;

			for(column = 0; column < 16; column ++)	{

// if a pixel in the character display it
				if((pixels & BitMask))
					WriteAPixel(theX+column, theY+row2, theColour) ;

				else {
					if(Erase == TRUE)

// if pixel is part of background (not part of character)
// erase the background to value of variable BackGroundColour

						WriteAPixel(theX+column, theY+row2, backgroundcolour) ;
				}
				BitMask = BitMask >> 1 ;
			}
			row2++;
		}
	}
}
