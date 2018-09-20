/*
 * touchscreen.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef TOUCHSCREEN_H_
#define TOUCHSCREEN_H_



#endif /* TOUCHSCREEN_H_ */

void Init_Touch(void);

/*****************************************************************************
** test if screen touched
*****************************************************************************/
int ScreenTouched( void );

/*****************************************************************************
** wait for screen to be touched
*****************************************************************************/
// return 1 for press and 0 for release
int WaitForTouch();

/* a data type to hold a point/coord */
typedef struct { int x, y, x_raw, y_raw; } Point ;

int getCharTS();

Point readPointData(void);

/*****************************************************************************
* This function waits for a touch screen press event and returns X,Y coord
*****************************************************************************/
Point GetPress(void);

/*****************************************************************************
* This function waits for a touch screen release event and returns X,Y coord
*****************************************************************************/
Point GetRelease(void);

