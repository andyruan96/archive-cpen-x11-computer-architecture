/*
 * OutGraphicsCharFont2.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef OUTGRAPHICSCHARFONT2_H_
#define OUTGRAPHICSCHARFONT2_H_
#endif /* OUTGRAPHICSCHARFONT2_H_ */


#define FONT2_XPIXELS	10				// width of Font2 characters in pixels (no spacing)
#define FONT2_YPIXELS	14				// height of Font2 characters in pixels (no spacing)

#define YRES 480
#define XRES 800
#define TRUE 1
#define FALSE 0
extern const unsigned int Font10x14[95][14];
extern const unsigned char Font16x27[95][27];

void OutGraphicsCharFont2(int x, int y, int colour, int backgroundcolour, int c, int Erase);
