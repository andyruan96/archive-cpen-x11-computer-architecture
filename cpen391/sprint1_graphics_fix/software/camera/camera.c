#include <stdio.h>
#include <inttypes.h>

#define Cam_Control (*(volatile unsigned char *)(0x84000210))
#define Cam_Status (*(volatile unsigned char *)(0x84000210))
#define Cam_TxData (*(volatile unsigned char *)(0x84000212))
#define Cam_RxData (*(volatile unsigned char *)(0x84000212))
#define Cam_Baud (*(volatile unsigned char *)(0x84000214))

#define sdram (volatile unsigned char *) 0x08000000

#define FBUF_MAX 13000

char fbuf_len[4] = {'\0'};
char fbuf[FBUF_MAX] = {'\0'};

void cam_put_char(char c){
	while( !(Cam_Status & 0x02) );
	Cam_TxData = c;
}

char cam_get_char(){
	while(!(Cam_Status & 0x01));
	return (char)Cam_RxData;
}

uint16_t cam_get_fbuf_len(){
	return 0x0000FFFF & ( (uint16_t)fbuf_len[2] << 8 | (uint16_t)fbuf_len[3]);
}

void cam_send_RESET(){
	cam_put_char((char)0x56);
	cam_put_char((char)0x00);
	cam_put_char((char)0x26);
	cam_put_char((char)0x00);

	int i = 0;
	for(i=0; i<5; i++){		//flush return
		printf("%hhX ", 0x0FF & cam_get_char());
	}
	for(i=0; i<10000000; i++);		// wait for reset
}

void cam_init(){
	Cam_Control = 0x03; // reset device
	Cam_Control = 0x15; // 0b0 00 101 01, no reciever interrupt, rts low no transmitter interrupt, 8 data no parity 1 stop, 16 divide
	Cam_Baud = 0x03;	// set baud to 38.4k baud

	cam_put_char((char)0x56);
	cam_put_char((char)0x00);
	cam_put_char((char)0x26);
	cam_put_char((char)0x00);

	int i = 0;

	for(i=0; i<5; i++){		//flush return
		printf("%hhX ", 0x0FF & cam_get_char());
	}

	for(i=0; i<10000000; i++);		// wait for reset

}

void cam_send_FBUF_CTRL(char param){
	cam_put_char((char)0x56);		//command
	cam_put_char((char)0x00);		//serial
	cam_put_char((char)0x36);		// FBUF_CTRL
	cam_put_char((char)0x01);		//
	cam_put_char(param);		// control flag

	// flush return
	//cam_get_char();	// garbage
	int i = 0;
	for(i=0; i<5; i++){
		//cam_get_char();
		printf("%hhX ", 0x0FF & cam_get_char());
	}
}

void cam_send_GET_FBUF_LEN(){
	cam_put_char((char)0x56);		//command
	cam_put_char((char)0x00);		//serial
	cam_put_char((char)0x34);		//GET_FBUF_LEN
	cam_put_char((char)0x01);
	cam_put_char((char)0x00);		//current frame

	int i = 0;
	for(i=0; i<5; i++){		// flush return
		cam_get_char();
	}

	// update fbuf length
	fbuf_len[0] = cam_get_char();
	fbuf_len[1] = cam_get_char();
	fbuf_len[2] = cam_get_char();
	fbuf_len[3] = cam_get_char();
}

void cam_send_READ_FBUFF(){
	cam_put_char((char)0x56);		//command
	cam_put_char((char)0x00);		//serial
	cam_put_char((char)0x32);		//READ_FBUF
	cam_put_char((char)0x0C);

	cam_put_char((char)0x00);		//FBUF type
	cam_put_char((char)0x0A);		//control mode

	cam_put_char((char)0x00);		//starting addr
	cam_put_char((char)0x00);		//
	cam_put_char((char)0x00);		//
	cam_put_char((char)0x00);		//

	cam_put_char(fbuf_len[0]);		//data length
	cam_put_char(fbuf_len[1]);		//
	cam_put_char(fbuf_len[2]);		//
	cam_put_char(fbuf_len[3]);		//

	cam_put_char((char)0x0B);		//delay
	cam_put_char((char)0xB8);		//

	// put return in fbuf
	uint16_t len = cam_get_fbuf_len();
	int i = 0;
	for(i = 0; i < len+10; i++){
		fbuf[i] = cam_get_char();
	}
}

void cam_take_picture(){
	//cam_send_RESET();
	cam_send_FBUF_CTRL((char)0x00);
	cam_send_GET_FBUF_LEN();

/*
	uint16_t flen = cam_get_fbuf_len();
	int i = 0;
	for(i = 0; i < flen+10; i++){
		printf("%hhX ", 0x0FF & fbuf[i]);
	}

*/
	cam_send_FBUF_CTRL((char)0x02);
}

void cam_send_COMM_MOTION_STATUS(char start){
	cam_put_char((char)0x56);		//command
	cam_put_char((char)0x00);		//serial
	cam_put_char((char)0x37);		//READ_FBUF
	cam_put_char((char)0x01);
	cam_put_char(start);

	int i = 0;
	//cam_get_char();
	for(i=0; i<5; i++){		// flush return
		//cam_get_char();
		printf("%hhX ", 0x0FF & cam_get_char());
	}
}

int cam_check_motion(){
	if( Cam_Status & 0x01 ){
		int i;
		for(i=0; i<5; i++){
			//cam_get_char();
			printf("%hhX ", 0x0FF & cam_get_char());
		}
		//cam_send_COMM_MOTION_STATUS((char)0x00);
		return 1;
	}
	return 0;
}

int main()
{
	cam_init();
	cam_get_char();

	cam_send_COMM_MOTION_STATUS((char)0x01);
	printf("motion set\n");
	while(1){
		if(cam_check_motion()) {
			printf("motion detected!\n");
			cam_send_COMM_MOTION_STATUS((char)0x00);
			break;
		}
	}

	cam_take_picture();
	cam_take_picture();

	cam_send_COMM_MOTION_STATUS((char)0x01);
		printf("motion set\n");
		while(1){
			if(cam_check_motion()) {
				printf("motion detected!\n");
				cam_send_COMM_MOTION_STATUS((char)0x00);
				break;
			}
		}

	cam_take_picture();


}
