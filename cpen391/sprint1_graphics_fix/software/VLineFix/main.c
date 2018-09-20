#include <stdio.h>
#include <time.h>
#include "ColourPallette.h"
#include "Colours.h"
#include "touchscreen.h"
#include "DemoGraphicsRoutines.h"
#include "OutGraphicsCharFont1.h"
#include "gui.h"
#include "doorbell.h"
#include "door_mechanism.h"

#define DOORBELL_RINGING_TIME 5000
#define TIMEOUT 2000

#define TRUE 1
#define FALSE 0

#define MAIN 0;
#define KEYPAD 1;
#define MAIN_UNLOCKED 2;


int doorbell_time_saved = 0;
int doorbell_status = FALSE;

int mode = MAIN;
int mode_switched = FALSE;

char pin_buffer[4] = {'\0', '\0', '\0', '\0'};
char pin[4] = {'1','1','1','1'};
int skip_ts_data = 1;

int mode_main(){
	Point p;
	int temp_time = clock();

RETRY:
	while(!ScreenTouched()){
		if(clock() - temp_time > TIMEOUT) goto SKIP;
	}

	if(WaitForTouch()){
		p = GetRelease();
		goto RETRY;
	}

	if(p.x < 400 && p.y < 240){
		mode = KEYPAD;
		mode_switched = TRUE;
		clear_main();
	}
	else if(p.x < 400 && p.y > 240){
		// door bell code here
		printf("ringing doorbell");
		ring_doorbell(TRUE);
		doorbell_status = TRUE;
		doorbell_time_saved = clock();
	}
SKIP:
	return mode;
}

char get_input (Point p) {
	if (p.x < 333 && p.x > 200 && p.y < 120)
		return '1';
	else if (p.x > 333 && p.x < 467 && p.y < 120)
		return '2';
	else if (p.x > 467 && p.x < 600 && p.y < 120)
		return '3';
	else if (p.x > 200 && p.x < 333 && p.y > 120 && p.y < 240)
		return '4';
	else if (p.x > 333 && p.x < 467 && p.y > 120 && p.y < 240)
		return '5';
	else if (p.x > 467 && p.x < 600 && p.y > 120 && p.y < 240)
		return '6';
	else if (p.x > 200 && p.x < 333 && p.y > 240 && p.y < 360)
		return '7';
	else if (p.x > 333 && p.x < 467 && p.y > 240 && p.y < 360)
		return '8';
	else if (p.x > 467 && p.x < 600 && p.y > 240 && p.y < 360)
		return '9';
	else if (p.x > 200 && p.x < 333 && p.y > 360)
		return '*';
	else if (p.x > 333 && p.x < 467 && p.y > 360)
		return '0';
	else if (p.x > 467 && p.x < 600 && p.y > 360)
		return '#';
	else return 'z';
}

int unlock(char entered_pin[4]) {
	int i = 0;
	for (i = 0; i < 4; i++) {
		if (entered_pin[i] != pin[i])
		return -1;
	}
	// TODO: pin is correct, unlock door
	return 0;
}

int mode_keypad(){
	char input;
	Point p;
	while(WaitForTouch())
		p = GetRelease();
	//p = GetRelease();

	printf("(%d, %d)\n", p.x, p.y);
	if(p.x < 200){
		mode = MAIN;
		mode_switched = TRUE;
		clear_keypad();
		int i;
		for (i = 0; i < 4; i++)
			pin_buffer[i] = '\0';
	}

	else if (p.x > 600 && p.x < 800) {
		int lock = unlock(pin_buffer);
		if (lock == -1){
			printf("incorrect pin\n");
			/*
			//draw_incorrect_pin();
			draw_main();
			int temp_time = clock();
			while(clock() - temp_time < 1500);

			printf("try again\n");
			//clear_incorrect_pin();
			clear_main();
			draw_keypad();*/
		}
		else if (lock == 0){
			printf("correct pin, door unlocked\n");
			unlock_door();
			mode = MAIN_UNLOCKED;
			mode_switched = TRUE;
			clear_keypad();
		}
		int i;
		for (i = 0; i < 4; i++)
			pin_buffer[i] = '\0';
	}

	else {
		if (skip_ts_data == 0) {
			input = get_input(p);
			if (input != 'z') {
				int i;
				for (i = 0; i < 4; i++) {
					if (pin_buffer[i] == '\0') {
						pin_buffer[i] = input;
						printf("Inputed %c into buffer\n", input);
						break;
					}
					else if (i == 3) {
						printf("buffer is full\n");
					}
				}
			}
			skip_ts_data = 1;
		}
		else
			skip_ts_data = 0;
	}
	//p = GetRelease();
	return mode;
}

int mode_main_unlocked(){
	Point p;
	int temp_time = clock();

RETRY:
	while(!ScreenTouched()){
		if(clock() - temp_time > TIMEOUT) goto SKIP;
	}

	if(WaitForTouch()){
		p = GetRelease();
		goto RETRY;
	}

	if(p.x < 400 && p.y < 240){
		mode = MAIN;
		mode_switched = TRUE;
		lock_door();
		clear_main_unlocked();
	}
	else if(p.x < 400 && p.y > 240){
		// door bell code here
		printf("ringing doorbell");
		ring_doorbell(TRUE);
		doorbell_status = TRUE;
		doorbell_time_saved = clock();
	}
SKIP:
	return mode;
}


int main() {
	printf("Hello from Nios2\n");
	int randX, randY, randXLen, randYLen, func, colour;

	clear_all();
	//Line(10, 10, 400, 400, RED);

	while(1){
		colour = rand() % 8;
		randX = rand() % 800;
		randY = rand() % 480;
		randXLen = rand() % (800 - randX);
		randYLen = rand() % (480 - randY);

		func = rand() % 3;

		//Line(randX, randY, randX+randXLen, randY+randYLen, colour);
		switch(func){
		/*
		case 0:
			HLine(randX, randY, randXLen, colour);
			break;
		case 1:
			VLine(randX, randY, randYLen, colour);
			break;
		*/
		case 0:
			draw_rectangle(randX, randY, randXLen, randYLen, colour);
			break;
		case 1:
			fill_rectangle(randX, randY, randXLen, randYLen, colour);
			break;

		}
	}
}
