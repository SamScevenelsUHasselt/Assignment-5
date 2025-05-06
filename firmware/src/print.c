// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "print.h"

void print_chr(char ch)
{
	*((volatile unsigned int*)OUTPORT) = ch;
}

void print_word(int word){
	*((volatile unsigned int*)OUTPORT) = word;
}

void print_str(const char *p)
{
	while (*p != 0)
		*((volatile unsigned int*)OUTPORT) = *(p++);
}

void print_hex(unsigned int val, int digits) {
	unsigned int index, max;
	int i; /* !! must be signed, because of the check 'i>=0' */
	char x;

	if(digits == 0)
		return;

	max = digits << 2;

	for (i = max-4; i >= 0; i -= 4) {
		index = val >> i;
		index = index & 0xF;
		x="0123456789ABCDEF"[index];
		*((volatile unsigned int*)OUTPORT) = x;
	}
}

int getDigit(int base, int number) {
	//print_str("number: ");
	//print_hex(number,8);
	//print_str("\n");
	//print_str("base: ");
	//print_hex(base,8);
	//print_str("\n");
	int digit = 0;
	for (int i = base;i <= number;i += base) ++digit;
	//print_str("digit: ");
	//print_hex(digit,1);
	//print_str("\n");
	return digit;
}

unsigned int base_lookup[] = {0,1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000};

void print_dec(unsigned int val) {
	char leading_0_flag = 0;
	for (int i = 10; i > 0; i--)
	{
		//print_str("i: ");
		//print_hex(i,8);
		//print_str("\n");
		int index = getDigit(base_lookup[i],val);
		if (index != 0 || leading_0_flag != 0)
		{
			leading_0_flag = 1;
			char x="0123456789"[index];
			*((volatile unsigned int*)OUTPORT) = x;
		}
		for (int j = 0; j < index; j++){
		    val -= base_lookup[i];
		}
	}
	return;
}