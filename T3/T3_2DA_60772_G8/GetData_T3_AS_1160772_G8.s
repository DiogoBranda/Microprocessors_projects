#define __SFR_OFFSET 0

#include <avr/interrupt.h>

.extern leituraH
.extern leituraL

.global GetData				

GetData:
		push	r20				 
		push	r21
		push	r22
		push	r23

		clr		r22				;leituraL
		clr		r23				;leituraH

		ldi		r20,4			

recolha:	sbi		ADCSRA,6		

conversao:
		in		r21,ADCSRA		
		andi	r21,0x40		
		brne	conversao   	;Quando a conversão terminar sai deste ciclo

		in		r21,ADCL		
		add		r22,r21
		in		r21,ADCH		
		adc		r23,r21

		dec		r20				;Decrementa o contador de amostras
		
		brne		recolha			;Enquanto não forem obtidas as recolhas pretendidas, fica preso no ciclo recolha

		ldi		r20,2			;Calcula a media
loop1:		lsr		r23				
		ror		r22				
		dec		r20				
		brne		loop1

		sts		leituraL,r22	;Guarda o valor da media
		sts		leituraH,r23

		pop		r23
		pop		r23
		pop		r21
		pop		r20				 
		ret
