		.include "address_map_arm.s"
		.text
		.global _start
_start:
		LDR R0, =SW_BASE
		LDR R1, =LEDR_BASE
		MOV R3, #0
WHILE:	LDR R2, [R0]
		CMP R2, #0
		BNE WHILE
		ADD R3, R3, #1
		STR R3, [R1]
	