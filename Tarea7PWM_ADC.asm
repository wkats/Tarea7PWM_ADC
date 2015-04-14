;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------


CONFIG			mov.b	#0FFh,&P2DIR	;P2 COMO SALIDA
				mov.b	#00h,&P2OUT		;SACAMOS UN 0 POR P2
				mov.b	#05h,R4			;5 muestras
				mov.b	#0200h,R5		;Apuntador
				bis.b	#040h,&P1DIR	;P1.6 COMO SALIDA
				bis.b	#040h,&P1SEL	;P1SEL.6 COMO 1

				mov.w	#TASSEL_2+ID_0+MC_1,&TACTL	;RELOG SMCLK,DIVISOR=1,MODE=UP
				bis.w	#OUTMOD_7,&TACCTL1
				mov.w	#03E8h,&TACCR0	;SE CARGA TACCR0 CON 1,000
				mov.w	#0190h,&TACCR1

				mov.w	#ADC10ON+ADC10IE,&ADC10CTL0;CONVERSOR ENCENDIDO CON INTERRUPCIÓN
				mov.w	#INCH_3+ADC10SSEL_2,&ADC10CTL1;IN-CHANNEL=3,SOURCE:MCLK
				mov.b	#08h,&ADC10AE0		;CANAL3 SE HABILITA COMO ENTRADA ANALÓGICA

				bis.w	#GIE,SR			;SE HABILITAN LAS INTERRUPCIONES GENERALES

PRINCIPAL
CICLO			bis.w	#ENC+ADC10SC,&ADC10CTL0
				mov.b	0(R5),&P2OUT
				incd		R5
				dec		R4
				jnz		sigue
				mov.w	#05h,R4
				mov.w	#0200h,R5
sigue			nop
				jmp		CICLO


intADC			mov.w	&ADC10MEM,0(R5)
				mov.w 	&ADC10MEM,&TACCR1
				reti


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
			.sect	".int05"
			.short	intADC
