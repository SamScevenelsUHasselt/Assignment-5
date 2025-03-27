#include "tcnt.h"

#define LED_BASEAxDDRESS 0x80000000

#define LED_REG0_ADDRESS (LED_BASEAxDDRESS + 0*4)

#define LED              (*(volatile unsigned int *) LED_REG0_ADDRESS)


void irq_handler(unsigned int cause) {

	static unsigned int counter;

    if (counter >= 7)
    {
        LED = 0xFFFFFFFF;
        counter = 0;
    }else if (counter%2)
    {
        LED = 0x1;
        counter++;
    }else{
        LED = 0x0;
        counter++;
    }

    TCNT_clear_ir();
    return;
}

void main(void) {

    TCNT_CMP = 12500000; //500ms on a clock of 25MHz
    TCNT_set_mode(ctc);
    TCNT_start();

    while(1) {
        //keeps pc constant, easier for debugging
    }
}
