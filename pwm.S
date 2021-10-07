; Copyright (c) 2021 ozforester. All rights reserved.
; Use of this source code is goverened by a MIT license
; that can be found in the LICENSE file.
#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#include <avr/io.h>
.global main
temp     = 16			; common reg
counter  = 17			;
yh       = 28			;
yl       = 29			;
zh       = 30			;
zl       = 31			;
.section .bss
b_reg: .byte 0,0,0,0,0,0,0,0	;
b_dat: .byte 0,0,0,0,0,0,0,0	;
si_w_reg: .byte 0               ; reg number to write
si_w_dat: .byte 0               ; reg data to write
.section .text
main:				;
        ldi counter, 8          ;
	clr zh			;
	ldi zl, b_reg		;
        clr yh                  ;
        ldi yl, b_dat          ;
	m0:			;
        ld temp, Y+             ; reg number
        sts si_w_dat, temp	;
        ld temp, Z+		; reg number
        sts si_w_reg, temp	;
        ;rcall si_write_reg	; write next si register
        dec counter             ;
        brne m0                 ;
	loop: rjmp loop		;
ret				;
