#include <stdio.h>
#include <stdint.h>

#include "print.h"

#define C_WIDTH 8
#define C_HEIGHT 8
#define CHUNK_SIZE 64

struct qoi_header {
    char magic[4]; // magic bytes "qoif"
    uint32_t width; // image width in pixels (BE)
    uint32_t height; // image height in pixels (BE)
    uint8_t channels; // 3 = RGB, 4 = RGBA
    uint8_t colorspace; // 0 = sRGB with linear alpha
                        // 1 = all channels linear
};

struct qoi_image_chunk {
    uint8_t chunk_byte[CHUNK_SIZE];
    uint8_t size;
    struct qoi_image_chunk *next;
};

void irq_handler(unsigned int cause) {

}

void initialise(uint8_t r[C_WIDTH][C_HEIGHT], uint8_t g[C_WIDTH][C_HEIGHT], uint8_t b[C_WIDTH][C_HEIGHT], uint8_t a[C_WIDTH][C_HEIGHT]) {
    uint8_t w, h;

    for(h=0;h<C_HEIGHT/2;h++) {
        for(w=0;w<C_WIDTH/2;w++) {
            r[h][w] = 255; g[h][w] = 0; b[h][w] = 0; a[h][w] = 255;
        }
        for(w=C_WIDTH/2;w<C_WIDTH;w++) {
            r[h][w] = 0; g[h][w] = 255; b[h][w] = 0; a[h][w] = 255;
        }
    }
    for(h=C_HEIGHT/2;h<C_HEIGHT;h++) {
        for(w=0;w<C_WIDTH/2;w++) {
            r[h][w] = 0; g[h][w] = 0; b[h][w] = 255; a[h][w] = 255;
        }
        for(w=C_WIDTH/2;w<C_WIDTH;w++) {
            r[h][w] = 127; g[h][w] = 127; b[h][w] = 127; a[h][w] = 255;
        }
    }
}


void store_byte(struct qoi_image_chunk **current, const uint8_t to_store, uint8_t* image_chunk_index) {

    print_chr(to_store);

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
}


int main(void) {


    uint8_t r[C_HEIGHT][C_WIDTH];
    uint8_t g[C_HEIGHT][C_WIDTH];
    uint8_t b[C_HEIGHT][C_WIDTH];
    uint8_t a[C_HEIGHT][C_WIDTH];

    uint8_t r_prev = 0;
    uint8_t g_prev = 0;
    uint8_t b_prev = 0;
    uint8_t a_prev = 255;

    int8_t dr, dg, db;


    int8_t rle = -1;
    uint32_t running_array[64];
    uint8_t rv;
    uint8_t index;
    uint32_t value;

    //storage objects
    struct qoi_header header;
    header.magic[0] = 'q';
    header.magic[1] = 'o';
    header.magic[2] = 'i';
    header.magic[3] = 'f';
    header.width = C_WIDTH;
    header.height = C_HEIGHT;
    header.channels = 3; //RGBA
    header.colorspace = 0;

    struct qoi_image_chunk element;
    element.next = 0;
    struct qoi_image_chunk *first = &element;
    struct qoi_image_chunk *current = &element;
    uint8_t image_chunk_index = 0;

    /* Sanity check */
    if((C_WIDTH % 2) || (C_HEIGHT % 2)) {
        //printf("ERROR: W or H not even");
        return 1;
    }

    /* Initialisation */
    initialise(r, g, b, a);
    for(uint8_t i=0;i<64;i++) {
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
    store_byte(&current, header.colorspace,                 &image_chunk_index);

    /* Loop over pixels */
    for(uint8_t h=0;h<C_HEIGHT;h++) {
        for(uint8_t w=0;w<C_WIDTH;w++) {



            //STEP 1 ------ check if equal to previous pixel ---------------------------------------------------------------------------------------------------------------------
            if (r[h][w] == r_prev && g[h][w] == g_prev && b[h][w] == b_prev && a[h][w] == a_prev) {
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
                index =  (r[h][w] * 3 + g[h][w] * 5 + b[h][w] * 7 + a[h][w] * 11) % 64; //possible bottleneck
                value =  (r[h][w] << 24) + (g[h][w] << 16) + (b[h][w] << 8) + a[h][w];
                if (running_array[index] == value) { //The pixel is in the running array
                    store_byte(&current, index, &image_chunk_index);
                }
                else {//if not store it anyway and continue
                    running_array[index] = value;
                    //STEP 3 ------ check difference with previous pixels --------------------------------------------------------------------------------------------------------
                    if (a[h][w] == a_prev) {
                        dr = (int8_t)(r[h][w] - r_prev);
                        dg = (int8_t)(g[h][w] - g_prev);
                        db = (int8_t)(b[h][w] - b_prev);

                        if ( (-2 <= dr && dr <= 1)&&(-2 <= dg && dg <= 1)&&(-2 <= db && db <= 1)) { //can encode in QOI_OP_DIFF chunk
                            rv = 0b01000000 + ((uint8_t)(dr+2)<<4) + ((uint8_t)(dg+2)<<2) + (uint8_t)(db+2);
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
                            store_byte(&current, r[h][w], &image_chunk_index);
                            store_byte(&current, g[h][w], &image_chunk_index);
                            store_byte(&current, b[h][w], &image_chunk_index);
                        }
                    }
                    else {
                        //STEP 5 ------ store raw RGBA -------------------------------------------------------------------------------------------------------------------------------
                        rv = 0b11111111;
                        store_byte(&current, rv, &image_chunk_index);
                        store_byte(&current, r[h][w], &image_chunk_index);
                        store_byte(&current, g[h][w], &image_chunk_index);
                        store_byte(&current, b[h][w], &image_chunk_index);
                        store_byte(&current, a[h][w], &image_chunk_index);
                    }
                }
                r_prev = r[h][w];
                g_prev = g[h][w];
                b_prev = b[h][w];
                a_prev = a[h][w];
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

    

    current = first;
    while (current != 0) {
        for(uint8_t i=0;i<current->size;i++) {
            print_chr(current->chunk_byte[i]);
        }
        current = current->next;
    }
    while (1){}
}