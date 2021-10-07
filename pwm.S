; Copyright (c) 2021 ozforester. All rights reserved.
; Use of this source code is goverened by a MIT license
; that can be found in the LICENSE file.

; simple pwm lab
; OC1A normal mode w/o prescaler
; atmega8 @4MHz loc. osc. HF:D9 LF:C3(23)
; sram instructions tested with regs

#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>

#define encD DDRD
#define encP PORTD
#define encA PD2
#define encB PD3
#define pwmD DDRB
#define pwmP PORTB
#define pwmA PB1

temp     = 16	;
counter  = 17	;

.section .text

.global main
main:			;
        rcall pwm_init  ;
	rcall enc_init	;
	loop: rjmp loop	;
ret			;


enc_init:
	cbi encD, encA	; as input
	sbi encP, encA	; pulled-up
        cbi encD, encB	; same with
        sbi encP, encB	; second
ret

pwm_init:
	; TCCR1A not tuch
	; TCCR1B bit CS1 set (start w/o prescaler)
	ldi temp, 1<<COM1A0 ;
        out TCCR1A, temp ; toggle
        ldi temp, 1     ;
	out TCCR1B, temp ; no prescaler
	; TIMSK not tuch
        sbi pwmD, pwmA  ; as output
ret

