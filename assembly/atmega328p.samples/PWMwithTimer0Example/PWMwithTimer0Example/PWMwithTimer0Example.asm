;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
;
;   The example will program the Counter/Timer0 to generate PWM (Pulse Width Modulator)
;   with a configurable PWM Periods. 
;   PWM defintions: 
;       Duty Cycle = 100% x Pulse Width/Period
;       Where:
;                Duty Cycle in (%)
;       Pulse Width = Time the signal is in the ON or high state (sec) 
;       Period = Time of one cycle (sec)
;     
;       ON    ______          ________          _________
;                   |        | PulseW.|        |
;                   |        |<------>|        |
;       OFF         |________|        |________|
;                             <--------------->
;                                   Period
;
;   The most important registers to remember for this programm:
;       PRR - Power Reduction Register (anble/disable the timer) - PIRTIM0 bit should be reseted
;       TIMSK0 - Timer/counter0 interrupt MaSK register
;       TCCR0A - Timer/Counter0 Control Register A
;       TCCR0B - Timer/Counter0 Control Register B
;       TCNT0  - Timer/counter0 CouNTer register
;       OCR0A  - Output Compare timer/counter0 Register A
;       OCR0B  - Output Compare timer/counter0 Register B
;
;   For this example to work accurately, setup the Fuse to 1Mb Frequency:
;       CKDIV8 = [X]
;       SUT_CKSEL = INTRCOSC_8MHZ_6CK_14CK_65MS
;
;; atmega328p pinout
;                                       _______  _______
;                   Reset-PCINT14-PC6 -| 1            28|- PC5-PCINT13-ADC5-A5|A5-SCL 
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
; LED<--- OC0A-PWM-6-AIN0-PCINT22-PD6 -|12            17|- PB3-PCINT3-OC2A-11-PWM-MOSI
;                  7-AIN1-PCINT23-PD7 -|13            16|- PB2-PCINT2-OC1B-10-PWM-SS
;             ICP1-8-CLK0-PCINT0--PB0 -|14            15|- PB1-PCINT1-OC1A--9-PWM
;                                      ------------------
;
; IMPORTANT:
;    Timer/Counter0  I/O registers: OCR0B, OCR0A, TCNT0, TCCR0B, TCCR0A are in the in/out range
;    Timer/Counter1,2 are in the Extended I/O space and have to be addressed using lds/sts
;    NB !always check where are your I/O Registers!
;

                .include        "stack.inc"
                ; define the interrupt table
                .org    0               jmp     start   ; RESET interrupt routine
                .org    OVF0addr        jmp     OVF0vec ; OVerFlow Counter/Timer0 interrupt routine
                .org    OC0Aaddr        jmp     OC0Avec ; Output Compare A Counter/Timer0 interrupt

                .org            INT_VECTORS_SIZE        ; end of the interrupt vectors table
start:          ; program start and the RESET interrupt vector 
                cli
                initStk                                 ; initialize stack for calls and iterrupts
                sbi             DDRD, DDD6              ; enavle PD6 for output
                ; enable the Timer/Counter0
                lds             r20, PRR                ; Power Reduction Register (!MemoryMapped!)
                andi            r20, ~(1 << PRTIM0)     ; enable the Timer/Counter0
                sts             PRR, r20                ;
                ; 
                ; clock 
                ; CS02  CS01  CS00
                ;   0     0     0      No clock source (Timer/Counter stopped)
                ;   0     0     1      clkI/O/(No prescaling)
                ;   0     1     0      clkI/O/8 (From prescaler)
                ;   0     1     1      clkI/O/64 (From prescaler)
                ;   1     0     0      clkI/O/256 (From prescaler)
                ;   1     0     1      clkI/O/1024 (From prescaler)
                ;   1     1     0      External clock source on T0 pin. Clock on falling edge.
                ;   1     1     1      External clock source on T0 pin. Clock on rising edge.
                ; 
                ; mode
                ; Mode  WGM02 WGM01 WGM00  Name               TOP     Update OCRx    TOV
                ;   
                ;  0      0     0     0    Normal             0xFF    immediate      MAX
                ;  1      0     0     1    PWM,Phase Correct  0xFF    TOP            BOTTOM 
                ;  2      0     1     0    CTC                OCRA    imediate       MAX
                ;  3      0     1     1    Fast PWM           0xFF    BOTTOM         MAX
                ;  4      1     0     0    -------            ----    -------        ----
                ;  5      1     0     1    PWM,Phase Correct  OCRA    TOP            BOTTOM
                ;  6      1     1     0    -------            ----    -------        ----
                ;  7      1     1     1    Fast PWM           OCRA    BOTTOM         TOP
                ; 
                ;  MAX = 0xFF, BOTTOM = 0xFF
                ; 
                ; OC0A - Output Compare Pin A for Timer/Counter 0 (for WGM 0&2)
                ; COM0A1 COM0A0  Description
                ;
                ;   0      0     Normal port operation, OC0A disconected
                ;   0      1     Toggle OC0A on Compare match
                ;   1      0     Clear OC0A on Compare match
                ;   1      1     Set OC0A on Compare match
                ; 
                ; OC0A - Output Compare Pin A for Timer/Counter 0 (for WGM 3&7)
                ; COM0A1 COM0A0  Description
                ;
                ;   0      0     Normal port operation, OC0A disconnected
                ;   0      1     Toggle OC0A on Compare Match. (WGM02 <- 1)
                ;   1      0     Clear OC0A on Compare Match, set OC0A at BOTTOM (non-inverting)
                ;   1      1     Set OC0A on Compare Match, clear OC0A at BOTTOM (inverting mode)
                ; 
                ;  CS02:0    <---  1 0 1 (clkI/O  1024 prescaling)
                ;  WGM02:0   <---  0 1 1 (Fast PWM mode)
                ;  COM0A1:0  <---  1 0   (clear OC0A on compare match, set at BOTTOM)
                ;
                ldi             r20, 1 << CS02 | 1 << CS00
                out             TCCR0B, r20                         
                ldi             r20, 1 << COM0A1 | 1 << WGM01 | 1 << WGM00 
                out             TCCR0A, r20                
                ldi             r20, 0x80               ; puls width <- 0x80 ( duty cycle = 50%)
                out             OCR0A, r20              ;
                in              r21, OCR0A 
                ; enable the interrupt(s)
                ldi             r20, 1 << TOIE0 | 1 << OCIE0A 
                sts             TIMSK0, r20             ;
                sei                                     ; enable interrupt
end:            rjmp            end                     ; infinite loop at the end of the programm


OVF0vec:        ; interrupt vector for the OVF0 interrupt
                reti

OC0Avec:        ; interrupt vector for the OC0A interrupt
                reti

