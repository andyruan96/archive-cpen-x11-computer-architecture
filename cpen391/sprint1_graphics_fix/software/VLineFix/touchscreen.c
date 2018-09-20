#define TS_Control (*(volatile unsigned char *)(0x84000230))
#define TS_Status (*(volatile unsigned char *)(0x84000230))
#define TS_TxData (*(volatile unsigned char *)(0x84000232))
#define TS_RxData (*(volatile unsigned char *)(0x84000232))
#define TS_Baud (*(volatile unsigned char *)(0x84000234))

#include <stdio.h>
#include "touchscreen.h"

// xmin = 162
// xmax = 3884
// ymin = 420
// ymax = 3855
//
// xmid = 1954
// ymid = 1969

/*****************************************************************************
** Initialise touch screen controller
*****************************************************************************/
void Init_Touch(void)
{
 // Program 6850 and baud rate generator to communicate with touchscreen
 // send touchscreen controller an "enable touch" command
		TS_Control = 0x03; // reset device
		TS_Control = 0x15; // 0b0 00 101 01, no reciever interrupt, rts low no transmitter interrupt, 8 data no parity 1 stop, 16 divide
		TS_Baud = 0x5;	// set baud to 9600k

		int i = 0;
		for(i = 0; i<3000000; i++);
		// Send touchscreen controller an "enable touch" command 0x55, 0x01, 0x12
		while( !(TS_Status & 0x02) );
		TS_TxData = 0x55;
		while( !(TS_Status & 0x02) );
		TS_TxData = 0x01;
		while( !(TS_Status & 0x02) );
		TS_TxData = 0x12;
}

/*****************************************************************************
** test if screen touched
*****************************************************************************/
int ScreenTouched( void )
{
 // return TRUE if any data received from 6850 connected to touchscreen
 // or FALSE otherwise
	return (TS_Status & 0x01);
}

/*****************************************************************************
** wait for screen to be touched
*****************************************************************************/
// return 1 for press and 0 for release
int WaitForTouch()
{
RETRY:
	while(!ScreenTouched());
	unsigned char eventType = TS_RxData;
	//printf("%x ", eventType);
	if (eventType != 0x80 && eventType != 0x81) goto RETRY;
	return (eventType == 0x81);
}

/* a data type to hold a point/coord */

int getCharTS(){
	while(!(TS_Status & 0x01));
	return TS_RxData;
}

Point readPointData()
{
	Point p;
	unsigned char buffer[4];

	buffer[0] = getCharTS() & 0x3F;
	buffer[1] = getCharTS() & 0x1F;
	buffer[2] = getCharTS() & 0x3F;
	buffer[3] = getCharTS() & 0x1F;

	//printf("[%x,%x,%x,%x] ", buffer[0], buffer[1], buffer[2], buffer[3]);

	int x_raw, y_raw;

	x_raw = ( ((buffer[1] << 7) | buffer[0]) & 0x0FFF );
	y_raw = ( ((buffer[3] << 7) | buffer[2]) & 0x0FFF );

	p.x_raw = x_raw;
	p.y_raw = y_raw;

	p.x = x_raw / 4.65 - 30; 	//4.65
	p.y = y_raw / 7.16 - 60;		//7.16
	return p;
}

/*****************************************************************************
* This function waits for a touch screen press event and returns X,Y coord
*****************************************************************************/
Point GetPress(void)
{
	// wait for a pen down command then return the X,Y coord of the point
	// calibrated correctly so that it maps to a pixel on screen
	//WaitForTouch();
	return readPointData();
}

/*****************************************************************************
* This function waits for a touch screen release event and returns X,Y coord
*****************************************************************************/
Point GetRelease(void)
{
	// wait for a pen down command then return the X,Y coord of the point
	// calibrated correctly so that it maps to a pixel on screen
	//WaitForTouch();
	return readPointData();
}
