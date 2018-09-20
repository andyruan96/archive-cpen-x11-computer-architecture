/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include "DemoGraphicsRoutines.h"
/**********************************************************************
* This function writes a single pixel to the x,y coords specified in the specified colour
* Note colour is a palette number (0-255) not a 24 bit RGB value
**********************************************************************/
void WriteAPixel (int x, int y, int Colour)
{
	WAIT_FOR_GRAPHICS;			// is graphics ready for new command

	GraphicsX1Reg = x;			// write coords to x1, y1
	GraphicsY1Reg = y;
	GraphicsColourReg = Colour;		// set pixel colour with a palette number
	GraphicsCommandReg = PutAPixel;		// give graphics a "write pixel" command
}

/*****************************************************************************************
* This function read a single pixel from x,y coords specified and returns its colour
* Note returned colour is a palette number (0-255) not a 24 bit RGB value
******************************************************************************************/
int ReadAPixel (int x, int y)
{
	WAIT_FOR_GRAPHICS;			// is graphics ready for new command

	GraphicsX1Reg = x;			// write coords to x1, y1
	GraphicsY1Reg = y;
	GraphicsCommandReg = GetAPixel;		// give graphics a "get pixel" command

	WAIT_FOR_GRAPHICS;			// is graphics done reading pixel
	return (int)(GraphicsColourReg) ;		// return the palette number (colour)
}

/****************************************************************************************************
** subroutine to program a hardware (graphics chip) palette number with an RGB value
** e.g. ProgramPalette(RED, 0x00FF0000) ;
****************************************************************************************************/

void ProgramPalette(int PaletteNumber, int RGB)
{
    WAIT_FOR_GRAPHICS;
    GraphicsColourReg = PaletteNumber;
    GraphicsX1Reg = RGB >> 16   ;          // program red value in ls.8 bit of X1 reg
    GraphicsY1Reg = RGB ;                	 // program green and blue into 16 bit of Y1 reg
    GraphicsCommandReg = ProgramPaletteColour;	// issue command
}

/*********************************************************************************************
This function draw a horizontal line, 1 pixel at a time starting at the x,y coords specified
*********************************************************************************************/

void HLine(int x1, int y1, int length, int Colour)
{
	/*int i;

	for(i = x1; i < x1+length; i++ )
		WriteAPixel(i, y1, Colour);
	*/
	WAIT_FOR_GRAPHICS;
	GraphicsColourReg = Colour;
	GraphicsX1Reg = x1;
	GraphicsY1Reg = y1;
	GraphicsX2Reg = x1 + length;
	GraphicsCommandReg = DrawHLine;
}

/*********************************************************************************************
This function draw a vertical line, 1 pixel at a time starting at the x,y coords specified
*********************************************************************************************/
// broken atm
void VLine(int x1, int y1, int length, int Colour)
{
	/*int i;

	for(i = y1; i < y1+length; i++ )
		WriteAPixel(x1, i, Colour);
	*/
	WAIT_FOR_GRAPHICS;
	GraphicsColourReg = Colour;
	GraphicsX1Reg = x1;
	GraphicsY1Reg = y1;
	GraphicsY2Reg = y1 + length;
	//printf("%d %d %d\n", y1, y1+length, GraphicsY2Reg);
	GraphicsCommandReg = DrawVLine;
}

void Line(int x1, int y1, int x2, int y2, int Colour)
{
	WAIT_FOR_GRAPHICS;
	GraphicsColourReg = Colour;
	GraphicsX1Reg = x1;
	GraphicsY1Reg = y1;
	GraphicsX2Reg = x2;
	GraphicsY2Reg = y2;
	GraphicsCommandReg = DrawLine;

}

void clear_all (){
	/*int i = 0;
	while(i < 480) {
		HLine(0,i,800,BLACK);
		i++;
	}
	*/
	//printf("WaitForGraphics\n");
	WAIT_FOR_GRAPHICS;
	//printf("Clearing Screen\n");
	GraphicsColourReg = BLACK;
	GraphicsX1Reg = 0x0000;
	GraphicsY1Reg = 0x0000;
	GraphicsX2Reg = 0x0320;
	GraphicsY2Reg = 0x01E0;
	GraphicsCommandReg = ClearScreen;
}

void draw_rectangle(int x1, int y1, int xlength, int ylength, int Colour){
	WAIT_FOR_GRAPHICS;
	GraphicsColourReg = Colour;
	GraphicsX1Reg = x1;
	GraphicsY1Reg = y1;
	GraphicsX2Reg = x1 + xlength;
	GraphicsY2Reg = y1 + ylength;
	GraphicsCommandReg = DrawRec;
}

void fill_rectangle(int x1, int y1, int xlength, int ylength, int Colour){
	WAIT_FOR_GRAPHICS;
	GraphicsColourReg = Colour;
	GraphicsX1Reg = x1;
	GraphicsY1Reg = y1;
	GraphicsX2Reg = x1 + xlength;
	GraphicsY2Reg = y1 + ylength;
	GraphicsCommandReg = FillRec;
}
