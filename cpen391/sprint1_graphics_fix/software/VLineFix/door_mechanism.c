/*
 * door_mechanism.c
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */
#include "door_mechanism.h"

void unlock_door(void){
	DoorLock = 0;
};

void lock_door(void){
	DoorLock = 1;
};
