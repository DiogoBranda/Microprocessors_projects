;*****************Trabalho_1*******************
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
	ldi R16,0b11000000; guarda o valor 0b0 na variavel r16
	out DDRA,R16; Define todos os pinos do PortA (Switches) como entradas
	ret
main:
	ldi r16,0xff;guarda o valor 0xff na variavel r16
	out spl,r16;
	ldi r16,0x10;guarda o valor 0x10 na variavel r16
	out sph,r16;
	call inic ;chama a funçao inic
		;*******apagar leds********
	sbi PortC,0;apaga led 1
	sbi PortC,1;apaga led 2
	sbi PortC,2;apaga led 3
	sbi PortC,3;apaga led 4
	sbi PortC,4;apaga led 5
	sbi PortC,6;apaga led 7
	sbi PortC,5;apaga led 6
	sbi PortC,7;apaga led 8
	;***************************
ciclo:
	sw1:
		sbis PinA,0;se o pinA entrada 0 estiver com o valor 1 salta a proxima instrução
		jmp sw1on;salta para a instruçao sw1on caso o botao tenha sido usado 
		jmp sw2;
	sw1on:
		;****acender leds*****
		ldi R16,0b11100111 
		out PortC,R16	;acende led 4 e 5
		;********************
		jmp sw2
	sw2:
		sbis PinA,1;se o pinA entrada 1 estiver com o valor 1 salta a proxima instrução
		jmp sw2on;salta para a instruçao sw1on caso o botao tenha sido usado 
		jmp sw3;
	sw2on:
		;****acender leds*****
		ldi R16,0b11011011 
		out PortC,R16	;acende led 4 e 5
		;********************
		jmp sw3
	sw3:
		sbis PinA,2;se o pinA entrada 2 estiver com o valor 1 salta a proxima instrução
		jmp sw3on;salta para a instruçao sw1on caso o botao tenha sido usado 
		jmp sw4;
	sw3on:
		;****acender leds*****
		ldi R16,0b10111101 
		out PortC,R16	;acende led 4 e 5
		;********************
		jmp sw4
	sw4:
		sbis PinA,3;se o pinA entrada 3 estiver com o valor 1 salta a proxima instrução
		jmp sw4on;salta para a instruçao sw1on caso o botao tenha sido usado 
		jmp sw6;
	sw4on:
		;****acender leds*****
		ldi R16,0b01111110 
		out PortC,R16	;acende led 4 e 5
		;********************
		jmp sw6
	sw6:
		sbic PinA,5;se o pinA entrada 5 estiver com o valor 0 salta a proxima instrução
		jmp ciclo
		;****acender leds*****
		sbi PortC,0;acende led 1
		sbi PortC,1;acende led 2
		sbi PortC,2;acende led 3
		sbi PortC,3;acende led 4
		sbi PortC,4;acende led 5
		sbi PortC,6;acende led 7
		sbi PortC,5;acende led 6
		sbi PortC,7;acende o led 8
		;********************
		jmp ciclo
		
