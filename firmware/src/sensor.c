#include "sensor.h"

unsigned int SENSOR_fetch(void) {
    unsigned int pixeldata;
    pixeldata = SENSOR_PIXELDATA;
    SENSOR_CR |= SENSOR_CR_RE; 
    SENSOR_CR &= ~SENSOR_CR_RE; 
    return pixeldata;
}

void SENSOR_advance(void) {
    SENSOR_CR = SENSOR_CR_RE; 
}