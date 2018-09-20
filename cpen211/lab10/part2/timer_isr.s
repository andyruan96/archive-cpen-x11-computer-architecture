				.include	"address_map_arm.s"
				.global	TIMER_ISR

interrupt_count: .word 0

TIMER_ISR:		
				LDR	R0, =LEDR_BASE
				LDR R1, =interrupt_count
				LDR R2, [R1]
				ADD R2, R2, #1
				
				STR R2, [R0]
				STR R2, [R1]
				BX	LR