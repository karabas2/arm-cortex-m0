
		AREA myData, DATA, READONLY ; Define a read only data section
arr    	DCD 0xA1, 0x15, 0x32, 0x27, 0x32, 0x14, 0xA0, 0x13, 0xA2, 0x11, 0x07, 0x32, 0x14, 0xA0, 0x11, 0xA3, 0x11, 0x27, 0x14, 0x07, 0xA0, 0x11, 0xA4, 0x14, 0x33, 0x27, 0x13, 0xA0, 0x11, 0xA5, 0x14, 0x03, 0x33, 0x04 , 0x13, 0xFF
		AREA myDataRW, DATA, READWRITE ; Define a read write data section
varx    DCD 0 
vary    DCD 0
varc	DCB 0
vari	DCD 0
varb	DCD 0


STCTRL   EQU 0xE000E010			;STCTRL = 0xE000E010	
STRELOAD EQU 0xE000E014			;STRELOAD = 0xE000E014	
canvas   EQU 0x20001000			;start address of canvas = 0x20001000

        AREA myCode, CODE, READONLY
        EXPORT main
main
        BL SysTick_Init          ; Initialize SysTick timer before entering main loop

main_loop
        LDR R0, =varb            ;Load address of SysTick flag variable
        LDRB R1, [R0]            ;Read flag value (set by SysTick interrupt)
        CMP R1, #0               ;compare varb and 0,check if interrupt has occurred
        BEQ main_loop            ;if flag is 0, keep waiting
        MOVS R1, #0              ;clear the SysTick flag
        STRB R1, [R0]            ;store cleared flag back to memory
        BL readArr               ;execute one array operation per SysTick interrupt
        B main_loop              ;repeat main loop forever

stop 	B  stop					 ;repeat loop, when we reach the end of the array we branch here.

SysTick_Init
        LDR R0, =STRELOAD        ;load address of SysTick Reload Register
        LDR R1, =9999999         ;R1=9999999 calculated for 10 MHz clock (Actual clock is 12 MHz, so interrupt occurs every 0.83 s)
        STR R1, [R0]             ;set reload value
        LDR R0, =STCTRL          ;load address of SysTick Control Register
        MOVS R1, #7              ;enable SysTick: bit0 ENABLE = 1 bit1 TICKINT = 1 (interrupt enabled) bit2 CLKSOURCE = 1 (processor clock)		
        STR R1, [R0]             ;store control value to SysTick
        BX LR                    ;return


SysTick_Handler FUNCTION
        EXPORT SysTick_Handler   ;export the function make it visible for vector table

        PUSH {LR}                ;save return address
        LDR R0, =varb            ;load address of SysTick flag variable
        MOVS R1, #1              ;set flag to indicate interrupt occurrence
        STRB R1, [R0]            ;store flag value
        POP {PC}                 ;return from interrupt handler
		ENDFUNC

readArr
        PUSH {R0,R1,LR}			;save return address, and registers
        LDR R0, =arr			;ro = &arr, load address of array
        LDR R1, =vari			;r1 = &vari, load address of index
        LDR R1, [R1]			;r1 = index, vari
		LSLS R1,#2				;index*4 for access array elements
        LDR R0, [R0, R1]		;R0 = vari[index]
		CMP R0,#0xFF			;R0 and 0xFF,check it is last element
		BEQ stop				;if reach the end of array branch stop, stop the program
        MOVS R1,#0xF0			;R1 = 0xF0, for mask the second byte
		ANDS R1,R0				;take the second byte of the element, and decide which operation gonna make
        CMP R1, #0xA0			;R1 = 0xA0 ?
        BEQ changeColor			;branch change color
        CMP R1, #0x00			;R1 = 0x00?
        BEQ goUp				;branch go up
        CMP R1, #0x10			;R1 = 0x10?
        BEQ goRight				;branch go right
        CMP R1, #0x20			;R1 = 0x20?
        BEQ goDown				;branch go down 
        CMP R1, #0x30			;R1 = 0x30?
        BEQ goLeft				;branch go left
		
  		

changeColor
        MOVS R1, #0x0F			;R1 = 0x0F, for mask the first byte
        ANDS R0, R1				;R0 will be first byte of the element which it is color
		LSLS R1,R0,#4			;shift to the left R0 by 4 bit. and write in to R1				
		ADDS R0,R0,R1			;Now R0's first two byte are the same number making this for coloring.
        LDR R1, =varc			;load the address of varc (color)
        STRB R0, [R1]			;store the color in &varc
        B	endarray			;branch endarray

goRight
        MOVS R1, #0x0F			;R1 = 0x0F, for mask the first byte
        ANDS R0, R1				;R0 will be first byte of the element which it is The lenght of the stroke 
        LDR R1, =varx			;load the address of varx (Xposition)
        LDR R1, [R1]			;take the value of X
