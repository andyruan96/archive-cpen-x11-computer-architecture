/*
 * door_mechanism.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef DOOR_MECHANISM_H_
#define DOOR_MECHANISM_H_

#endif /* DOOR_MECHANISM_H_ */

#define DoorLock (*(volatile unsigned char *)(0x80000020))

void unlock_door(void);
void lock_door(void);
