; ECE-222 Lab ... Winter 2013 term 
; Lab 3 sample code 
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R10, =LED_BASE_ADR		; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports

				MOV 		R3, #0xB0000000		; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn off five LEDs on port 2 

; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!

				
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number
				BL			COUNTER
				
				MOV 		R3, #0x007C			; Turn off port 2 leds
				LDR 		R4, =FIO2CLR
				STR			R3, [R4]
				
				MOV 		R3, #0xB0000000		; Turn off port 1 leds
				LDR 		R4, =FIO1CLR
				STR			R3, [R4]
				
loop 			BL 			RandomNum			; Generate a random number	
				MOV 		R10, #0x4E20		; Check for a random number for a delay >=2 seconds
				CMP			R11, R10
				BLE			loop
				MOV 		R10, #0x86A0		; Check for a random number for a delay <=10 seconds
				MOVT		R10, #0x0001		
				CMP			R11, R10
				BGE			loop				; Generate another random number if the number is out of bounds
				
				MOV			R0, R11				; Call random number of ms of delay
				BL			DELAY
				
				MOV			R3, #0x20000000		; Turn on led 29 after random delay
				LDR 		R4, =FIO1SET
				STR			R3, [R4]				
				
				MOV			R6, #0				; Increment R6 until button is pressed to store total user reaction speed
				MOV			R0, #1				; Call 0.1ms delay
increment		BL			DELAY
				LDR 		R4, =FIO2PIN				; Poll P2.10 button for user press
				LDR			R9, [R4]
				MOV 		R10, #0x400
				TST			R10, R9				; Read button with R10 as the mask for the index
				ADD			R6, #1
				BNE			increment
	
				
				MOV 		R7, #0x000000FF		; Create a mask to display 8 bits at a time of the resulting user reaction speed
RESULT			MOV			R12, R6				; Store user reaction time into temporary R12 register
				MOV			R8, #4				; 4 * 8-bit numbers to display
RES				MOV 		R0, #0x4E20			; 2 second delay (20000ms)
				MOV 		R1, R12				
				AND			R1, R7, R1			; Get 8 bits with mask and store in R1
				BL			DISPLAY_NUM 		; Display 8 bits with R1
				BL 			DELAY				; Wait 2 seconds
				LSR			R12, #8				; Shift reaction speed result for the next 8 bits
				SUBS		R8, #1				; Subtract from the loop counter
				CMP 		R8, #0				; Break from loop if all digits have been displayed (looped 4 times)
				BNE 		RES
				
				MOV 		R0, #0xC350			; 5 second delay (50000ms)
				BL 			DELAY				
				B 			RESULT				; Branch back for infinite loop of the reaction speed result
				
				B loop

;
; Display the number in R3 onto the 8 LEDs
DISPLAY_NUM		STMFD		R13!,{R1, R2, R14}

; Usefull commaands:  RBIT (reverse bits), BFC (bit field clear), LSR & LSL to shift bits left and right, ORR & AND and EOR for bitwise operations

;start here 
				MOV 		R3, #0x007C			; Turn off port 2 leds
				LDR 		R4, =FIO2CLR
				STR			R3, [R4]
				
				MOV 		R3, #0xB0000000		; Turn off port 1 leds
				LDR 		R4, =FIO1CLR	
				STR			R3, [R4]

				MOV 		R5, #1				; Register to check bits to display
				LDR 		R4, =FIO2SET			
				MOV			R3, #0x40			; Upper range of port 2 LED indices

CHECK2			TST			R1, R5				; Test bits in range 2^0 to 2^5 against mask
				STRNE 		R3, [R4]			; Store FIO2SET turn on val if bit is 1
				CMP			R3, #0x4			; See if mask has reached lowest range
				LSR			R3, #1				; Shift mask
				LSL			R5, #1				; Shift led turn on value
				BNE 		CHECK2				; Loop if not at lowest range of indices

				MOV 		R3, #0x80000000		; Upper range of port 1 LED indices
				LDR 		R4, =FIO1SET

CHECK1			TST			R3, #0x40000000		; Check for skipped value because led pin values have a skip between P1.29 and P1.28
				BNE			LED1SKIP	
				TST			R1, R5				; Test bits in range 2^6 to 2^8 against mask
				STRNE 		R3, [R4]			; Store FIO1SET turn on val if bit is 1
				LSL			R5, #1				; Shift mask
LED1SKIP		LSR			R3, #1				; Shift led turn on value
				CMP			R3, #0x08000000		; Check and loop if not in lowest range of indices
				BNE 		CHECK1	
				
				LDMFD		R13!,{R1, R2, R15}
				
COUNTER			STMFD		R13!,{R1, R2, R14}
				
				MOV			R1, #0x0			; zero-based to count to 0xFF (255)
				MOV			R2, #0x100
				MOV 		R3, #0x0
			
counter			BL 			DISPLAY_NUM			; Loop for displaying counter numbers of 0 to 255 and delaying for 100ms
				MOV			R0, #0x3E8			; 1000 for (0.1ms * 1000 = 100ms)
				BL			DELAY
				ADDS		R1, #1
				CMP			R2, R1
				
				BNE			counter
				
				LDMFD		R13!,{R1, R2, R15}
				
;
; R11 holds a 16-bit random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 holds a non-zero 16-bit number.  If a zero is fed in the pseudo-random sequence will stay stuck at 0
; Take as many bits of R11 as you need.  If you take the lowest 4 bits then you get a number between 1 and 15.
;   If you take bits 5..1 you'll get a number between 0 and 15 (assuming you right shift by 1 bit).
;
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program OR ELSE!
; R11 can be read anywhere in the code but must only be written to by this subroutine
RandomNum		STMFD		R13!,{R1, R2, R3, R14}

				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				
				LDMFD		R13!,{R1, R2, R3, R15}

;
;		Delay 0.1ms (100us) * R0 times
; 		aim for better than 10% accuracy
;               The formula to determine the number of loop cycles is equal to Clock speed x Delay time / (#clock cycles)
;               where clock speed = 4MHz and if you use the BNE or other conditional branch command, the #clock cycles =
;               2 if you take the branch, and 1 if you don't.

DELAY			STMFD		R13!,{R2, R14}
		;
		; code to generate a delay of 0.1mS * R0 times
		; 400 / 3
				MOV			R2, #0x85			; Initialize R2 lower word for countdown (0.1ms)
				MUL 		R2, R0				; Loop for 0.1ms * R0 times
milidelay		SUBS 		R2, #0x1			; Decrement r2 and set the N,Z,C status bits
				BNE			milidelay				; Loop until R2 is 0
exitDelay		LDMFD		R13!,{R2, R15}
				

LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]
;	Usefull GPIO Registers
;	FIODIR  - register to set individual pins as input or output
FIO1PIN			EQU		0x2009c034		;- register to read and write pins
FIO2PIN			EQU		0x2009c054		;- register to read and write pins
FIO1SET	 	 	EQU		0x2009c038		;- register to set I/O pins to 1 by writing a 1
FIO2SET	 	 	EQU		0x2009c058		;- register to set I/O pins to 1 by writing a 1
FIO1CLR			EQU		0x2009c03c		;- register to clr I/O pins to 0 by writing a 1
FIO2CLR			EQU		0x2009c05c		;- register to clr I/O pins to 0 by writing a 1

				ALIGN 

				END 

