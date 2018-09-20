/*
 * OutGraphicsCharFont3.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef OUTGRAPHICSCHARFONT3_H_
#define OUTGRAPHICSCHARFONT3_H_



#endif /* OUTGRAPHICSCHARFONT3_H_ */

#define YRES 480
#define XRES 800
#define TRUE 1
#define FALSE 0
extern const unsigned char Font16x27[95][54];

void OutGraphicsCharFont3(int x, int y, int fontcolour, int backgroundcolour, int c, int Erase);
