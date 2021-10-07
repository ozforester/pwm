; Copyright (c) 2021 ozforester. All rights reserved.
; Use of this source code is goverened by a MIT license
; that can be found in the LICENSE file.

; simple pwm lab
; atmega8 @4MHz local osc. HF: LF:

#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>

#define encA PD2
#define encB PD3

temp     = 16			;
counter  = 17			;

.section .text

.global main
main:				;
	loop: rjmp loop		;
ret				;
