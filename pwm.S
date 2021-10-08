; Copyright (c) 2021 ozforester. All rights reserved.
; Use of this source code is goverened by a MIT license
; that can be found in the LICENSE file.

; simple pwm lab
; OC1A normal mode w/o prescaler
; atmega8 @4MHz loc. osc. HF:D9 LF:C3(23)
; buttons
; fast mode

#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>

#define btnD DDRD
#define btnP PORTD
#define btnI PIND
#define btnA PD2
#define btnB PD3
#define pwmD DDRB
#define pwmP PORTB
#define pwmA PB1

temp   = 16 ;
dlcntr = 17 ; delay
port   = 18 ; port state
dir    = 19 ; direction

.global TIMER0_OVF_vect
.global main

.section .text

main:
        rcall pwm_init
	rcall timer0_init
	rcall btn_init
	loop:
	rcall buttons
	rcall delay
	rjmp loop
ret

btn_init:
	cbi btnD, btnA	; as input
	sbi btnP, btnA	; pulled-up
        cbi btnD, btnB	; same with
        sbi btnP, btnB	; second
ret

pwm_init:
	ldi temp, ( 1<<COM1A1 | 1<<COM1A0 | 1<<WGM10 ) 	; clear on compare inv
        out TCCR1A, temp 			;
        ldi temp, ( 1<<WGM12 |  1<<CS10 )	; 1/8 prescaler fast mode
        out TCCR1B, temp        		;
	clr temp				; H=0
	out OCR1AH, temp			;
        ldi temp, 127                           ; L=100
	out OCR1AL, temp			;
        sbi pwmD, pwmA  			; output
ret

buttons: ; modulation
        cpi dir, 1
        breq wide
        cpi dir, 2
        breq narrow
        rjmp ex
        wide:
        in temp, OCR1AH
        in temp, OCR1AL
        inc temp
        inc temp
        inc temp
        inc temp
	inc temp
        out OCR1AL, temp
	clr temp
        out OCR1AH, temp
        rjmp ex
        narrow:
        in temp, OCR1AH
        in temp, OCR1AL
        dec temp
        dec temp
        dec temp
        dec temp
        dec temp
        out OCR1AL, temp
        clr temp
        out OCR1AH, temp
        ex:
	clr dir
ret

TIMER0_OVF_vect:
	clr dir
        in port, btnI
	andi port, 0b00001100
	cpi port, 0b00001000
	breq up
	cpi port, 0b00000100
	breq down
	reti
        up:
	ldi dir, 1
	reti
        down:
	ldi dir, 2
reti

timer0_init:
	ldi temp, (1<<CS00)
        ori temp, (1<<CS02)
        out TCCR0, temp
	ldi temp, (1<<TOIE0)
	out TIMSK, temp
	sei
ret

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
