				.include	"address_map_arm.s"
				.include	"interrupt_ID.s"
				
char_buffer:	.word 0
char_flag:		.word 0
/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly language code. 
 * The program responds to interrupts from the pushbutton KEY port in the FPGA.
 *
 * The interrupt service routine for the pushbutton KEYs indicates which KEY has 
 * been pressed on the HEX0 display.
 ********************************************************************************/

				.section .vectors, "ax"

				B 			_start					// reset vector
				B 			SERVICE_UND				// undefined instruction vector
				B 			SERVICE_SVC				// software interrrupt vector
				B 			SERVICE_ABT_INST		// aborted prefetch vector
				B 			SERVICE_ABT_DATA		// aborted data vector
				.word 	0							// unused vector
				B 			SERVICE_IRQ				// IRQ interrupt vector
				B 			SERVICE_FIQ				// FIQ interrupt vector

				.text
				.global	_start
_start:		
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #0b11010010					// interrupts masked, MODE = IRQ
				MSR		CPSR_c, R1							// change to IRQ mode
				LDR		SP, =A9_ONCHIP_END - 3			// set IRQ stack to top of A9 onchip memory
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b11010011					// interrupts masked, MODE = SVC
				MSR		CPSR, R1								// change to supervisor mode
				LDR		SP, =DDR_END - 3					// set SVC stack to top of DDR3 memory

				BL			CONFIG_GIC							// configure the ARM generic interrupt controller

				// write to the pushbutton KEY interrupt mask register
				LDR		R0, =KEY_BASE						// pushbutton KEY base address
				MOV		R1, #0xF								// set interrupt mask bits
				STR		R1, [R0, #0x8]						// interrupt mask register is (base + 8)

				// enable IRQ interrupts in the processor
				MOV		R0, #0b01010011					// IRQ unmasked, MODE = SVC
				MSR		CPSR_c, R0

				// LAB10 PART2 CONFIG TIMER
				LDR		R0, =MPCORE_PRIV_TIMER
				MOV		R1, #0x05F00000
				STR		R1, [R0]						// 100 FOR 200Mhz = 0.5s
				
				MOV 	R1, #0x00000007					// IAE = 111
				STR		R1, [R0, #8]
	
				// LAB10 PART 3 CONFIG JTAG UART
				LDR		R0, =JTAG_UART_BASE
				MOV 	R1, #0x00000001					// RE = 1
				STR		R1, [R0, #4]
				
IDLE:
				LDR 	R0, =char_flag					// check CHAR_FLAG
				LDR 	R0, [R0]
				CMP 	R0, #1
				BNE 	IDLE
				
				LDR		R0, =char_buffer
				LDR		R0, [R0]
				BL		PUT_JTAG
				
				LDR		R0, =char_flag					// set CHAR_FLAG to 0
				MOV		R1, #0
				STR		R1, [R0]
				B 		IDLE							// main program simply idles
				
UART_ISR:		
				LDR R0, =JTAG_UART_BASE
				LDR R1, =char_buffer
				LDR R2, =char_flag
				LDRB R0, [R0]
				STR R0, [R1]
				MOV R0, #1
				STR R0, [R2]
				BX	LR
				
PUT_JTAG:		LDR		R1, =JTAG_UART_BASE
				LDR		R2, [R1, #4]
				LDR		R3, =0xFFFF
				ANDS	R2, R2, R3
				BEQ		END_PUT
				STR		R0, [R1]
END_PUT:		BX		LR

/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
    			B SERVICE_UND 
 
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:			
    			B SERVICE_SVC 

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
    			B SERVICE_ABT_DATA 

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
    			B SERVICE_ABT_INST 
 
/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
    			PUSH		{R0-R7, LR}
    
    			/* Read the ICCIAR from the CPU interface */
    			LDR		R4, =MPCORE_GIC_CPUIF
    			LDR		R5, [R4, #ICCIAR]				// read from ICCIAR

FPGA_IRQ1_HANDLER:
    			CMP		R5, #KEYS_IRQ
				BNE		TIMER_INTERRUPT
    
    			BL		KEY_ISR
				B		EXIT_IRQ
				
TIMER_INTERRUPT:
				CMP		R5, #MPCORE_PRIV_TIMER_IRQ
				BNE		JTAG_INTERRUPT
				
				BL		TIMER_ISR
				B		EXIT_IRQ

JTAG_INTERRUPT:
				CMP		R5, #JTAG_IRQ
UNEXPECTED:		BNE		UNEXPECTED
				
				BL		UART_ISR
				
EXIT_IRQ:
    			/* Write to the End of Interrupt Register (ICCEOIR) */
    			STR		R5, [R4, #ICCEOIR]			// write to ICCEOIR
    
    			POP		{R0-R7, LR}
    			SUBS		PC, LR, #4

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
    			B			SERVICE_FIQ 

				.end   
