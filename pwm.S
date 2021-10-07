; Copyright (c) 2021 ozforester. All rights reserved.
; Use of this source code is goverened by a MIT license
; that can be found in the LICENSE file.

; simple pwm lab
; OC1A normal mode w/o prescaler
; atmega8 @4MHz loc. osc. HF:D9 LF:C3(23)
; encoder
; fast mode

#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>

#define encD DDRD
#define encP PORTD
#define encI PIND
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
        rcall delay     ;
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
	ldi temp, ( 1<<COM1A1 | 1<<WGM10 ) 	; clear on compare non inv
        out TCCR1A, temp 			;
        ldi temp, ( 1<<WGM12 |  1<<CS10 )	; 1/8 prescaler fast mode
        out TCCR1B, temp        		;
	clr temp				; H=0
	out OCR1AH, temp			;
	ldi temp, 100				; L=100
	out OCR1AL, temp			;
        sbi pwmD, pwmA  			; output
ret

encoder: ; modulation
        cpi dir, 1
        breq cw
        cpi dir, 2
        breq ccw
        rjmp ex
        cw:
        ; wider
        in temp, OCR1AL
	andi temp, 1
        out OCR1AL, temp
        rjmp ex
        ccw:
        ; shorter
        in temp, OCR1AL
        subi temp, 1
        out OCR1AL, temp
        ex:
	clr dir
ret

INT0_vect:
	rcall delay
	clr port
        out GIFR, port
        in port, encI
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
reti

INT1_vect:
	rcall delay
        clr port
        out GIFR, port
        in port, encI
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
