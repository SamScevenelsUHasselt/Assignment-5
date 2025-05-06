#include <stdio.h>
#include <stdint.h>

#include "sensor.h"
#include "print.h"
#include "qoi.h"

#define CHUNK_SIZE 64
#define STORE_IN_MEM 0

extern unsigned int sw_mult(unsigned int x, unsigned int y);
extern void load_test();


struct qoi_header {
    char magic[4]; // magic bytes "qoif"
    unsigned int width; // image width in pixels (BE)
    unsigned int height; // image height in pixels (BE)
    unsigned char channels; // 3 = RGB, 4 = RGBA
    unsigned char colorspace; // 0 = sRGB with linear alpha
                        // 1 = all channels linear
};

void irq_handler(unsigned int cause) {

}


int main(void) {

    unsigned int width = SENSOR_get_width();
    unsigned int height = SENSOR_get_height();

    //storage objects
    struct qoi_header header;
    header.magic[0] = 'q';
    header.magic[1] = 'o';
    header.magic[2] = 'i';
    header.magic[3] = 'f';
    header.width = width;
    header.height = height;
    header.channels = 3; //RGBA
    header.colorspace = 0;

    //Store header
    print_chr(header.magic[0]);
    print_chr(header.magic[1]);
    print_chr(header.magic[2]);
    print_chr(header.magic[3]);
    print_chr((header.width >> 24) & 0xFF);
    print_chr((header.width >> 16) & 0xFF);
    print_chr((header.width >> 8)  & 0xFF);
    print_chr((header.width >> 0)  & 0xFF);
    print_chr((header.height >> 24) & 0xFF);
    print_chr((header.height >> 16) & 0xFF);
    print_chr((header.height >> 8)  & 0xFF);
    print_chr((header.height >> 0)  & 0xFF);
    print_chr(header.channels);
    print_chr(header.colorspace);

    unsigned int value;
    unsigned int result_info;
    unsigned int result;
    unsigned int chunk_len;
    
    /* Loop over pixels */
    for(unsigned char h=0;h<height;h++) {
        for(unsigned char w=0;w<width;w++) {
            value = SENSOR_fetch();
            
            result_info = QOI_put_pixel(value);
            if ((result_info & QOI_RLE_MASK) == QOI_RLE_MASK){ //RLE has ended, store the chunk
                print_chr(result_info & QOI_RLE_DATA_MASK);
            }
            chunk_len = result_info & QOI_LEN_MASK;
            switch (chunk_len)
            {
            case 0x100: //1 Byte chunk
                result = QOI_fetch_result();
                print_chr(result);
                break;
            case 0x200: //2 Byte chunk
                result = QOI_fetch_result();
                print_chr(result>>8);
                print_chr(result);
                break;
            case 0x300: //4 Byte chunk
                result = QOI_fetch_result();
                print_chr(result>>24);
                print_chr(result>>16);
                print_chr(result>>8);
                print_chr(result);
                break;
            default: //no chunk
                break;
            }
        }
    }

    //check rle
    result_info = QOI_flush();
    if ((result_info & QOI_RLE_MASK) == QOI_RLE_MASK){ //RLE still had something, store it
        print_chr(result_info && QOI_RLE_DATA_MASK);
    }

    //end marker
    print_chr(0);
    print_chr(0);
    print_chr(0);
    print_chr(0);
    print_chr(0);
    print_chr(0);
    print_chr(0);
    print_chr(1);
    
    while (1){}
}