/*
 * gui.h
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#ifndef GUI_H_
#define GUI_H_

#endif /* GUI_H_ */

#define TRUE 1
#define FALSE 0
#define MAX_MSG_SIZE	16

void draw_main_helper(void);
void draw_main(void);
void clear_main(void);
void draw_keypad(void);
void clear_keypad(void);
void draw_main_unlocked(void);
void clear_main_unlocked(void);
void draw_incorrect_pin(void);
void clear_incorrect_pin(void);

void draw_settings(void);
