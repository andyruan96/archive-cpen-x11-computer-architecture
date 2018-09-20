/*
 * gui.c
 *
 *  Created on: Feb 1, 2017
 *      Author: Andy
 */

#include <stdlib.h>
#include "gui.h"
#include "DemoGraphicsRoutines.h"
#include "OutGraphicsCharFont1.h"
#include "OutGraphicsCharFont2.h"
//#include "DemoGraphicsRoutines.h"

char msg_buf[MAX_MSG_SIZE] = {'H', 'E', 'L','L','O','\0'};

void draw_main_helper(){
	int i;
	draw_rectangle(5, 5, 790, 470, WHITE);

	draw_rectangle(725, 425, 50, 30, WHITE);
	draw_rectangle(715, 420, 40, 20, WHITE);
	draw_rectangle(715, 440, 40, 20, WHITE);
	draw_rectangle(745, 420, 40, 20, WHITE);
	draw_rectangle(745, 440, 40, 20, WHITE);


	for(i = 0; i<10; i++){
		VLine(395+i, 0, 400, WHITE);
		HLine(0, 195+i, 800, WHITE);
		HLine(0, 400+i, 800, WHITE);
		VLine(695+i, 405, 100, WHITE);
	}

	for(i = 0; i < MAX_MSG_SIZE; i++){
		if(msg_buf[i] == '\0') break;

		OutGraphicsCharFont2(100+15*i, 420, WHITE, BLACK, msg_buf[i], FALSE);
	}

	OutGraphicsCharFont2(100, 300, WHITE, BLACK, 'R', FALSE);
	OutGraphicsCharFont2(115, 300, WHITE, BLACK, 'I', FALSE);
	OutGraphicsCharFont2(130, 300, WHITE, BLACK, 'N', FALSE);
	OutGraphicsCharFont2(145, 300, WHITE, BLACK, 'G', FALSE);
	OutGraphicsCharFont2(130, 320, WHITE, BLACK, 'D', FALSE);
	OutGraphicsCharFont2(145, 320, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(160, 320, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(175, 320, WHITE, BLACK, 'R', FALSE);
	OutGraphicsCharFont2(190, 320, WHITE, BLACK, 'B', FALSE);
	OutGraphicsCharFont2(210, 320, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(225, 320, WHITE, BLACK, 'L', FALSE);
	OutGraphicsCharFont2(240, 320, WHITE, BLACK, 'L', FALSE);

	OutGraphicsCharFont2(500, 100, WHITE, BLACK, 'C', FALSE);
	OutGraphicsCharFont2(515, 100, WHITE, BLACK, 'A', FALSE);
	OutGraphicsCharFont2(530, 100, WHITE, BLACK, 'L', FALSE);
	OutGraphicsCharFont2(545, 100, WHITE, BLACK, 'L', FALSE);
	OutGraphicsCharFont2(560, 100, WHITE, BLACK, '/', FALSE);
	OutGraphicsCharFont2(575, 100, WHITE, BLACK, 'T', FALSE);
	OutGraphicsCharFont2(590, 100, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(605, 100, WHITE, BLACK, 'X', FALSE);
	OutGraphicsCharFont2(620, 100, WHITE, BLACK, 'T', FALSE);
	OutGraphicsCharFont2(530, 120, WHITE, BLACK, 'H', FALSE);
	OutGraphicsCharFont2(545, 120, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(560, 120, WHITE, BLACK, 'M', FALSE);
	OutGraphicsCharFont2(575, 120, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(590, 120, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(605, 120, WHITE, BLACK, 'W', FALSE);
	OutGraphicsCharFont2(620, 120, WHITE, BLACK, 'N', FALSE);
	OutGraphicsCharFont2(635, 120, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(650, 120, WHITE, BLACK, 'R', FALSE);

	OutGraphicsCharFont2(500, 300, WHITE, BLACK, 'S', FALSE);
	OutGraphicsCharFont2(515, 300, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(530, 300, WHITE, BLACK, 'N', FALSE);
	OutGraphicsCharFont2(545, 300, WHITE, BLACK, 'D', FALSE);
	OutGraphicsCharFont2(545, 320, WHITE, BLACK, 'P', FALSE);
	OutGraphicsCharFont2(560, 320, WHITE, BLACK, 'H', FALSE);
	OutGraphicsCharFont2(575, 320, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(590, 320, WHITE, BLACK, 'T', FALSE);
	OutGraphicsCharFont2(605, 320, WHITE, BLACK, 'O', FALSE);
}

void draw_main(){

	draw_main_helper();

	OutGraphicsCharFont2(150, 120, WHITE, BLACK, 'U', FALSE);
	OutGraphicsCharFont2(165, 120, WHITE, BLACK, 'N', FALSE);
	OutGraphicsCharFont2(180, 120, WHITE, BLACK, 'L', FALSE);
	OutGraphicsCharFont2(195, 120, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(210, 120, WHITE, BLACK, 'C', FALSE);
	OutGraphicsCharFont2(225, 120, WHITE, BLACK, 'K', FALSE);
}

void clear_main(void){
	int i;

	for(i = 0; i<10; i++){
		VLine(395+i, 0, 400, BLACK);
		HLine(0, 235+i, 800, BLACK);
	}

	OutGraphicsCharFont2(150, 120, BLACK, BLACK, 'U', TRUE);
	OutGraphicsCharFont2(165, 120, BLACK, BLACK, 'N', TRUE);
	OutGraphicsCharFont2(180, 120, BLACK, BLACK, 'L', TRUE);
	OutGraphicsCharFont2(195, 120, BLACK, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(210, 120, BLACK, BLACK, 'C', TRUE);
	OutGraphicsCharFont2(225, 120, BLACK, BLACK, 'K', TRUE);

	OutGraphicsCharFont2(100, 340, BLACK, BLACK, 'R', TRUE);
	OutGraphicsCharFont2(115, 340, BLACK, BLACK, 'I', TRUE);
	OutGraphicsCharFont2(130, 340, BLACK, BLACK, 'N', TRUE);
	OutGraphicsCharFont2(145, 340, BLACK, BLACK, 'G', TRUE);

	OutGraphicsCharFont2(130, 360, BLACK, BLACK, 'D', TRUE);
	OutGraphicsCharFont2(145, 360, BLACK, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(160, 360, BLACK, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(175, 360, BLACK, BLACK, 'R', TRUE);
	OutGraphicsCharFont2(190, 360, BLACK, BLACK, 'B', TRUE);
	OutGraphicsCharFont2(210, 360, BLACK, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(225, 360, BLACK, BLACK, 'L', TRUE);
	OutGraphicsCharFont2(240, 360, BLACK, BLACK, 'L', TRUE);
}

void draw_keypad() {
	int i = 0;
	while (i < 5) {
		VLine(0+i, 0, 479, WHITE);
		VLine(202-i,0, 479, WHITE);
		VLine(331+i,0, 479, WHITE);
		VLine(465+i,0, 479, WHITE);
		VLine(598+i,0, 479, WHITE);
		VLine(799-i, 0, 479, WHITE);
		HLine(0,0+i, 799, WHITE);
		HLine(0,479-i, 799, WHITE);
		HLine(200,118+i, 400, WHITE);
		HLine(200,238+i, 400, WHITE);
		HLine(200,358+i+1, 400, WHITE);
		i++;
	}

	OutGraphicsCharFont2(266,60, WHITE, BLACK, '1', FALSE);
	OutGraphicsCharFont2(400,60, WHITE, BLACK, '2', FALSE);
	OutGraphicsCharFont2(533,60, WHITE, BLACK, '3', FALSE);
	OutGraphicsCharFont2(266,180, WHITE, BLACK, '4', FALSE);
	OutGraphicsCharFont2(400,180, WHITE, BLACK, '5', FALSE);
	OutGraphicsCharFont2(533,180, WHITE, BLACK, '6', FALSE);
	OutGraphicsCharFont2(266,300, WHITE, BLACK, '7', FALSE);
	OutGraphicsCharFont2(400,300, WHITE, BLACK, '8', FALSE);
	OutGraphicsCharFont2(533,300, WHITE, BLACK, '9', FALSE);
	OutGraphicsCharFont2(266,420, WHITE, BLACK, '*', FALSE);
	OutGraphicsCharFont2(400,420, WHITE, BLACK, '0', FALSE);
	OutGraphicsCharFont2(533,420, WHITE, BLACK, '#', FALSE);

	OutGraphicsCharFont2(670,235, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(684,235, WHITE, BLACK, 'N', FALSE);
	OutGraphicsCharFont2(698,235, WHITE, BLACK, 'T', FALSE);
	OutGraphicsCharFont2(712,235, WHITE, BLACK, 'E', FALSE);
	OutGraphicsCharFont2(726,235, WHITE, BLACK, 'R', FALSE);

	OutGraphicsCharFont2(80,235, WHITE, BLACK, 'B', FALSE);
	OutGraphicsCharFont2(94,235, WHITE, BLACK, 'A', FALSE);
	OutGraphicsCharFont2(108,235, WHITE, BLACK, 'C', FALSE);
	OutGraphicsCharFont2(122,235, WHITE, BLACK, 'K', FALSE);

}

void clear_keypad() {
	int i = 0;
	while (i < 5) {
		VLine(0+i, 0, 479, BLACK);
		VLine(202-i,0, 479, BLACK);
		VLine(331+i,0, 479, BLACK);
		VLine(465+i,0, 479, BLACK);
		VLine(598+i,0, 479, BLACK);
		VLine(799-i, 0, 479, BLACK);
		HLine(0,0+i, 799, BLACK);
		HLine(0,479-i, 799, BLACK);
		HLine(200,118+i, 400, BLACK);
		HLine(200,238+i, 400, BLACK);
		HLine(200,358+i+1, 400, BLACK);
		i++;
	}

	OutGraphicsCharFont2(266,60, BLACK, BLACK, '1', TRUE);
	OutGraphicsCharFont2(400,60, BLACK, BLACK, '2', TRUE);
	OutGraphicsCharFont2(533,60, BLACK, BLACK, '3', TRUE);
	OutGraphicsCharFont2(266,180, BLACK, BLACK, '4', TRUE);
	OutGraphicsCharFont2(400,180, BLACK, BLACK, '5', TRUE);
	OutGraphicsCharFont2(533,180, BLACK, BLACK, '6', TRUE);
	OutGraphicsCharFont2(266,300, BLACK, BLACK, '7', TRUE);
	OutGraphicsCharFont2(400,300, BLACK, BLACK, '8', TRUE);
	OutGraphicsCharFont2(533,300, BLACK, BLACK, '9', TRUE);
	OutGraphicsCharFont2(266,420, BLACK, BLACK, '*', TRUE);
	OutGraphicsCharFont2(400,420, BLACK, BLACK, '0', TRUE);
	OutGraphicsCharFont2(533,420, BLACK, BLACK, '#', TRUE);

	OutGraphicsCharFont2(670,235, BLACK, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(684,235, BLACK, BLACK, 'N', TRUE);
	OutGraphicsCharFont2(698,235, BLACK, BLACK, 'T', TRUE);
	OutGraphicsCharFont2(712,235, BLACK, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(726,235, BLACK, BLACK, 'R', TRUE);

	OutGraphicsCharFont2(80,235, BLACK, BLACK, 'B', TRUE);
	OutGraphicsCharFont2(94,235, BLACK, BLACK, 'A', TRUE);
	OutGraphicsCharFont2(108,235, BLACK, BLACK, 'C', TRUE);
	OutGraphicsCharFont2(122,235, BLACK, BLACK, 'K', TRUE);
}

void draw_main_unlocked(){
	draw_main_helper();
	OutGraphicsCharFont2(180, 120, WHITE, BLACK, 'L', FALSE);
	OutGraphicsCharFont2(195, 120, WHITE, BLACK, 'O', FALSE);
	OutGraphicsCharFont2(210, 120, WHITE, BLACK, 'C', FALSE);
	OutGraphicsCharFont2(225, 120, WHITE, BLACK, 'K', FALSE);
}

void clear_main_unlocked(void){
	int i;

	for(i = 0; i<10; i++){
		VLine(395+i, 0, 480, BLACK);
		HLine(0, 235+i, 800, BLACK);
	}

	//OutGraphicsCharFont2(150, 120, BLACK, BLACK, 'U', TRUE);
	//OutGraphicsCharFont2(165, 120, BLACK, BLACK, 'N', TRUE);
	OutGraphicsCharFont2(180, 120, BLACK, BLACK, 'L', TRUE);
	OutGraphicsCharFont2(195, 120, BLACK, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(210, 120, BLACK, BLACK, 'C', TRUE);
	OutGraphicsCharFont2(225, 120, BLACK, BLACK, 'K', TRUE);

	OutGraphicsCharFont2(100, 340, BLACK, BLACK, 'R', TRUE);
	OutGraphicsCharFont2(115, 340, BLACK, BLACK, 'I', TRUE);
	OutGraphicsCharFont2(130, 340, BLACK, BLACK, 'N', TRUE);
	OutGraphicsCharFont2(145, 340, BLACK, BLACK, 'G', TRUE);

	OutGraphicsCharFont2(130, 360, BLACK, BLACK, 'D', TRUE);
	OutGraphicsCharFont2(145, 360, BLACK, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(160, 360, BLACK, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(175, 360, BLACK, BLACK, 'R', TRUE);
	OutGraphicsCharFont2(190, 360, BLACK, BLACK, 'B', TRUE);
	OutGraphicsCharFont2(210, 360, BLACK, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(225, 360, BLACK, BLACK, 'L', TRUE);
	OutGraphicsCharFont2(240, 360, BLACK, BLACK, 'L', TRUE);
}

void draw_settings(){
	draw_rectangle(100, 60, 599, 49, WHITE);
	draw_rectangle(100, 160, 599, 49, WHITE);
	draw_rectangle(100, 260, 599, 49, WHITE);
	draw_rectangle(100, 360, 599, 49, WHITE);

	OutGraphicsCharFont2(325, 70, WHITE, BLACK, 'R', TRUE);
	OutGraphicsCharFont2(340, 70, WHITE, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(355, 70, WHITE, BLACK, 'S', TRUE);
	OutGraphicsCharFont2(370, 70, WHITE, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(385, 70, WHITE, BLACK, 'T', TRUE);
	//OutGraphicsCharFont2(400, 70, WHITE, BLACK, ' ', TRUE);
	OutGraphicsCharFont2(415, 70, WHITE, BLACK, 'P', TRUE);
	OutGraphicsCharFont2(430, 70, WHITE, BLACK, 'I', TRUE);
	OutGraphicsCharFont2(445, 70, WHITE, BLACK, 'N', TRUE);

	OutGraphicsCharFont2(295, 170, WHITE, BLACK, 'P', TRUE);
	OutGraphicsCharFont2(310, 170, WHITE, BLACK, 'A', TRUE);
	OutGraphicsCharFont2(325, 170, WHITE, BLACK, 'I', TRUE);
	OutGraphicsCharFont2(340, 170, WHITE, BLACK, 'R', TRUE);
	//OutGraphicsCharFont2(355, 170, WHITE, BLACK, ' ', TRUE);
	OutGraphicsCharFont2(370, 170, WHITE, BLACK, 'B', TRUE);
	OutGraphicsCharFont2(385, 170, WHITE, BLACK, 'L', TRUE);
	OutGraphicsCharFont2(400, 170, WHITE, BLACK, 'U', TRUE);
	OutGraphicsCharFont2(415, 170, WHITE, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(430, 170, WHITE, BLACK, 'T', TRUE);
	OutGraphicsCharFont2(445, 170, WHITE, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(460, 170, WHITE, BLACK, 'O', TRUE);
	OutGraphicsCharFont2(475, 170, WHITE, BLACK, 'T', TRUE);
	OutGraphicsCharFont2(490, 170, WHITE, BLACK, 'H', TRUE);

	OutGraphicsCharFont2(340, 270, WHITE, BLACK, 'E', TRUE);
	OutGraphicsCharFont2(355, 270, WHITE, BLACK, 'D', TRUE);
	OutGraphicsCharFont2(370, 270, WHITE, BLACK, 'I', TRUE);
	OutGraphicsCharFont2(385, 270, WHITE, BLACK, 'T', TRUE);
	//OutGraphicsCharFont2(400, 270, WHITE, BLACK, ' ', TRUE);
	OutGraphicsCharFont2(415, 270, WHITE, BLACK, 'M', TRUE);
	OutGraphicsCharFont2(430, 270, WHITE, BLACK, 'S', TRUE);
	OutGraphicsCharFont2(445, 270, WHITE, BLACK, 'G', TRUE);

	OutGraphicsCharFont2(370, 370, WHITE, BLACK, 'B', TRUE);
	OutGraphicsCharFont2(385, 370, WHITE, BLACK, 'A', TRUE);
	OutGraphicsCharFont2(400, 370, WHITE, BLACK, 'C', TRUE);
	OutGraphicsCharFont2(415, 370, WHITE, BLACK, 'K', TRUE);
}
