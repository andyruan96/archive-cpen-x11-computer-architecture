/*
 * doorbell.c
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#include "doorbell.h"

void ring_doorbell(int val){
	DoorbellControl = val;
}
