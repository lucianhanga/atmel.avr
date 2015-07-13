;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
;
; This application is a simple AVR ATMega328p application which can be used to test if the IPS is 
; correctly connected to the MCU and if the programming was successfully completed.
; 
; The programm will just continuouslly blink the LED connected at PC5 (PIN28).
; For programm testing was used also the circuit presented in the folder:
; atmel.avr\assembly\atmega328p.programs\PersistenceOfVision
;
;   For this example to work accurately, setup the Fuse to 1Mb Frequency:
;       CKDIV8 = [X]
;       SUT_CKSEL = INTRCOSC_8MHZ_6CK_14CK_65MS
;
;
; atmega328p pinout
;                                       _______  _______
;                   Reset-PCINT14-PC6 -| 1            28|- PC5-PCINT13-ADC5-A5|A5-SCL  <--- LED
;                  0--RXD-PCINT16-PD0 -| 2            27|- PC4-PCINT12-ADC4-A4|A5-SDA 
;                  1--TXD-PCINT17-PD1 -| 3            26|- PC3-PCINT11-ADC3-A3|A5
;                  2-INT0-PCINT18-PD2 -| 4            25|- PC2-PCINT10-ADC2-A2|A5
;         OC2B-PWM-3-INT1-PCINT19-PD3 -| 5            24|- PC1-PCINT9--ADC1-A1|A5
;              T0--4-XCK--PCINT20-PD4 -| 6            23|- PC0-PCINT8--ADC0-A0|A5
;                                 VCC -| 7            22|- GND
;                                 GND -| 8            21|- AREF
;              OSC1-XTAL1-PCINT6--PB6 -| 9            20|- VCC
;              OSC2-XTAL2-PCINT7--PB7 -|10            19|- PB5-PCINT5------13-----SCK
;         OC0B-PWM-5--T1--PCINT21-PD5 -|11            18|- PB4-PCINT4------12-----MISO
;         OC0A-PWM-6-AIN0-PCINT22-PD6 -|12            17|- PB3-PCINT3-OC2A-11-PWM-MOSI
;                  7-AIN1-PCINT23-PD7 -|13            16|- PB2-PCINT2-OC1B-10-PWM-SS
;             ICP1-8-CLK0-PCINT0--PB0 -|14            15|- PB1-PCINT1-OC1A--9-PWM
;                                      ------------------
;
;
                .include        "stack.inc"


                .macro          delay_ms
                pushSREG
                push            r24
                push            r25
                push            r16
                ldi             r24, LOW(@0)
                ldi             r25, HIGH(@0)
                call            __delay_ms
                pop             r16
                pop             r25
                pop             r24
                popSREG
                .endmacro

                .cseg
                .org    0       rjmp    start

                .org    INT_VECTORS_SIZE
start:          initStk                                 ; initialize the stack for proc calls
                ldi             r20, 1 << DDC5          ; setup the C5 PIN for output
                out             DDRC, r20

repeat_toggle:  sbi             PINC, PINC5             ; toggle the value of the PIN C5
                delay_ms        1000
                rjmp            repeat_toggle

end:            rjmp            end

;
;
;
__delay_ms:     ; delay milliseconds routine
                ldi             r16,200                 ; 7*142 cycles -1       = 993 cycles
__delay_ms_E20: push            r30                     ;   2 cycles
                pop             r30                     ;   2 cycles
                dec             r16                     ;   1 cycle
                brne            __delay_ms_E20          ;   2 cycle (1cycle)
                push            r30                     ;   2 cycles
                pop             r30                     ;   2 cycles            = 993+4=997 cycles
                sbiw            r25:r24, 1              ;   2 cycles
                brne            __delay_ms              ;   2 cycles (1cycle)
__delay_ms_end: ret                                     ;   4 cycles

