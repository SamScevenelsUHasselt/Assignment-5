#include "qoi.h"

unsigned int QOI_put_pixel(unsigned int pixel){
    QOI_PIXELDATA = pixel;
    return QOI_RES_INFO;
}


unsigned int QOI_flush(void){
    QOI_CR = 0x01;
    return QOI_RES_INFO;
}

void QOI_start(void){
    QOI_CR = 0x00;
}

