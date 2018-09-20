			.include "address_map_arm.s"
			.text
			.global _start
	
my_array0:	.word 10
my_array1:	.word 20
			.word 30
			.word 40
			.word 50
			.word 60
			.word 70
			.word 80
			.word 90
my_array2:	.word 100
			.word 110
			.word 120
			.word 130
			.word 140
			.word 150
			.word 160
			.word 170
			.word 180
			.word 190
			.word 200
			.word 210
			.word 220
			.word 230
			.word 240
			.word 250
			.word 260
			.word 270
			.word 280
			.word 290
			.word 300
			
_start:
			ldr r0, =my_array0 		// array base address
			mov r1, #10				// key = 10; my_array0[0] = 10
			mov r2, #0 				// startIndex = 0
			mov r3, #0				// endIndex = 0
			mov r4, #0				// numCalls = 0; will be preserved
			bl	PROLOGUE
			bl	SEARCH
			
			ldr r1, =LEDR_BASE 		// load result and wait for switch
			ldr r2, =SW_BASE
			str r0, [r1]
WAIT0:		ldr r3, [r2]			
			cmp r3, #1				// switch up
			bne	WAIT0
			
			ldr r0, =my_array1
			mov r1, #42				// 42 not found 
			mov r2, #0
			mov r3, #7				// endIndex = 7*4 = 28; ending index begins at +28
			bl 	PROLOGUE			// r4 should already be restored = 0
			bl	SEARCH
			
			ldr r1, =LEDR_BASE
			ldr r2, =SW_BASE
			str r0, [r1]
WAIT1:		ldr r3, [r2]
			cmp r3, #0				// switch down
			bne WAIT1
			
			ldr r0, =my_array2
			mov r1, #180			// my_array2[8] = 180
			mov r2, #0
			mov r3, #20				// endIndex = 20*4 = 80; ending index begins at +80
			bl	PROLOGUE			// r4 should already be restored = 0
			bl	SEARCH
			
			ldr r1, =LEDR_BASE
			str R0, [r1]
DONE:		b	DONE


SEARCH:		sub sp, sp, #4
			str lr, [sp, #0]
			sub r9, r7, r6			// endIndex - startIndex
			add r9, r6, r9, lsr #1	// r9: middleIndex = startIndex + (endIndex - startIndex) / 2
			add r8, r8, #1			// numCalls++
			
			cmp r6, r7
			bls L1					// if (startIndex > endIndex)
			mov r0, #-1				// return -1
			ldr r12, [sp, #0]
			add sp, sp, #4
			bl	EPILOGUE
			mov lr, r12
			mov pc, lr

L1:			mov r10, r9, LSL#2
			ldr r11, [r4, r10]		// r10: array[middleIndex]
			cmp r11, r5
			bne L2					// else if (array[middleIndex] == key)
			mov r0, r9
			b	RETURN
			
L2:			cmp r11, r5				
			blo L3					// else if (array[middleIndex] > key)
			mov r0, r4
			mov r1, r5
			mov r2, r6
			sub r9, r9, #1
			mov r3, r9
			mov r12, r4				// base address still needed
			mov r4, r8
			bl	PROLOGUE
			bl	SEARCH
			b	RETURN
			
L3:			mov r0, r4				// else (array[middleIndex] < key)
			mov r1, r5
			add r9, r9, #1
			mov r2, r9
			mov r3, r7
			mov r12, r4				// base address still needed
			mov r4, r8
			bl	PROLOGUE
			bl	SEARCH
			b	RETURN
			
RETURN:		mvn r8, r8
			add r8, r8, #1
			str r8, [r12, r10]
			
			ldr r12, [sp, #0]
			add sp, sp, #4
			bl	EPILOGUE
			mov lr, r12
			mov pc, lr
			
PROLOGUE:	sub sp, sp, #32
			str r4, [sp, #0]
			str r5, [sp, #4]
			str r6, [sp, #8]
			str r7, [sp, #12]
			str r8, [sp, #16]
			str r9, [sp, #20]
			str r10, [sp, #24]
			str r11, [sp, #28]
			mov r4, r0				// r4: local array base address
			mov r5, r1				// r5: local key
			mov r6, r2				// r6: local startIndex
			mov r7, r3				// r7: local endIndex
			ldr r8, [sp, #0]		// r8: local numCalls
			mov pc, lr
			
EPILOGUE:	ldr r4, [sp, #0]		// restores r4 - r11
			ldr r5, [sp, #4]
			ldr r6, [sp, #8]
			ldr r7, [sp, #12]
			ldr r8, [sp, #16]
			ldr r9, [sp, #20]
			ldr r10, [sp, #24]
			ldr r11, [sp, #28]
			add sp, sp, #32
			mov pc, lr