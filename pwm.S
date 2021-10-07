; Copyright (c) 2021 ozforester. All rights reserved.
; Use of this source code is goverened by a MIT license
; that can be found in the LICENSE file.

; simple pwm lab
; OC1A normal mode w/o prescaler
; atmega8 @4MHz loc. osc. HF:D9 LF:C3(23)
; encoder prepared
; fast mode planned


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

temp   = 16 ;
dlcntr = 17 ; delay
port   = 18 ; port state
dir    = 19 ; direction

.section .text
.global INT0_vect
.global INT1_vect
.global main

main:			;
        rcall pwm_init  ;
	rcall enc_init	;
	loop:		;
	rcall encoder	;
	rjmp loop	;
ret			;

enc_init:
	cbi encD, encA	; as input
	sbi encP, encA	; pulled-up
        cbi encD, encB	; same with
        sbi encP, encB	; second
        ldi temp, 0b00001010 ; @falling
        out MCUCR, temp
        in temp, GICR
        ori temp, 0b11000000 ; enable both
        out GICR, temp
        sei
ret

pwm_init:
	; TCCR1A not tuch
	ldi temp, 1<<COM1A0 ;
        out TCCR1A, temp ; toggle
        ldi temp, 1     ;
	out TCCR1B, temp ; no prescaler
	; TIMSK not tuch
        sbi pwmD, pwmA  ; as output
ret

encoder: ; planned to change pwm
        cpi dir, 1
        breq cw
        cpi dir, 2
        breq ccw
        rjmp ex
        cw:
        ; pwm higher
        rjmp ex
        ccw:
        ; pwm_lower
        ex:
ret

INT0_vect:
        clr port
        out GIFR, port
        in port, PIND
	andi port, 12
	cpi port, 8
	breq cw0
	cpi port, 4
	breq ccw0
	reti
        cw0:
	ldi dir, 1
	reti
        ccw0:
	ldi dir, 2
	rcall delay
reti

INT1_vect:
        clr port
        out GIFR, port
        in port, PIND
        andi port, 12
        cpi port, 8
        breq cw1
        cpi port, 4
        breq ccw1
        reti
        cw1:
	ldi dir, 1
        reti
        ccw1:
	ldi dir, 2
        rcall delay
reti

delay: ; ~ 16 ms
        ldi dlcntr, 255
        dl1:
        push dlcntr
        ldi dlcntr, 255
        dl2:
        dec dlcntr
        brne dl2
        pop dlcntr
        dec dlcntr
        brne dl1
ret

.end
