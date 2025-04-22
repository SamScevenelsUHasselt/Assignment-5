#include <stdio.h>
#include <stdint.h>

#include "sensor.h"
#include "print.h"

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

struct qoi_image_chunk {
    unsigned char chunk_byte[CHUNK_SIZE];
    unsigned char size;
    struct qoi_image_chunk *next;
};

void irq_handler(unsigned int cause) {

}

void store_byte(struct qoi_image_chunk **current, const unsigned char to_store, unsigned char* image_chunk_index) {

    //print_str("Storing: X");
    //print_hex(to_store,2);
    if (STORE_IN_MEM == 1){
        struct qoi_image_chunk *chunk = *current;
        chunk->chunk_byte[*image_chunk_index] = to_store;
        chunk->size = *image_chunk_index + 1;
        *image_chunk_index += 1;
        if(*image_chunk_index >= CHUNK_SIZE){ //chunk is full make a new one
            struct qoi_image_chunk new; //init new chunk
            new.next = 0;
            chunk->next = &new; //point to new chunk from current chunk
            *current = chunk; //update the current pointer to point at the new chunk
            *image_chunk_index = 0;
        }
        return;
    }else{
        print_hex(to_store,2);
    }
    
    
}

int main(void) {

    //print_str("Sensor Height: ");
    //print_dec(SENSOR_get_height());
    //print_str("Sensor Width: ");
    //print_dec(SENSOR_get_width());

    unsigned char r, r_prev = 0;
    unsigned char g, g_prev = 0;
    unsigned char b, b_prev = 0;
    unsigned char a, a_prev = 255;

    signed char dr, dg, db;

    signed char rle = -1;
    unsigned int running_array[64];
    unsigned char rv;
    unsigned char index;
    unsigned int value;

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

    struct qoi_image_chunk element;
    element.next = 0;
    struct qoi_image_chunk *first = &element;
    struct qoi_image_chunk *current = &element;
    unsigned char image_chunk_index = 0;

    /* Initialisation */
    for(unsigned char i=0;i<64;i++) {
        running_array[i] = 0;
    }

    //Store header
    store_byte(&current, header.magic[0],               &image_chunk_index);
    store_byte(&current, header.magic[1],               &image_chunk_index);
    store_byte(&current, header.magic[2],               &image_chunk_index);
    store_byte(&current, header.magic[3],               &image_chunk_index);
    store_byte(&current,(header.width&0xFF000000)<<24,  &image_chunk_index);
    store_byte(&current,(header.width&0x00FF0000)<<16,  &image_chunk_index);
    store_byte(&current,(header.width&0x0000FF00)<<8,   &image_chunk_index);
    store_byte(&current,(header.width&0x000000FF),      &image_chunk_index);
    store_byte(&current,(header.height&0xFF000000)<<24, &image_chunk_index);
    store_byte(&current,(header.height&0x00FF0000)<<16, &image_chunk_index);
    store_byte(&current,(header.height&0x0000FF00)<<8,  &image_chunk_index);
    store_byte(&current,(header.height&0x000000FF),     &image_chunk_index);
    store_byte(&current, header.channels,               &image_chunk_index);
    store_byte(&current, header.colorspace,             &image_chunk_index);

    /* Loop over pixels */
    for(unsigned char h=0;h<height;h++) {
        for(unsigned char w=0;w<width;w++) {
            
            value = SENSOR_fetch();
            r = (unsigned char)(value >> 24);
            g = (unsigned char)(value >> 16);
            b = (unsigned char)(value >> 8);
            a = (unsigned char)(value);

            //int pixel = (r << 24) | (g << 16) | (b << 8) | a;
            //print_str("Pixel: X");
            //print_hex(pixel,8);
            //print_str("\n");

            //STEP 1 ------ check if equal to previous pixel ---------------------------------------------------------------------------------------------------------------------
            if (r == r_prev && g == g_prev && b == b_prev && a == a_prev) {
                rle++;
                if (rle>62) { //Ensure that rle does not exceed 62 as this is illegal and store the current QOI_OP_RUN chunk
                    rv = rle + 0b11000000;
                    store_byte(&current, rv, &image_chunk_index);
                    rle = -1;
                }
            }
            else{
                if (rle != -1) { //if rle != -1 then store QOI_OP_RUN chunk
                    rv = rle + 0b11000000;
                    store_byte(&current, rv, &image_chunk_index);
                    rle = -1;
                }

                //STEP 2 ------ check if in the running array --------------------------------------------------------------------------------------------------------------------

                index =  (sw_mult(r , 3) + sw_mult(g , 5) + sw_mult(b , 7) + sw_mult(a , 11)) % 64; //possible bottleneck

                if (running_array[index] == value) { //The pixel is in the running array
                    store_byte(&current, index, &image_chunk_index);
                }
                else {//if not store it anyway and continue
                    running_array[index] = value;
                    //STEP 3 ------ check difference with previous pixels --------------------------------------------------------------------------------------------------------
                    if (a == a_prev) {
                        dr = (signed char)(r - r_prev);
                        dg = (signed char)(g - g_prev);
                        db = (signed char)(b - b_prev);

                        if ( (-2 <= dr && dr <= 1)&&(-2 <= dg && dg <= 1)&&(-2 <= db && db <= 1)) { //can encode in QOI_OP_DIFF chunk
                            rv = 0b01000000 + ((unsigned char)(dr+2)<<4) + ((unsigned char)(dg+2)<<2) + (unsigned char)(db+2);
                            store_byte(&current, rv, &image_chunk_index);
                        }
                        else if (-32 <= dg && dg <= 31) { //green dif value can be stored so we compute the dr_dg and db_dg
                            dr = dr = dg;
                            db = db = dg;
                            if ((-8 <= dr && dr <= 7)&&(-8 <= db && db <= 7)) { // can encode in QOI_OP_LUMA chunk
                                rv = 0b10000000 + (dg+32);
                                store_byte(&current, rv, &image_chunk_index);
                                rv = ((dr + 8)<<4) + (db+8);
                                store_byte(&current, rv, &image_chunk_index);
                            }
                        }
                        else { //store as RGB as alpha has not changed -----------------------------------------------------------------------------------------------------------
                            rv = 0b11111110;
                            store_byte(&current, rv, &image_chunk_index);
                            store_byte(&current, r, &image_chunk_index);
                            store_byte(&current, g, &image_chunk_index);
                            store_byte(&current, b, &image_chunk_index);
                        }
                    }
                    else {
                        //STEP 5 ------ store raw RGBA -------------------------------------------------------------------------------------------------------------------------------
                        rv = 0b11111111;
                        store_byte(&current, rv, &image_chunk_index);
                        store_byte(&current, r, &image_chunk_index);
                        store_byte(&current, g, &image_chunk_index);
                        store_byte(&current, b, &image_chunk_index);
                        store_byte(&current, a, &image_chunk_index);
                    }
                }
                r_prev = r;
                g_prev = g;
                b_prev = b;
                a_prev = a;
            }
        }
    }

    //check rle
    if (rle != -1) { //check if rle still has something
        rv = rle + 0b11000000;
        store_byte(&current, rv, &image_chunk_index);
        rle = -1;
    }

    //end marker
    rv = 0;
    store_byte(&current, rv, &image_chunk_index);
    store_byte(&current, rv, &image_chunk_index);
    store_byte(&current, rv, &image_chunk_index);
    store_byte(&current, rv, &image_chunk_index);
    store_byte(&current, rv, &image_chunk_index);
    store_byte(&current, rv, &image_chunk_index);
    store_byte(&current, rv, &image_chunk_index);
    rv = 1;
    store_byte(&current, rv, &image_chunk_index);

    
    if (STORE_IN_MEM == 1){
        current = first;
        while (current != 0) {
            for(unsigned char i=0;i<current->size;i++) {
                print_hex(current->chunk_byte[i],2);
            }
            current = current->next;
        }
    }
    
    while (1){}
}