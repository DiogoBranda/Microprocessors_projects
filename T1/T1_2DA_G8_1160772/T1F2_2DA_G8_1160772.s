﻿;*****************Trabalho_1*******************
.include <m128def.inc>
.cseg; inicio do programa
.org 0 ; que começa nesta linha
	jmp main;salta para o processo main
.cseg ;vai fazer com que seja deixada memoria livre de 0x0 até 0x46
.org 0x46; a posição 0x46
;**************iniciar processador************
inic:
	ldi R16,0b11111111; guarda o valor 0b11111111 na variavel r16
	out DDRC,R16; Define todos os pinos do Portc (leds) como saidas
	ldi R16,0b00000000; guarda o valor 0b0 na variavel r16
	out DDRA,R16; Define todos os pinos do PortA (Switches) como entradas
	ret
Delay:
	push R18 ;guarda na stack o valor de r18 para nao se perder
	push R19 ;guarda na stack o valor de r19 para nao se perder
	push R20 ;guarda na stack o valor de r20 para nao se perder
	ldi R20,132 ;atribui a r18 o valor de 132
	ciclo0: 
		ldi r19,100;atribui a r19 o valor de 100
		ciclo1:
			ldi r18,100;atribui a r20 o valor de 100
			ciclo2:
				dec r18; decrementa 0 r18
				brne ciclo2 ;se o valor da flag z for = 0 vai para o ciclo2
		
			dec r19;decrementa r19
			brne ciclo1 ;se o valor da flag z for = 0 vai para o ciclo1

		dec r20;decrementa r20
		brne ciclo0 ;se o valor da flag z for = 0 vai para o ciclo0
		
	pop r20 ;reatribui o valor de r20 que tinha antes destes ciclos
	pop r19 ;reatribui o valor de r19 que tinha antes destes ciclos
	pop r18 ;reatribui o valor de r18 que tinha antes destes ciclos
	ret
testsw6:	
	sbic PinA,5
	jmp re 
	tes:
		sbis PinA,0; saltar caso sw1 off
		jmp re
		jmp tes
	re: ret
main:
	ldi r16,0xff;guarda o valor 0xff na variavel r16
	out spl,r16;
	ldi r16,0x10;guarda o valor 0x10 na variavel r16
	out sph,r16;
	call inic; chama a funçao inic
		;*******apagar leds********
		ldi R16,0b11111111
		out Portc,R16
	;***************************
testesw1:
	sbis PinA,0; saltar caso sw1 off
	jmp ciclo
	jmp testesw1
ciclo:
	;*******apagar leds********
		ldi R16,0b11111111
		out Portc,R16
	;***************************
		call delay
		call testsw6
		;****acender leds*****
		cbi PortC,0;acende led 1
		call testsw6
		call delay
		call testsw6
		cbi PortC,1;acende led 2
		call testsw6
		call delay
		call testsw6
		cbi PortC,2;acende led 3
		call testsw6
		call delay
		call testsw6
		cbi PortC,3;acende led 4
		call testsw6
		call delay
		call testsw6
		cbi PortC,4;acende led 5
		call testsw6
		call delay
		call testsw6
		cbi PortC,5;acende led 7
		call testsw6
		call delay
		call testsw6
		cbi PortC,6;acende led 6
		call testsw6
		call delay
		call testsw6
		cbi PortC,7;acende o led 8
		;********************
		call testsw6
		call delay
		call testsw6
		jmp ciclo
