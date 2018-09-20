/*
 * doorbell.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef DOORBELL_H_
#define DOORBELL_H_

#endif /* DOORBELL_H_ */

#define TRUE 1
#define FALSE 0

#define DoorbellControl (*(volatile unsigned short int *)(0x00000010))

void ring_doorbell(int val);
