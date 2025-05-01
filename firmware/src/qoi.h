#ifndef QOI_H
#define QOI_H

#define QOI_BASEADDRESS              0x85000000

#define QOI_REG0_ADDRESS             (QOI_BASEADDRESS + 0*4)
#define QOI_REG1_ADDRESS             (QOI_BASEADDRESS + 1*4)
#define QOI_REG2_ADDRESS             (QOI_BASEADDRESS + 2*4)
#define QOI_REG3_ADDRESS             (QOI_BASEADDRESS + 3*4)

#define QOI_PIXELDATA                (*(volatile unsigned int *) QOI_REG0_ADDRESS)
#define QOI_CR                       (*(volatile unsigned int *) QOI_REG1_ADDRESS)
#define QOI_RES                      (*(volatile unsigned int *) QOI_REG2_ADDRESS)
#define QOI_RES_INFO                 (*(volatile unsigned int *) QOI_REG3_ADDRESS)

#define QOI_CR_FL                    0x1

#define QOI_RLE_MASK                 0x400
#define QOI_LEN_MASK                 0x300
#define QOI_RLE_DATA_MASK            0x0FF

unsigned int QOI_put_pixel(unsigned int pixel);
unsigned int QOI_fetch_result(void);
unsigned int QOI_flush(void);

#endif