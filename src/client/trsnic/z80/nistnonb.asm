;
; NIST
;
; THIS IS AN EXAMPLE OF USING TRSNIC WITH A SIMPLE NON-BLOCKING 
; FIXED RESPONSE SIZE TCP/IP SERVICE LISTENING USING IP ADDRESS AND PORT
;
;

*INCLUDE TRSNIC

;CONNECT TO THE NIST TIME SERVER
;time-a-wwv.nist.gov	132.163.97.1	WWV, Fort Collins, Colorado

DESTIP1		EQU	132		; BYTE 1 OF IP ADDR TO CONNECT
DESTIP2		EQU	163		; BYTE 2 OF IP ADDR TO CONNECT
DESTIP3		EQU	97		; BYTE 3 OF IP ADDR TO CONNECT
DESTIP4		EQU	1			; BYTE 4 OF IP ADDR TO CONNECT
DESTPORT	EQU	13		; TCP PORT TO CONNECT

START::	EQU	$

	LD	DE,DESTPORT	;THE DESTINATION PORT
	LD	H,DESTIP1		;FIRST BYTE OF DEST IP
	LD	L,DESTIP2		;SECOND BYTE OF DEST IP
	LD	B,DESTIP3		;THIRD BYTE OF DEST IP
	LD	C,DESTIP4		;FOURTH BYTE OF DEST IP

	CALL NICINIT		;INITIALIZE TRSNIC

;SET UP FOR RECV

	LD	IX,RESBUF	;IX IS THE INDEX INTO THE RECV BUFFER
	LD	BC,0			;TOTAL RESPONSE BYTE COUNT

DONIC

	PUSH	BC		;SAVE TOTAL RESPONSE BYTE COUNT
	PUSH	IX		;GET BUFFER INDEX INTO HL
	POP		HL

;SET UP RECV PARAMS
	LD	BC,0			;MAX 64K BUFFER SO TOP 2 MSB LEN BYTES ARE ZERO
	LD	DE,RESLEN	;2 LSB ARE THE BUFFER SIZE
	LD	A,1				;USE NON-BLOCKING

	PUSH	IX
	CALL	NICRECV
	POP	IX
	
	ADD	IX,DE		;ADD BYTES RECEIVED TO BUFFER INDEX

	POP	HL			;SAVED BYTE COUNT INTO HL
	ADD	HL,DE		;DE HAS THE BYTES READ ON THIS RECV
	PUSH	HL
	POP		BC

;BC NOW HAS TOTAL BYTES READ SO FAR

;CHECK IF TOTAL RETURN BYTES = EXPECTED RETURN BYTES
	LD	HL,51		;EXPECTED BYTE COUNT IS 51 BYTES
	OR	A						;THESE 3 LINES ARE 16BIT CP
	SBC	HL,BC
	ADD	HL,BC

	JR	NZ,DONIC	;WE HAVE NOT RECEIVED ALL THE BYTES YET, KEEP READING

;WE HAVE THE EXPECTED BYTES

	LD	HL,RESBUF	;HL HAS THE RESPONSE BUFFER

;BCDE HAS THE RESPONSE LENGTH (WE IGNORE 2 UPPER MSB IN BC)

;DO SOMETHING WITH RESPONSE

	CALL	4467H		;PRINT OUT RESPONSE

;CLOSE THE SOCKET

	CALL NICCLOS

	JP	4030H			;EXIT

RESBUF	DS	51		;20 BYTE RESPONSE BUFFER
				DB	13		;CR/LF AT END OF RESPONSE
RESLEN	EQU	51

