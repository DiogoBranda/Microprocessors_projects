;Trabalho_1
.include <m128def.inc>
.def lugares=r23
.def FlagE = r24
.def FlagS = r25

.cseg; inicio do programa
.org 0 ; que começa nesta linha
	jmp main;salta para o processo main
.cseg ;vai fazer com que seja deixada memoria livre de 0x0 até 
.org 0x46; a posição 0x46
table:
	.DB 0x90,0x80,0xF8,0x82,0x92,0x99,0xB0,0xA4,0xF9,0xC0
;iniciar processador
inic:
	ldi r16,0b11111111
	out PortA,r16;(portA) apagar os leds
	ldi R16,0b11111111
	out DDRA,r16;Defenir o DDRA (leds) como saidas
	ldi r16,0x90
	out PortC,r16;(Portc) defenir o display com o numero zero
	ldi R16,0b11111111
	out DDRC,r16;Defenir o DDRC (Displays) como saidas
	ldi R16,0b11000000
	out portD,r16;Defenir o portD para o display da direita como saidas e entrada
	ldi R16,0b11000000
	out DDRD,r16;Defenir o DDRD (switchs) como saidas e set display como entradas
	ldi FlagE,0
	ldi FlagS,0

	ret
;Delays
delay:
	push R18 ;guarda na stack o valor de r18 para nao se perder
	push R19 ;guarda na stack o valor de r19 para nao se perder
	push R20 ;guarda na stack o valor de r20 para nao se perder
	ldi R20,2 ;atribui a r18 o valor de 132
	ciclod0 :
		ldi r19,65;atribui a r19 o valor de 100
		ciclod1:
			ldi r18,40;atribui a r20 o valor de 100
			ciclod2:
				dec r18; decrementa 0 r18
				brne ciclod2 ;se o valor da flag z for = 0 vai para o ciclo2
		
			dec r19;decrementa r19
			brne ciclod1 ;se o valor da flag z for = 0 vai para o ciclo1
			
		dec r20;decrementa r20
		brne ciclod0 ;se o valor da flag z for = 0 vai para o ciclo0
		
	pop r20 ;reatribui o valor de r20 que tinha antes destes ciclos
	pop r19 ;reatribui o valor de r19 que tinha antes destes ciclos
	pop r18 ;reatribui o valor de r18 que tinha antes destes ciclos
	ret
delay2:
	push R18 ;guarda na stack o valor de r18 para nao se perder
	push R19 ;guarda na stack o valor de r19 para nao se perder
	push R20 ;guarda na stack o valor de r20 para nao se perder
	ldi R20,118 ;atribui a r18 o valor de 132
	ciclo0 :
		ldi r19,150;atribui a r19 o valor de 100
		ciclo1:
			ldi r18,150;atribui a r20 o valor de 100
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
;Displays
Display:
	out PortC,lugares;defenir o display com o numero nove
	cpi lugares,0xC0
	breq nove
	ldi r16,0b10111111
	out PortA,r16;acender o led
	jmp fim
nove:
	ldi r16,0xC0
	out PortC,r16
	ldi r16,0b11111111
	out PortA,r16;apagar o led de entrada de carros
	cpi FlagE,0
	brne fim
	ldi r16,0b01111111
	out PortA,r16;Fechar portao
	jmp pisca
fim:
	ret
;inicio
main:
	ldi r16,0xff;guarda o valor 0xff na variavel r16
	out spl,r16;
	ldi r16,0x10;guarda o valor 0x10 na variavel r16
	out sph,r16;
	call inic; chama a funçao inic
	LDI ZH,high(table<<1)
	LDI Zl,low(table<<1)
	Lpm lugares,Z
	jmp TesteSensor
TesteSensor:
	Lpm lugares,Z
	call display
	in r16,PinD;Le o valor do pinD
	andi r16,0b00000011;limpa o valor do que nao nos enteressa
	call delay
	in r17,PinD;Le o valor do pinD
	andi r17,0b00000011;limpa o valor do que nao nos enteressa
	cp R16,R17;compra os valores se 
	brne TesteSensor
Sw1:
	cpi FlagE,0 
	brne TesteFlagE
	cpi Lugares,0xC0
	breq Sw2
	sbic PinD,0;Se o butao tiver sido permido
	jmp Sw2
	inc Zl
	Ldi FlagE,1
Sw2:
	cpi FlagS,0 
	brne TesteFlagS
	cpi Lugares,0x90
	breq TesteSensor
	sbic PinD,1;Se o butao tiver sido permido
	jmp TesteSensor
	dec Zl
	Ldi FlagS,1
	jmp TesteSensor
TesteFlagE:
	sbis PinD,0
	jmp Sw2
	Ldi FlagE,0
	jmp Sw2
TesteFlagS:
	sbis PinD,1
	jmp TesteSensor
	Ldi FlagS,0
	jmp TesteSensor
pisca:
	call delay2
	ldi r16,0b11111111
	out PortC,r16
	call delay2
	ldi r16,0xC0
	out PortC,r16
	jmp fim
