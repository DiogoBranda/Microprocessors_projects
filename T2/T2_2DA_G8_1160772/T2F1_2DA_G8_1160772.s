;Trabalho_2
;***************************"main"**********************************************
.include <m128def.inc>
.def numero=r23;define r23 como numero
.def F5ms=r24; define a flag que informa que passaram 5 ms
.def F500ms=r25;define a flag que informa que passaram 500 ms
.def s3=r22;define a flag que informa que passaram 3 s
.def count5ms=r21;define a flag que informa que o numero de vezes que passaram 1ms
.def count500ms=r20;define a flag que informa que o numero de vezes que passaram 1ms em 500ms
.def ativar500ms=r19;ativa a contagem de 500ms 
.def numeroreal=r18
.cseg
.org 0
	jmp	main
.org 0x1E
	jmp int_tc0
.org 0x46
table:
	.DB 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90
inic:
;inicializar processador
	ldi r16,0b11111111
	out PortA,r16;apagar os leds
	out DDRA,r16;Defenir o DDRA (leds) como saidas
	out PortC,r16;apagar os displays
	out DDRC,r16
	ldi r16,0b11000000
	out PortD,r16
	out DDRD,r16
;inicializar timer
	ldi r16,62;atribui a ocr0 o valor de 62
	out ocr0,r16
	Ldi r16,0b00001110;tccr0 modo ctc,prescaler 256,oc0 off
	out Tccr0,r16
	in r16,TIMSK;enable da interropeçao oc0 
	ori r16,0b00000010 
	out TIMSK,r16

;inicializar variaveis
	ldi numero,0
	ldi s3,3
	ldi F5ms,0
	ldi F500ms,0
	ldi count5ms,0
	ldi count500ms,100
	ldi	ativar500ms,0
	clt ;flag t igual a zero 
	sei
	ret	
main:
	ldi r16,0xff;guarda o valor 0xff na variavel r16
	out spl,r16;
	ldi r16,0x10;guarda o valor 0x10 na variavel r16
	out sph,r16;
	call inic; chama a funçao inic
;********************fim "main"****************************
;**************ciclo principal*******************************
ciclo:;enquanto a flag de t for igual a 0 ele nao saira deste ciclo, a flag de t so passa a um 
	sbic pinD,0
	JMP ciclo;quando a int0 é ativada ouseja quando o botao de start é premido
roleta:;se foi premido entao vai entrar na "roleta" 
	mov numeroreal,numero
	call display;vai chamar a funçao para mostrar os numeros no display
	cpi numero,9;se o numero for igual a nove temos de dar reset ao numero para começar do zero
	breq resetnumero;se o numero for igual a nove vai para o reset do numero
	inc numero;senao for igual a zero vai encrementar o numero
	ldi r16,0;para esperar 5 ms temos de por o timer a zero 
	out tcnt0,r16
espera5ms:;vai esperar 5 ms
	cpi F5ms,1;se a flag for igual a 1 ja passaram 5 ms 
	brne espera5ms; se nao quer diser que ainda tem de esperar
	ldi F5ms,0; da reset na flag para da proxima vez que tiver de esperar 5 ms
	sbic pinD,1
	JMP ROLETA
	ldi ativar500ms,1;se carregaram no stop ligamos a flag de 500 ms
numeroselec:;e entao temos de mostrar o numero selcionado
	ldi r16,0;da reset ao timer 
	out tcnt0,r16
	ldi count500ms,0
	ldi count5ms,0
	espera500msli:;espera 500 ms com o visor ligado
		cpi f500ms,1
		brne espera500msli
		ldi F500ms,0
	ldi r16,0b11111111
	out PortC,r16;apagar os leds
	ldi r16,0;da rest ao timer
	out tcnt0,r16
	ldi count500ms,0
	ldi count5ms,0
	espera500msdes:;espera 500 ms com o visor desligado
		cpi f500ms,1
		brne espera500msdes
		ldi F500ms,0
	mov numero,numeroreal
	call display;liga o led novamente
	dec s3;decrementa o contador de 3 segundos
	brne numeroselec;se ele for diferente de zero repete pois ainda nao passsaram 3 seg
	ldi s3,3;se for igual a zero faz reset ao contador e vai para o ciclo start
	ldi ativar500ms,0
	jmp ciclo;e espera que alguem carregue novamente no start
;***********************fim ciclo principal*******************************
;*************************funçoes ***************************************
resetnumero:
	ldi numero,0
	ldi r16,0
	out tcnt0,r16
	jmp espera5ms
	
Display:
	LDI ZH,high(table<<1)
	LDI Zl,low(table<<1)
	lpm r17,Z	
	ADD Zl,numero
	lpm r17,Z
	out portC,r17
	ret

int_tc0:;int do timer
	push r16;guarda o valor de r16 na stack
	in r16,sreg
	push r16;guarda o valor do vetor de registos
;ciclo 5 ms
	inc count5ms;sempre que passar 1ms encrementa um 
	cpi count5ms,5;compara se passsou 5ms 
	brne fimint;se nao passou 1ms vai para o fim do ciclo
	ldi count5ms,0;se passsou 5ms da rest ao contador de 5ms 
	ldi f5ms,1;sinaliza que passou 5 ms
;ciclo500ms
	cpi ativar500ms,1;ve se a se pretende contar 500ms
	brne fimint;se nao se pretender salta para o fim 
	inc	count500ms ;se se pretender começa a encrementar o contador de 500ms
	cpi count500ms,100;compara se se passaram 100 ciclos
	brne fimint ;se nao se passaram salta para o fim
	ldi f500ms,1;se se passaram sinaliza que passaram 500ms
	ldi count500ms,0;da rest ao conta dor de 500ms 
fimint:
	pop r16
	out sreg,r16
	pop r16
	reti
	
;************************Fim funçoes***********************************
