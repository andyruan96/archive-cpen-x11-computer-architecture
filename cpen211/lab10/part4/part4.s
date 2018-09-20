				.include	"address_map_arm.s"
				.include	"interrupt_ID.s"
				
char_buffer:	.word 0
char_flag:		.word 0

current_pid:	.word 0
pd_array:		.fill 17, 4, 0xDEADBEEF
				.fill 13, 4, 0xDEADBEE1
				.word 0x3F000000		// SP
				.word PROC1+4			// LR
				.word PROC1+4			// PC
				.word 0x53				// CPSR (0x53 means IRQ ENABLED, MODE = SVC)
extra_storage:	.word 0
				.word 0
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
		
PROC1:			
				LDR 	R0, =LEDR_BASE
				MOV 	R3, #0
WHILE:			ADD 	R3, R3, #1
				STR 	R3, [R0]
				CMP 	R3, #1024
				BEQ 	DONE
				MOV 	R4, #0
FOR:			CMP 	R4, #134217728
				BHI 	WHILE
				ADD 	R4, R4, #1
				B		FOR
DONE:
				
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
				
				LDR		R0, =extra_storage
				STMIA	R0, {R4,R5}
				
				LDR		R0, =current_pid
				LDR		R1, [R0]
				CMP		R1, #0				
				BNE		PROCESS1
				
				POP		{R0-R7, LR}
				PUSH	{R12}
				LDR		R12, =pd_array
				STMIA	R12, {R0-R11}
				MOV		R0, R12
				POP		{R12}
				STR		R12, [R0, #48]			// order of registers stored 0,1,2,3,4,5,6,7,8,9,10,11,12
				
				MOV		R1, #0b11010011			// temporarily enter uninterrupted supervisor mode
				
				MRS 	R2, SPSR
				STR		SP, [R0, #52]
				STR		LR, [R0, #56]
				STR		PC, [R0, #60]
				STR		R2, [R0, #64]			// registers: ...11, 12, sp, lr, pc, cpsr
				
				LDR		R1, =current_pid
				MOV		R2, #1
				STR		R2, [R1]
				
				ADD		R0, R0, #72
				LDMIA	R0, {R1-R14}
				
				LDR		R0, [R0, #60]
				MSR		SPSR, R0
				
				LDR		R0, =pd_array
				LDR		R0, [R0, #68]
				
				PUSH	{R0-R7, LR}
				LDR		R0, =extra_storage
				LDMIA	R0, {R4,R5}
				B		EXIT_IRQ
PROCESS1:		
				LDR		R0, =extra_storage
				STMIA	R0, {R4,R5}
				
				POP		{R0-R7, LR}
				PUSH	{R12}
				LDR		R12, =pd_array
				ADD		R12, R12, #68
				STMIA	R12, {R0-R11}
				MOV		R0, R12
				POP		{R12}
				STR		R12, [R0, #48]			// order of registers stored 0,1,2,3,4,5,6,7,8,9,10,11,12
				
				MOV		R1, #0b11010011			// temporarily enter uninterrupted supervisor mode
				
				MRS 	R2, SPSR
				STR		SP, [R0, #52]
				STR		LR, [R0, #56]
				STR		PC, [R0, #60]
				STR		R2, [R0, #64]			// registers: ...11, 12, sp, lr, pc, cpsr
				
				LDR		R1, =current_pid
				MOV		R2, #0
				STR		R2, [R1]
				
				LDR		R0, =pd_array
				ADD		R0, R0, #4
				LDMIA	R0, {R1-R14}
				
				LDR		R0, [R0, #60]
				MSR		SPSR, R0
				
				LDR		R0, =pd_array
				LDR		R0, [R0]
				
				PUSH	{R0-R7, LR}
				LDR		R0, =extra_storage
				LDMIA	R0, {R4,R5}
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
