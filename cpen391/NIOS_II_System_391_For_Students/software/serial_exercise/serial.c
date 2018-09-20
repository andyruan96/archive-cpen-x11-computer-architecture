
#include <stdio.h>

#define RS232_Control (*(volatile unsigned char *)(0x84000200))
#define RS232_Status (*(volatile unsigned char *)(0x84000200))
#define RS232_TxData (*(volatile unsigned char *)(0x84000202))
#define RS232_RxData (*(volatile unsigned char *)(0x84000202))
#define RS232_Baud (*(volatile unsigned char *)(0x84000204))

/**************************************************************************
** Subroutine to initialise the RS232 Port by writing some data
** to the internal registers.
** Call this function at the start of the program before you attempt
** to read or write to data via the RS232 port
**
** Refer to 6850 data sheet for details of registers and
***************************************************************************/
void Init_RS232(void)
{
 // set up 6850 Control Register to utilise a divide by 16 clock,
 // set RTS low, use 8 bits of data, no parity, 1 stop bit,
 // transmitter interrupt disabled
 // program baud rate generator to use 115k baud

	//while( (RS232_Status & 0x01) ) wait until recieve data register is empty
	RS232_Control = 0x03; // reset device
	//while( (RS232_Status & 0x01) ) wait until recieve data register is empty
	RS232_Control = 0x15; // 0b0 00 101 01, no reciever interrupt, rts low no transmitter interrupt, 8 data no parity 1 stop, 16 divide
	//while( (RS232_Status & 0x01) ) wait until recieve data register is empty
	RS232_Baud = 0x1;	// set baud to 115k

}

int putcharRS232(int c)
{
 // poll Tx bit in 6850 status register. Wait for it to become '1'
 // write 'c' to the 6850 TxData register to output the character

	while( !(RS232_Status & 0x02) ); // wait until ready to send
	RS232_TxData = c;
	return c ; // return c
}

int getcharRS232( void )
{
 // poll Rx bit in 6850 status register. Wait for it to become '1'
 // read received character from 6850 RxData register.
	while( !(RS232_Status & 0x01) );	//wait until something to read
	return RS232_RxData;
}

// the following function polls the 6850 to determine if any character
// has been received. It doesn't wait for one, or read it, it simply tests
// to see if one is available to read
int RS232TestForReceivedData(void)
{
 // Test Rx bit in 6850 serial comms chip status register
 // if RX bit is set, return TRUE, otherwise return FALSE
	if( RS232_Status & 0x01 ) return 1;
	else return 0;
}


int main()
{
  printf("Hello from Nios II!\n");
  int i;
  char buff[10] = {'x'};

  Init_RS232();
  for(i=0; i<3000000; i++);
/*
  getcharRS232();
  putcharRS232('a');
  getcharRS232();
  if(RS232_Status & 0b100000) printf("overrun after a\n");

  putcharRS232('b');
  //getcharRS232();
  if(RS232_Status & 0b100000) printf("overrun after b\n");

  putcharRS232('c');
  if(RS232_Status & 0b100000) printf("overrun after c\n");

  putcharRS232('d');
  if(RS232_Status & 0b100000) printf("overrun after d\n");

  putcharRS232('e');
  if(RS232_Status & 0b100000) printf("overrun after e\n");

  putcharRS232('f');
  if(RS232_Status & 0b100000) printf("overrun after f\n");
*/

  getcharRS232();
  putcharRS232('a');
  putcharRS232('b');
  putcharRS232('c');

  buff[0] = getcharRS232();
  buff[1] = getcharRS232();
  buff[2] = getcharRS232();

  putcharRS232('d');
  putcharRS232('e');
  putcharRS232('f');

  buff[3] = getcharRS232();
  buff[4] = getcharRS232();
  buff[5] = getcharRS232();

  putcharRS232('g');
  putcharRS232('h');
  putcharRS232('i');
  putcharRS232('j');

  buff[6] = getcharRS232();
  buff[7] = getcharRS232();
  buff[8] = getcharRS232();

  printf("%c %c %c %c %c %c %c %c %c %c\n", buff[0], buff[1], buff[2], buff[3], buff[4], buff[5], buff[6], buff[7], buff[8], buff[9]);


  printf("complete!\n");
  return 0;
}