loopr							;in this loop, increase X and go paint until the remaining stroke length reach the zero
        CMP R0, #0				;compare remaining stroke length and 0,
        BEQ endarray			;if the it is 0, branch endarray
        CMP R1, #31				;compare X position and 31, Is X reach to the canvas limits?
        BEQ endarray			;if it is go endarray 
		PUSH {R0}				;save R0
        ADDS R1, #1				;X++
        LDR R0, =varx			;load the address of varx (Xposition)
        STR R1, [R0]			;store the value X in the varx = X
		POP {R0}				;reload R0
        BL paint				;branch and link to paint
        SUBS R0, #1				;remaining stroke length-- 
        B loopr					;branch loopr

goLeft
        MOVS R1, #0x0F			;R1 = 0x0F, for mask the first byte
        ANDS R0, R1				;R0 will be first byte of the element which it is The lenght of the stroke 
        LDR R1, =varx			;load the address of varx (Xposition)
        LDR R1, [R1]			;take the value of X
loopl
        CMP R0, #0				;compare remaining stroke length and 0,
        BEQ endarray			;if the it is 0, branch endarray
        CMP R1, #0				;compare X position and 0, Is X reach to the canvas limits?	
        BEQ endarray			;if it is go endarray 
		PUSH {R0}				;save R0
        SUBS R1, #1				;X--
        LDR R0, =varx			;load the address of varx (Xposition)
        STR R1, [R0]			;store the value X in the varx = X
		POP {R0}				;reload R0
        BL paint				;branch and link to paint
        SUBS R0, #1				;remaining stroke length-- 
        B loopl					;branch loopl

goDown
        MOVS R1, #0x0F			;R1 = 0x0F, for mask the first byte
        ANDS R0, R1				;R0 will be first byte of the element which it is The lenght of the stroke 
        LDR R1, =vary			;load the address of vary (Yposition)
        LDR R1, [R1]			;take the value of Y
loopd
        CMP R0, #0				;compare remaining stroke length and 0,
        BEQ endarray			;if the it is 0, branch endarray
        CMP R1, #7				;compare Y position and 7, Is Y reach to the canvas limits?	
        BEQ endarray			;if it is go endarray 
		PUSH {R0}				;save R0
        ADDS R1, #1				;Y++
        LDR R0, =vary			;load the address of vary (Yposition)
        STR R1, [R0]			;store the value Y in the vary = Y
		POP {R0}				;reload R0
        BL paint				;branch and link to paint
        SUBS R0, #1				;remaining stroke length-- 
        B loopd					;branch loopd

goUp
        MOVS R1, #0x0F			;R1 = 0x0F, for mask the first byte
        ANDS R0, R1				;R0 will be first byte of the element which it is The lenght of the stroke 
        LDR R1, =vary			;load the address of vary (Yposition)
        LDR R1, [R1]			;take the value of Y
loopu
        CMP R0, #0    			;compare remaining stroke length and 0,
        BEQ endarray			;if the it is 0, branch endarray
        CMP R1, #0				;compare Y position and 0, Is Y reach to the canvas limits?	
        BEQ endarray			;if it is go endarray 
		PUSH {R0}				;save R0
        SUBS R1, #1				;Y--
        LDR R0, =vary			;load the address of vary (Yposition)
        STR R1, [R0]			;store the value Y in the vary = Y
		POP {R0}				;reload R0
        BL paint				;branch and link to paint
        SUBS R0, #1				;remaining stroke length-- 
        B loopu					;branch loopd

endarray
        LDR R0, =vari			;load the address of vari index
        LDR R1, [R0]			;load the value of index
        ADDS R1, #1				;index++
        STR R1, [R0]			;store the value of index into vari
        POP {R0,R1,PC}			;restore the registers and return the saved address

paint
		PUSH    {R0, R1, LR}	;save return address, and registers
        LDR     R0, =vary		;load address of vary
		LDR     R1, [R0]        ;R1 = y
		LSLS    R1, R1, #5      ;R1 = y*32, because every Y index increase or decrease the memory address by 32 
		LDR     R0, =varx		;load address of varx
		LDR     R0, [R0]        ;R0 = X
		ADDS    R1, R1, R0      ;R1 = (Y*32) + X
		LDR     R0, =canvas     ;load the canvas R0 = 0x20001000
		ADDS    R0, R1, R0      ;R1 = final Address that will be paint
		LDR     R1, =varc		;load the address of color
		LDRB    R1, [R1]        ;R0 = color 
		STRB    R1, [R0]        ;store color to canvas 
		
		POP     {R0, R1, PC}    ;restore registers, and return the saved address
		
		