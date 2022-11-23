ORG 0


ACALL CONFIGURE_LCD
sjmp start
AG:	ACALL CONFIGURE_LCD
	MOV A, #'P'
	ACALL SEND_DATA
	MOV A, #'H'
	ACALL SEND_DATA
	MOV A, #'I'
	ACALL SEND_DATA
	MOV A, #'('
	ACALL SEND_DATA
	ACALL KEYBOARD
	MOV R4, A
	ACALL SEND_DATA
	SJMP CONTIN

START:	MOV A, #'P'
	ACALL SEND_DATA
	MOV A, #'H'
	ACALL SEND_DATA
	MOV A, #'I'
	ACALL SEND_DATA
	MOV A, #'('
	ACALL SEND_DATA
	ACALL KEYBOARD
	MOV R4, A
	ACALL SEND_DATA
CONTIN:	ACALL KEYBOARD
	CJNE A, #'D',PASS
	MOV A, #')'
	ACALL SEND_DATA
	mov A,#0C0H 
	ACALL SEND_COMMAND
	MOV A, #'='
	ACALL SEND_DATA
	ACALL FIND
SHOW:	ACALL CONV
HERE:	SJMP HERE


PASS:

	MOV R3, 4
	MOV R4, A
	ACALL SEND_DATA
	ACALL KEYBOARD
	CJNE A, #'D',PASS_2
	MOV A, #')'
	ACALL SEND_DATA
	mov A,#0C0H 
	ACALL SEND_COMMAND
	MOV A, #'='
	ACALL SEND_DATA
	ACALL FIND

PASS_2:

	MOV R2, 3
	MOV R3, 4
	MOV R4, A
	ACALL SEND_DATA
	AGAIN:ACALL KEYBOARD
	CJNE A, #'D',AGAIN
	MOV A, #')'
	ACALL SEND_DATA
	mov A,#0C0H 
	ACALL SEND_COMMAND
	MOV A, #'='
	ACALL SEND_DATA
	ACALL FIND





FIND:MOV A, R2
     MOV B, #100
     MUL AB
     MOV R6, A
     MOV A, R3
     MOV B, #10
     MUL AB
     ADD A,R6
     ADD A,R4	; NOW A HAS THE HEX VALUE OF INPUT "N"
     MOV R7, A	; R7 = N
     MOV 96H, A	; 96H = N
     CLR A
     MOV DPTR, #PRIME		;primes look-up table  (in descending order)
     F:MOVC A, @A+DPTR
     CJNE A, 7, $+3
     JC NEXT
     CLR A
     INC DPTR
     SJMP F
NEXT:
     MOV R0, #30H	; LIST OF Pi
     MOV R1, #97H	; LIST OF (Pi-1)
     MOV R5, #0		;COUNT OF PI
     APPEND:
	  CLR A
	  MOVC A, @A+DPTR
          CJNE A, #'0',PROCEED
	  ACALL DO_JOB
	  LJMP SHOW
          PROCEED:MOV R2, A
		       		; PUSHED A IS THE FIRST PRIME SMALLER THAN N
		  MOV B, R7
	          XCH A,B		; A= N, B = FIRST PRIME SMALLER THAN N
       	          DIV AB		; division by prime number, 
		       XCH A,B
		       CJNE A, #0,SKP
		       MOV A, R2
		       MOV @R0, A
		       INC R0
		       DEC A
		       MOV @R1, A
		       INC R1
		       INC R5		; R2 IS COUNT OD PRIME NUMBERS THAT DIVIDE N
		       SKP:
		       	      INC DPTR
			      SJMP APPEND

DO_JOB:
       MOV R0, 30H
       MOV R1, 96H
       MOV A,@R1
       PROC:
       	       MOV B, @R0
       	       XCH A, B
       	       JZ FINISH
       	       XCH A,B
	       DIV AB	; A HAS THE VALUE OF DIVISION
	       MOV R3, A
	       INC R0
	       INC R1
	       MOV B,@R1
	       XCH A, B
	       JZ FINISH
	       XCH A,B
	       MUL AB	; A HAS LOW PART, B HAS HIGH PART
	       MOV R3, A
	       FINISH:
	       		MOV A, R3
	       		RET

CONV:
	mov B, #10
	div AB
	mov R5, B ; save next bit
	orl A, #30H ; convert MSB to ascii
	acall SEND_DATA
	mov A, R5
	orl A, #30H
	acall SEND_DATA
	RET








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
PRIME:	DB	251, 241, 239, 233, 229, 227, 223, 211, 199, 197, 193 ,191, 181, 179, 173, 167, 163, 157, 151, 149, 139, 137, 131, 127, 113, 109, 107, 103, 101, 97, 89, 83, 79, 71, 67, 61, 59, 53, 47, 43, 41, 37, 31, 29, 23, 19, 17, 13, 11, 7, 5, 3, 2, '0'

END
