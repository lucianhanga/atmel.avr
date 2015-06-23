;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
;
;       This example will show/explain step by step how to programm the ATMega328p to trigger
;       external interrupts. In this sample the INT0 will be shown.
;       However external interrupts can be triggerd on INT0..1 and PCINT0..23, the interrupts are
;       generated even if the pins are configured as outputs.
;       
;       The interrupt INT0..1 can be triggered on the following conditions: falling edge, 
;       rising edge, low level as specified in External Interrupt Control Register A (EICRA)
;       (for detailed description: ATmega48PA/88PA/168PA/328P page 70)
;
;       I didn't figure out how to use the AtmelStudio Simulator to test this code, so I have to 
;       use my HW to test it. The fritzing project for testing this code you can find it in:
;       atmel.avr/fritzing/external.interrupt.example.fzz
;       Comment out all the lines with (temporary) - they were required for the HW testing
;
; atmega328p pinout
;                                      _______  _______
;                  Reset-PCINT14-PC6 -| 1            28|- PC5-PCINT13-ADC5-A5|A5-SCL  --->LED
;                 0--RXD-PCINT16-PD0 -| 2            27|- PC4-PCINT12-ADC4-A4|A5-SDA 
;                 1--TXD-PCINT17-PD1 -| 3            26|- PC3-PCINT11-ADC3-A3|A5
; ---->           2-INT0-PCINT18-PD2 -| 4            25|- PC2-PCINT10-ADC2-A2|A5
;        OC2B-PWM-3-INT1-PCINT19-PD3 -| 5            24|- PC1-PCINT9--ADC1-A1|A5
;             T0--4-XCK--PCINT20-PD4 -| 6            23|- PC0-PCINT8--ADC0-A0|A5
;                                VCC -| 7            22|- GND
;                                GND -| 8            21|- AREF
;             OSC1-XTAL1-PCINT6--PB6 -| 9            20|- VCC
;             OSC2-XTAL2-PCINT7--PB7 -|10            19|- PB5-PCINT5------13-----SCK
;        OC0B-PWM-5--T1--PCINT21-PD5 -|11            18|- PB4-PCINT4------12-----MISO
;        OC0A-PWM-6-AIN0-PCINT22-PD6 -|12            17|- PB3-PCINT3-OC2A-11-PWM-MOSI
;                 7-AIN1-PCINT23-PD7 -|13            16|- PB2-PCINT2-OC1B-10-PWM-SS
;            ICP1-8-CLK0-PCINT0--PB0 -|14            15|- PB1-PCINT1-OC1A--9-PWM
;                                     ------------------
;
;
                .include "stack.inc"
                
                .dseg                                   ; data segment specs
                .org            SRAM_START              ; move to the start of SRAM
counter:        .byte           1                       ; counter of the interrupts
                .cseg
                ; interupt table definition
                .org    0               jmp     start
                .org    INT0addr        jmp     INT0vec

                .org    INT_VECTORS_SIZE
start:          ; program start (and the interrupt vector for RESET)
                initStk                                 ; init the stack
                ; prepare the LED driving
                 sbi             DDRC, DDC5              ; setup PC5 (PortC) for output (temporary)
                 cbi             PORTC, PORTC5           ; low signal on pin PDC        (temporary)
                 sbi             DDRC, DDC4
                 cbi             PORTC, PORTC4
                ; setup the INT0 to fire on low level
                cli                                     ; disable the interrupts
; ISC01 ISC00
;   0    0      The low level of INT0 generate an interrupt req.
;   0    1      Any logical change on INT0 generates an interrupt req.
;   1    0      The falling edge of INT0 generates an interrupt req.
;   1    1      The rising edge of INT0 generates an interrupt req.
;
; IMPORTANT: EIMSK is in the I/O range (0x00 - 0x3F) should be addressed with out/in.
;                  To address them with lds/sts: 0x20 should be added to the value of the I/O reg.
;            EICRA is Memory Mapped and should be addressed with lds/sts
;
                 ldi             r20, 1 << ISC00         ; trigger ANY logic change 
                 sts             EICRA, r20              ; store the value in the EICRA 
                 in              r20, EIMSK              ; load the External Interrupt MaSK reg
                 ori             r20, 1 << INT0          ; enable INT0
                 out             EIMSK, r20              ; write back the EIMSK
                 cbi             DDRD, DDD2              ; setup pin PD2 for input in Port D
                 sbi             PORTD, PORTD2           ; enable pull-up on PD2
                 sei                                     ; ebable interrupts

inf_loop:       in              r20, PIND
                andi            r20, 1 << PIND2
                brne            inf_loop_E10
                sbi             PORTC, PORTC4
                rjmp            inf_loop
inf_loop_E10:   cbi             PORTC, PORTC4
                rjmp            inf_loop
end:            rjmp    end

INT0vec:        ; Extern Interrupt INT0 routine
                pushSREG                                ; save the SREG
                push            r20                     ; save registers
                
                lds             r20, counter            ; increment the counter
                inc             r20                     ;
                sts             counter, r20            ;
                sbi             PORTC, PORTC5           ; toggle the LED (temporary)
                
                pop             r20                     ; restore registers
                popSREG                                 ; restore the SREG
                reti                                    ; return from interrupt
