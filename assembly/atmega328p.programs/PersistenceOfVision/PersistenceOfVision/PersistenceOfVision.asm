;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
;
; Persistence of Vision
;
; The application will print text using 2 rows of leds and the persistence of vision property
; (an image remains on the retina for 40ms and if the leds are moved fast enough they can be 
; percived as distributed in space and form charactes and texts).
;
;
;
; atmega328p pinout
;                                         _______  _______
;                     Reset-PCINT14-PC6 -| 1            28|- PC5-PCINT13-ADC5-A5|A5-SCL
;LED10<---           0--RXD-PCINT16-PD0 -| 2            27|- PC4-PCINT12-ADC4-A4|A5-SDA 
;LED10<--            1--TXD-PCINT17-PD1 -| 3            26|- PC3-PCINT11-ADC3-A3|A5
;LED10<--            2-INT0-PCINT18-PD2 -| 4            25|- PC2-PCINT10-ADC2-A2|A5
;LED10<--   OC2B-PWM-3-INT1-PCINT19-PD3 -| 5            24|- PC1-PCINT9--ADC1-A1|A5
;                T0--4-XCK--PCINT20-PD4 -| 6            23|- PC0-PCINT8--ADC0-A0|A5
;                                   VCC -| 7            22|- GND
;                                   GND -| 8            21|- AREF
;LED06<---       OSC1-XTAL1-PCINT6--PB6 -| 9            20|- VCC
;LED07<---       OSC2-XTAL2-PCINT7--PB7 -|10            19|- PB5-PCINT5------13-----SCK    --->LED05
;LED10<--   OC0B-PWM-5--T1--PCINT21-PD5 -|11            18|- PB4-PCINT4------12-----MISO   --->LED04
;LED10<--   OC0A-PWM-6-AIN0-PCINT22-PD6 -|12            17|- PB3-PCINT3-OC2A-11-PWM-MOSI   --->LED03
;LED10<--            7-AIN1-PCINT23-PD7 -|13            16|- PB2-PCINT2-OC1B-10-PWM-SS     --->LED02
;LED00<--       ICP1-8-CLK0-PCINT0--PB0 -|14            15|- PB1-PCINT1-OC1A--9-PWM        --->LED01
;                                        ------------------

                .include        "stack.inc"
                .include        "util.inc"


                .macro          delay_ms
                pushSREG
                push            r24
                push            r25
                push            r16
                ldi             r20, LOW(@0)
                ldi             r21, HIGH(@0)
                call            __delay_ms
                pop             r16
                pop             r25
                pop             r24
                popSREG
                .endmacro


                .dseg                                   ; data segment definition
                .org            SRAM_START
                .cseg                                   ; code segment definitions
                ; interrupt vectors
                .org    0               jmp start
                ; end of interrupt vectors
                .org            INT_VECTORS_SIZE
                ; defintions which are going to be used during the program
                .equ            LED_ROW_0 = PORTB
                .equ            LED_ROW_1 = PORTD
start:          ; program start (the vector for the RESET interrupt)
                ldi             r20, 0xFF               ; 
                out             DDRB, r20               ; configure the port B for output
                out             DDRD, r20               ; configure the port D for output
infinite_loop:                                          ; infinite loop which displays the text
                ldZcseg         line0                   ;  initialize Z pointer with text1
text_loop:      lpm             r20, Z+                 ;  load a character and inc the pointer Z
                breq            text_loop_end           ;  0x00 encounter, end of the text loop
                out             LED_ROW_0, r20          ;  ligth them up - row0
                delay_ms        50
                
                ; delay 20ms
                ; while r20 !=0 
text_loop_end:  rjmp            infinite_loop           ; close the infinite loop 
end:            rjmp            end

                ; data definition in the .cseg
line0:          .db             "Daniel Hanga", 0x00, 0x00
line1:          .db             "ist die Beste", 0x00


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