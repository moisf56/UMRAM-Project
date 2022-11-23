ORG 0
;X,Y [0,99]
acall	CONFIGURE_LCD
INPUTS_AND_DISPLAY:
	ACALL KEYBOARD
	MOV R2, A
	SJMP SKIPP
AGAIN:  mov a,#80H
	ACALL SEND_COMMAND
	MOV A, R2
SKIPP:	ACALL SEND_DATA
	ACALL KEYBOARD
	MOV R3, A 
	ACALL SEND_DATA

	MOV A, #7CH	;ASCII VAL OF DIVISON OPERATOR
	ACALL SEND_DATA
	ACALL KEYBOARD
	MOV R4, A
	ACALL SEND_DATA
	ACALL KEYBOARD
	MOV R5, A
	ACALL SEND_DATA

	MOV A, #20H	; SPACE IN ASCII
	ACALL SEND_DATA
	MOV A, #3FH 
	ACALL SEND_DATA
	MOV A, #0C0H 
	ACALL SEND_COMMAND
	ACALL CALCULATE



CALCULATE:
	MOV A, R2
	MOV B, #10
	ANL A, #0FH
	MUL AB
	MOV R6, A
	MOV A, R3
	ANL A, #0FH
	ADD A, R6
	PUSH A
	MOV A, R4
	MOV B, #10
	ANL A, #0FH
	MUL AB
	MOV R7, A
	MOV A, R5
	ANL A, #0FH
	ADD A, R7
	MOV B, A	; R7 HAS THE VAL OF 2ND NUMBER Y
	POP A
CHECK1:
	CJNE A, B, CHECK2
	acall TRUE


CHECK2:
	JNC DIVIDE 
	acall FALSE

DIVIDE:
	DIV AB		; X/Y
	XCH A,B
	JNZ FALSE

	acall TRUE


TRUE:
	SETB P2.5
	MOV A, #'T'
	ACALL SEND_DATA
	MOV A, #'R'
	ACALL SEND_DATA
	MOV A,#'U'
	ACALL SEND_DATA
	MOV A,#'E'
	ACALL SEND_DATA
	LJMP AGAIN
FALSE:
	CLR P2.5
	MOV A,#'F'
	ACALL SEND_DATA
	MOV A, #'A'
	ACALL SEND_DATA
	MOV A, #'L'
	ACALL SEND_DATA
	MOV A, #'S'
	ACALL SEND_DATA
	MOV A, #'E'
	ACALL SEND_DATA
	LJMP AGAIN




CONFIGURE_LCD:	;THIS SUBROUTINE SENDS THE INITIALIZATION COMMANDS TO THE LCD
	mov a,#38H	;TWO LINES, 5X7 MATRIX
	acall SEND_COMMAND
	mov a,#0FH	;DISPLAY ON, CURSOR BLINKING
	acall SEND_COMMAND
	mov a,#06H	;INCREMENT CURSOR (SHIFT CURSOR TO RIGHT)
	acall SEND_COMMAND
	mov a,#01H	;CLEAR DISPLAY SCREEN
	acall SEND_COMMAND
	mov a,#80H	;FORCE CURSOR TO BEGINNING OF THE FIRST LINE
	acall SEND_COMMAND
	ret



SEND_COMMAND:
	mov p1,a		;THE COMMAND IS STORED IN A, SEND IT TO LCD
	clr p3.5		;RS=0 BEFORE SENDING COMMAND
	clr p3.6		;R/W=0 TO WRITE
	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall DELAY
	clr p3.7
	ret


SEND_DATA:
	mov p1,a		;SEND THE DATA STORED IN A TO LCD
	setb p3.5	;RS=1 BEFORE SENDING DATA
	clr p3.6		;R/W=0 TO WRITE
	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall DELAY
	clr p3.7
	ret


DELAY:
	push 0
	push 1
	mov r0,#50
DELAY_OUTER_LOOP:
	mov r1,#255
	djnz r1,$
	djnz r0,DELAY_OUTER_LOOP
	pop 1
	pop 0
	ret


KEYBOARD: ;takes the key pressed from the keyboard and puts it to A
	mov	P0, #0ffh	;makes P0 input
K1:
	mov	P2, #0	;ground all rows
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, K1
K2:
	acall	DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER
	sjmp	K2
KB_OVER:
	acall DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER1
	sjmp	K2
KB_OVER1:
	mov	P2, #11111110B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_0
	mov	P2, #11111101B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_1
	mov	P2, #11111011B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_2
	mov	P2, #11110111B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_3
	ljmp	K2
	
ROW_0:
	mov	DPTR, #KCODE0
	sjmp	KB_FIND
ROW_1:
	mov	DPTR, #KCODE1
	sjmp	KB_FIND
ROW_2:
	mov	DPTR, #KCODE2
	sjmp	KB_FIND
ROW_3:
	mov	DPTR, #KCODE3
KB_FIND:
	rrc	A
	jnc	KB_MATCH
	inc	DPTR
	sjmp	KB_FIND
KB_MATCH:
	clr	A
	movc	A, @A+DPTR; get ASCII code from the table 
	ret

;ASCII look-up table 
KCODE0:	DB	'1', '2', '3', 'A'
KCODE1:	DB	'4', '5', '6', 'B'
KCODE2:	DB	'7', '8', '9', 'C'
KCODE3:	DB	'*', '0', '#', 'D'

END


