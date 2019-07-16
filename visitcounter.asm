	LCD_DPort EQU P0
	
	LCD_Rs	EQU  P1.5
	LCD_Rw  EQU  P1.6
	LCD_En	EQU  P1.7
	
	DELAY1	DATA 30h
	DELAY2  DATA 31h
	DELAY3	DATA 32h

/****************************************/
/*-----Here main program start----------*/
/****************************************/
	org  00h

	acall LCD_Init
	acall welcomedata
	call  delay1sec

	mov R1,#00h
	mov P2,#00h
	mov P1,#0Fh
Mainloop:
   jNb P1.0,countinc
   jNb P1.1,countdec

jmp Mainloop
/****************************************/
countinc:
	inc  R1           
	setb P2.0
	call incdisplay
	call displine1A
	call hex_to_ascii
	call delay1sec
	call delay1sec					 
	jmp  mainloop

countdec:
	dec  R1
	cjne R1,#00h,decloop
	clr  P2.0
	call decdisplay
	call displine1A
	call hex_to_ascii
	call delay1sec
	call delay1sec
	jmp  mainloop

decloop:
	call decdisplay
	call displine1A
	call hex_to_ascii
	call delay1sec
	call delay1sec
	jmp  mainloop
/****************************************/
/*-----welcome data programming---------*/
/****************************************/
welcomedata:
	call lcdclear
	call displine1
	mov  dptr,#mydata
	call DISPDATA

	call displine2
	mov  dptr,#mydata1
	call DISPDATA
ret

incdisplay:
	call lcdclear
	call displine1
	mov  dptr,#level1
	call DISPDATA
	ret

decdisplay:
	call lcdclear
	call displine1
	mov  dptr,#level2
	call DISPDATA
	ret


//mydata : DB"Automatic Room",0        
//mydata1: DB"Light Control ",0
mydata : DB"    Visitor   ",0        
mydata1: DB"    Counter   ",0
level1:  DB"Members:      ",0
level2:  DB"Members:      ",0

/******************************************/
hex_to_ascii:	
	mov   a,R1
	DA    a
	anl   a,#0f0h
	swap  a             ;msb
	add   a,#30h
	acall LCD_DATA_OUT    
	acall delay
	
	mov   a,R1
	DA    a
	anl   a,#00fh        ;lsb
	add   a,#30h
	acall LCD_DATA_OUT    
	acall delay
	ret
/******************************************/
/*---LCD initialization program-----------*/
/******************************************/
LCD_Init:
	mov  a,#30h
	call LCD_CMND_OUT
	
	mov  a,#38h
	call LCD_CMND_OUT
	
	mov  a,#06h
	call LCD_CMND_OUT
	
	mov  a,#0Ch
	call LCD_CMND_OUT
	
	mov  a,#01h
	call LCD_CMND_OUT
	
RET
/*******************************************/
/*-------lcd command programming-----------*/
/*******************************************/
LCD_CMND_OUT:
	call lcd_busy
	mov  LCD_DPort,a
	clr  LCD_Rs
	clr  LCD_Rw
	setb LCD_En
	nop
	nop
	clr  LCD_En
RET
/****************************************/
/*-------lcd data programming-----------*/
/****************************************/
LCD_DATA_OUT:
	call lcd_busy
	mov  LCD_DPort,a
	setb LCD_Rs
	clr  LCD_Rw
	setb LCD_En
	nop
	nop
	clr  LCD_En
	RET
/****************************************/
/*----------busy check programming------*/
/****************************************/
lcd_busy:
	mov  LCD_DPort,#0ffh
	CLR  LCD_Rs
	SETB LCD_Rw
AGAIN1:	
	CLR  LCD_EN
	NOP
	NOP
	SETB LCD_EN
	JB p0.7,AGAIN1
	RET	
/***************************************/
/*-----Display the string&send---------*/
/***************************************/

DISPDATA:
Next_Char:
	clr  a
	movc a,@a+dptr
	jz   End_Str
	call LCD_DATA_OUT
	inc  dptr
	jmp  Next_char
End_Str:
	RET
/***************************************/
/*---------display routine-------------*/
/***************************************/
lcdclear:
	mov  a,#01h
	call LCD_CMND_OUT
ret
displine1:
	mov  a,#80h
	call LCD_CMND_OUT
ret
displine2:
	mov  a,#0c0h
	call LCD_CMND_OUT
ret
displine1A:
	mov  a,#8Ah
	call LCD_CMND_OUT
ret
/******************************************/		
/*-------Delay routine-------------------*/
/****************************************/
delay1sec:
		mov  DELAY1,#10		
wait2:	mov  DELAY2,#200 
wait1:	mov  DELAY3,#250
wait:	djnz DELAY3,wait
		djnz DELAY2,wait1
		djnz DELAY1,wait2
		ret
delay:
		mov DELAY1,#0	
same:	djnz DELAY1,same
		ret
	end