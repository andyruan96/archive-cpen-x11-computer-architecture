/*
 * DemoGraphicsRoutines.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef DEMOGRAPHICSROUTINES_H_
#define DEMOGRAPHICSROUTINES_H_
#endif /* DEMOGRAPHICSROUTINES_H_ */

#define TRUE 1
#define FALSE 0
// #defined constants representing values we write to the graphics 'command' register to get
// it to do something. You will add more values as you add hardware to the graphics chip
// Note DrawHLine, DrawVLine and DrawLine at the moment do nothing - you will modify these

#define DrawHLine		1
#define DrawVLine		2
#define DrawLine		3
#define PutAPixel		0xA
#define GetAPixel		0xB
#define ProgramPaletteColour   	0x10
#define ClearScreen		4
#define DrawRec			5
#define FillRec			6

/*******************************************************************************************
** This macro pauses until the graphics chip status register indicates that it is idle
*******************************************************************************************/

#define WAIT_FOR_GRAPHICS		while((GraphicsStatusReg & 0x0001) != 0x0001);

//Predefined Colour Values
//Use the symbolic constants below as the values to write to the Colour Register
//When you ask the graphics chip to draw something. These values are also returned
//By the read pixel command

// the header file "Colours.h" contains symbolic names for all 256 colours e.g. RED
// while the source file ColourPaletteData.c contains the 24 bit RGB data
// that is pre-programmed into each of the 256 palettes

#define	BLACK		0
#define	WHITE		1
#define	RED			2
#define	LIME		3
#define	BLUE		4
#define	YELLOW		5
#define	CYAN		6
#define	MAGENTA		7


#define GraphicsCommandReg   		(*(volatile unsigned short int *)(0x84000000))
#define GraphicsStatusReg   		(*(volatile unsigned short int *)(0x84000000))
#define GraphicsX1Reg   			(*(volatile unsigned short int *)(0x84000002))
#define GraphicsY1Reg   			(*(volatile unsigned short int *)(0x84000004))
#define GraphicsX2Reg   			(*(volatile unsigned short int *)(0x84000006))
#define GraphicsY2Reg				(*(volatile unsigned short int *)(0x84000008))
#define GraphicsColourReg			(*(volatile unsigned short int *)(0x8400000E))
#define GraphicsBackGroundColourReg   		(*(volatile unsigned short int *)(0x84000010))

void WriteAPixel (int x, int y, int Colour);
int ReadAPixel (int x, int y);
void ProgramPalette(int PaletteNumber, int RGB);
void HLine(int x1, int y1, int length, int Colour);
void VLine(int x1, int y1, int length, int Colour);
void Line(int x1, int y1, int x2, int y2, int Colour);
void clear_all(void);
void draw_rectangle(int x1, int y1, int xlength, int ylength, int Colour);
void fill_rectangle(int x1, int y1, int xlength, int ylength, int Colour);
