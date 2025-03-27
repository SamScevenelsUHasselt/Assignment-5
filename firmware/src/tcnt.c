#include "tcnt.h"

void TCNT_start(void) {
    TCNT_CR = TCNT_CR | TCNT_CR_CS_ON;
}

void TCNT_start_div8(void) {
    TCNT_stop();
    TCNT_CR = TCNT_CR | TCNT_CR_CS_DIV8;
}

void TCNT_start_div16(void) {
    TCNT_stop();
    TCNT_CR = TCNT_CR | TCNT_CR_CS_DIV64;
}

void TCNT_stop(void) {
    TCNT_CR = TCNT_CR & ~(TCNT_CR_CS_ON);
}

void TCNT_set_mode(enum counter_mode counter_mode){
    TCNT_CR = TCNT_CR & TCNT_CR_WGM_RESET;
    switch (counter_mode)
    {
    case ctc:
        TCNT_CR = TCNT_CR | TCNT_CR_WGM_CTC;
        break;
    case pwm:
        TCNT_CR = TCNT_CR | TCNT_CR_WGM_PWM;
        break;
    
    default:
        break;
    }
}

void TCNT_clear_ir(){
    TCNT_CR = TCNT_CR | TCNT_CR_IR_RESET;
}