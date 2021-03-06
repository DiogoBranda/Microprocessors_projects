/*
 * Created: 21/11/2017 08:51:11
 * Author : Diogo Silva
 */
#include <avr/interrupt.h>
#define ppwm(pw) ((pw*255)/100)

const unsigned char tabela[]={0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, 0xff,0xbf,0x8e}; //0x8e -> 'F' | 0xff -> display desligado
volatile unsigned char cont_disp ,digito[4]={10,10,10,0},pwm,sentido=1,sw,cont;

void display(void){
    PORTA=cont_disp<<6;                                                                        //shift para os dois digitos mais significativoso do PORTA
    PORTC=tabela[digito[cont_disp]];                                                           //coloca no display correspondente ao valor do contador no momento, o valor que é indicado na função processar display
    cont_disp++;                                                                               //incrementa o contador do display
    if (cont_disp==4)                                                                          //Quando o contador for 4 o contador regressa a 0
    cont_disp=0;                                                                           // contador do display a 0
}
void processar_display(void){
  digito[0]=10;
  digito[2]=pwm/10;
  digito[3]=pwm%10;
  if (sentido==0)
    digito[1]=11;
  else
    digito[1]=10;
}

void init(void){
  // switches e selecionador de display
  DDRA=0b11000000;
  //motor
  DDRB=0b11100000;
  PORTB=0b0110000;//Pb6 e PB5 a um para parar o motor
  //displays
  DDRC=0xff;//tudo saidas
  PORTC=0xff;//tudo apagado
  //timer 5ms
  OCR0=77;
  TCCR0=0b00001111;
  TIMSK|=0b00000010;
  //configurar timer2 para pwm do motor
  OCR2=0;
  TCCR2=0b01100011;
  SREG|=0x80;
}
ISR(TIMER0_COMP_vect){
  cont++;
  display();
}
void process_sw(void){
  sw=PINA&0b00111111;//usa a mascara para eliminar os bits que nao sao precisos
  switch(sw){
    case(0b00111110):
      pwm=25;
      OCR2=ppwm(pwm);
      processar_display();
      break;
    case(0b00111101):
      pwm=50;
      OCR2=ppwm(pwm);
      processar_display();
      break;
    case(0b00111011):
      pwm=70;
      OCR2=ppwm(pwm);
      processar_display();
      break;
    case(0b00110111):
      pwm=90;
      OCR2=ppwm(pwm);
      processar_display();
      break;
    case(0b00101111):
      if (sentido==1){          //se sentido positivo tera de mudar para negativo
        OCR2=0;
        PORTB=0b00000000;
        cont=0;
        while(cont!=100);
        PORTB=0b00100000;
        OCR2=(pwm*255)/100;
        sentido=0;
      }
      else{
        OCR2=0;
        PORTB=0b00000000; //parar motor
        cont=0;
        while(cont!=100);
        PORTB=0b01000000;
        OCR2=(pwm*255)/100;
        sentido=1;
    }
      processar_display();
      break;
      case(0b00011111):
        pwm=0;
        OCR2=ppwm(pwm);
        PORTB=0b0110000;
        processar_display();
      break;
    }

}
int main(void){
  init();
  while(1){
        process_sw();
  }
}

