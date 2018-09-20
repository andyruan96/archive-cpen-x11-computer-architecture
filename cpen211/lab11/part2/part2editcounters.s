					.text
					.global		_start
					
					.equ SIZE, 3
zero:				.double 0.0
my_arrayA:			.double 1.1
					.double 1.2
					.double 1.3
					.double 2.1
					.double 2.2
					.double 2.3
					.double 3.1
					.double 3.2
					.double 3.3
my_arrayB:			.double 1.1
					.double 1.2
					.double 1.3
					.double 2.1
					.double 2.2
					.double 2.3
					.double 3.1
					.double 3.2
					.double 3.3
my_arrayC:			.fill 16384, 8, 0xDEADBEEF

_start:
					BL	CONFIG_VIRTUAL_MEMORY
				
					//	Step	1-3:	configure	PMN0	to	count	cycles	
					MOV	R0,	#0							//	Write	0	into	R0	then	PMSELR	
					MCR	p15,	0,	R0,	c9,	c12,	5	//	Write	0	into	PMSELR	selects	PMN0	
					MOV	R1,	#0x11						//	Event	0x11	is	CPU	cycles	
					MCR	p15,	0,	R1,	c9,	c13,	1	//	Write	0x11	into	PMXEVTYPER	(PMN0	measure	CPU	cycles)
				
					// LAB11 PART1 MOD: ENABLE LOAD INSTRUCTION  and CACHE MISS counter
					MOV R0, #1							// 1 -> PMSELR selects PMN1
					MCR p15, 0, R0, c9, c12, 5
					MOV R1, #0x6						// Event 0x6 iS LOAD INSTRUCTIONS
					MCR p15, 0, R1, c9, c13, 1
				
					MOV R0, #2							// 2 -> PMSELR selects PMN2
					MCR p15, 0, R0, c9, c12, 5
					MOV R1, #0x3						// Event 0x3 iS CACHE MISSES
					MCR p15, 0, R1, c9, c13, 1				
				
					//	Step	4:	enable	PMN0; Lab11p1 edit: enables PMN1 and PMN2 also	
					mov	R0,	#0b111						//	PMN0	is	bit	0	of	PMCNTENSET
					MCR	p15,	0,	R0,	c9,	c12,	1	//	Setting	bit	0	of	PMCNTENSET	enables	PMN0
				
					//	Step	5:	clear	all	counters	and	start	counters	
					mov	r0,	#3							//	bits	0	(start	counters)	and	1	(reset	counters)
					MCR	p15,	0,	r0,	c9,	c12,	0	//	Setting	PMCR	to	3
				
					//	Step	6:	code	we	wish	to	profile	using	hardware	counters
					
					mov r4, #SIZE						// r4 = offset for 1 N-sized column
					lsl r4, r4, #3
					ldr r9, =my_arrayA					// r9, r10 = base array addresses
					ldr r10, =my_arrayB
					mov r5, #0							// r5 = row offset for A
					mov r0, #0							// for ( i = 0;
FOR1_2:				cmp r0, #SIZE						// 		i < N; ...
					bge DONE
					
					mov r6, #0							// r6 = column offset for B
					mov r1, #0							//		for ( j = 0;
FOR2_2:				cmp r1, #SIZE						// 			j < N; ...
					bge FOR1_1
					
					ldr r3, =zero
					.word 0xED130B00					// 	FLDD D0, [r3]; sum = D0 = 0.0
					
					mov r7, #0							// r7 = column offset for A
					mov r8, #0							// r8 = row offset for B
					mov r2, #0							// 			for ( k = 0;
FOR3:				cmp r2, #SIZE						// 				k < N; ...
					bge FOR2_1
					
					/* sum = sum + A[i][k] * B[k][j]; */
					
					add r11, r9, r5
					add r11, r11, r7					//	r11 = A[i][k] address
					add r12, r10, r8
					add r12, r12, r6					//	r12 = B[k][j] address
					
					/* FLOATING POINT OPERATIONS */
					.word 0xED1B1B00					//	FLDD D1, [r11]; D0 = A[i][k]
					.word 0xED1C2B00					//	FLDD D2, [r12]; D1 = A[k][j]
					.word 0xEE213B02					//	FMULD D3, D1, D2; D3 = D2*D1
					.word 0xEE300B03					//	FADDD D0, D0, D3; D0 = D0+D3
					
					add	r2, r2, #1						// 				...k++ )
					add r7, r7, #8						// increase A column offset
					add r8, r8, r4						// increase B row offset
					b	FOR3
					
FOR2_1:				/* C[i][j] = sum; */
					ldr r11, =my_arrayC
					add r11, r11, r5					//	r9 = C[i][j] address
					add r11, r11, r6
					.word 0xED0B0B00					//	FSTD D0, [R9]; C[i][j] = sum = D0

					add r1, r1, #1						//			...j++ )
					add r6, r6, #8						// increase B column offset
					b	FOR2_2
					
FOR1_1:				add r0, r0, #1						//		...i++ )
					add r5, r5, r4						// increase A row offset
					b	FOR1_2
					
DONE:				//	Step	7:	stop	counters	
					mov	r0,	#0		
					MCR	p15,	0,	r0,	c9,	c12,	0	//	Write	0	to	PMCR	to	stop	counters
					
					//	Step	8-10:	Select	PMN0	and	read	out	result	into	R3
					// 	Lab10p1 edit: also reads # of load instructions and cache misses into R4 and R5
					mov	r0,	#0							//	PMN0	
					MCR	p15,	0,	R0,	c9,	c12,	5	//	Write	0	to	PMSELR		
					MRC	p15,	0,	R3,	c9,	c13,	2	//	Read	PMXEVCNTR	into	R3

					mov r0, #1
					MCR p15, 0, R0, c9, c12, 5
					MRC p15, 0, R4, c9, c13, 2
				
					mov r0, #2
					MCR p15, 0, R0, c9, c12, 5
					MRC p15, 0, R5, c9, c13, 2
					
END:				b	END