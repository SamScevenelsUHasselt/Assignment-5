#ifndef TCNT_H
#define TCNT_H

#define TCNT_BASEADDRESS        0x81000000

#define TCNT_REG0_ADDRESS       (TCNT_BASEADDRESS + 0*4)
#define TCNT_REG1_ADDRESS       (TCNT_BASEADDRESS + 1*4)
#define TCNT_REG2_ADDRESS       (TCNT_BASEADDRESS + 2*4)
#define TCNT_REG3_ADDRESS       (TCNT_BASEADDRESS + 3*4)

#define TCNT_CR                 (*(volatile unsigned int *) TCNT_REG0_ADDRESS)
#define TCNT_CMP                (*(volatile unsigned int *) TCNT_REG1_ADDRESS)
#define TCNT_SR                 (*(volatile unsigned int *) TCNT_REG2_ADDRESS)
#define TCNT_VAL                (*(volatile unsigned int *) TCNT_REG3_ADDRESS)


#define TCNT_CR_CS_DIV8         0x1
#define TCNT_CR_CS_DIV64        0x2
#define TCNT_CR_CS_ON           0x3

#define TCNT_CR_WGM_RESET       0xFFFFFFF3
#define TCNT_CR_WGM_NORMAL      0x0
#define TCNT_CR_WGM_CTC         0x4
#define TCNT_CR_WGM_PWM         0x8
#define TCNT_CR_IR_RESET        0x10


enum counter_mode {
    normal,
    ctc,
    pwm
};

void TCNT_start(void);
void TCNT_start_div8(void);
void TCNT_start_div16(void);
void TCNT_stop(void);
void TCNT_set_mode(enum counter_mode counter_mode);
void TCNT_clear_ir();

#endif