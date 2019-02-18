#include <avr/interrupt.h>
#include <stdio.h>
#define  F_CPU 16000000UL
#include <util/delay.h>
//const unsigned char passos[]={0b00001001,0b00001001,0b00001001,0b00001001};
const unsigned char passos[]={9,12,6,3};

volatile unsigned char sw,i,sel_passo=20, cont_passo=0,passo_0_graus=20,cont,cont_M;

typedef struct USARTRX {
	char receiver_buffer;
	unsigned char status;
	unsigned char receive:1;
	unsigned char error:1;
}USARTRX;
volatile USARTRX rxUSART={0,0,0,0};
char transmit_buffer[10];


void incr_passo(void){
	cont_passo++;
	if (cont_passo==4){
		cont_passo==0;
	}
	PORTE=passos[cont_passo];
	_delay_ms(25);
}
void decr_passo(void){
	cont_passo--;
	if (cont_passo==255){
		cont_passo==3;
	}
	PORTE=passos[cont_passo];
	_delay_ms(25);
}

void send_message(char *buffer){
	unsigned char i=0;
	while(buffer[i]!='\0'){
		while ((UCSR1A & 1<<UDRE1)==0);
		UDR1=buffer[i];
		i++;
	}
}

ISR(USART1_RX_vect){
	rxUSART.status=UCSR1A;
	if(rxUSART.status & ((1<<FE1)|(1<<DOR1)|(1>>UPE1)))
	{rxUSART.error=1;}
	rxUSART.receiver_buffer=UDR1;
	rxUSART.receive=1;
}
void init(void){
	//motor
	DDRF=0b11111111;
	//timer 5ms
	OCR0=77;
	TCCR0=0b00001111;
	TIMSK|=0b00000010;
	//usart
	UBRR1H=1;
	UBRR1L=160;
	UCSR1A=(1<<U2X1);
	UCSR1B=(1<<RXCIE1)|(1<<RXEN1)|(1<<TXEN1);
	UCSR1C=(1<<UCSZ11)|(1<<UCSZ10);
	sei();

}
void process_usart(void){
	sw=rxUSART.receiver_buffer ;//usa a mascara para eliminar os bits que nao sao precisos
	switch(sw){
		case('r'):
		if(sel_passo<40){
			incr_passo();
			sel_passo++;}
			else
				send_message("Limite atingido");
		break;
		case('l'):
		if(sel_passo>0){
			decr_passo();
			sel_passo--;}
		else
			send_message("Limite atingido");
		break;
		case('z'):
		if(sel_passo>passo_0_graus){
			while(sel_passo!=passo_0_graus){
				decr_passo();
			}
			sel_passo=20;
			send_message("Ir para zero");
		}
		if(sel_passo<passo_0_graus){
			while(sel_passo!=passo_0_graus){
				incr_passo();
			}
			sel_passo=20;
			send_message("Ir para zero");
			
		}
		break;
		case('s'):
		sel_passo=20;
		break;
	}
}

int main(void){
	init();
	while(1){
		if(rxUSART.receive==1){
			if(rxUSART.error==1){
				rxUSART.error=0;
			}
			else{
				sprintf(transmit_buffer,"Tecla:%c\r\n",rxUSART.receiver_buffer);
				send_message(transmit_buffer);
				process_usart();
			}
			rxUSART.receive=0;
		}
	}
}

