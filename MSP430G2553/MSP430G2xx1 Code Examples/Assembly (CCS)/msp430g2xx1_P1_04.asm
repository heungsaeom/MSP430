;*******************************************************************************
;   MSP430G2xx1 Demo - P1 Interrupt from LPM4 with Internal Pull-up
;
;   Description: A hi/low transition on P1.4 will trigger P1_ISR which,
;   toggles P1.0. Normal mode is LPM4 ~ 0.1uA.
;   Internal pullup enabled on P1.4.
;   ACLK = n/a, MCLK = SMCLK = default DCO
;
;                MSP430G2xx1
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;      /|\   |      R          |
;       --o--| P1.4-o      P1.0|-->LED
;      \|/
;
;   D. Dang
;   Texas Instruments Inc.
;   October 2010
;   Built with Code Composer Essentials Version: 4.2.0
;*******************************************************************************
 .cdecls C,LIST,  "msp430g2231.h"

;------------------------------------------------------------------------------
            .text                           ; Progam Start
;------------------------------------------------------------------------------
RESET       mov.w   #0280h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP1     mov.b   #001h,&P1DIR            ; P1.0 output, else input
            mov.b   #010h,&P1OUT            ; P1.4 set, else reset
            bis.b   #010h,&P1REN            ; P1.4 pullup
            bis.b   #010h,&P1IE             ; P1.4 Interrupt enabled
            bis.b   #010h,&P1IES            ; P1.4 hi/low edge
            bic.b   #010h,&P1IFG            ; P1.4 IFG Cleared
                                            ;
Mainloop    bis.w   #LPM4+GIE,SR            ; LPM4, enable interrupts
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
P1_ISR;     Toggle P1.0 Output
;-------------------------------------------------------------------------------
            xor.b   #001h,&P1OUT            ; P1.0 = toggle
            bic.b   #010h,&P1IFG            ; P1.4 IFG Cleared
            reti                            ; Return from ISR
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int02"                ; P1.x Vector
            .short  P1_ISR                  ;
            .end