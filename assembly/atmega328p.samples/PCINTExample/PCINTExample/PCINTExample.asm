;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
;
;       This example will show/explain step by step how to programm the ATMega328p to trigger
;       PinChangeInterrupts (PCINT). In this sample the PCINT0 will be shown. However external
;       interrupts can be triggerd on PCINT0..23. They are triggered even if the pins are configured
;       for output. This feature provides the way to generate software interrupts.
;
;       PCI0..2 (Pin Change Interrupt 0,1,2) are triggered if enabled PCINT0..7 toggles,
;       respectivelly on PCINT7..15 and PCINT16..23. Once the interrupt triggered the registers:
;       PCMSK0..2 will reflect which pin generated the interrupt. PCINT23 and PCINT0 are detected
;       async, which means that they can be used to wakeup the MCU from sleep modes other than IDLE.
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
;       Terminology:
;       PCICR  - Pin Change Interrupt Control Register
;       PCIE0  - (bit mask) - PCI0 Enable (same thing with 1 and 2 at the end for the PCI1..2) 
;       PCIFR  - Pin Change Interrupt Flag Register
;       PCIF0  - (bitmask) - PCI0 Flag (same thing with 1 and 2 at the end for the PCI1..2)
;                           The flag is cleared when the interrupt routine is executed. 
;                           Alternatively, the flag can be cleared by writing a logical one to it.
;       PCMSK0 - PCi0 MaSK register (PCMSK1, PCMSK2)
;       PCINT0 - (bitmask) PCI0..23, 8 for each PCMSK, bigendian
;
;
; atmega328p pinout
;                                      _______  _______
;                  Reset-PCINT14-PC6 -| 1            28|- PC5-PCINT13-ADC5-A5|A5-SCL  --->LED
;                 0--RXD-PCINT16-PD0 -| 2            27|- PC4-PCINT12-ADC4-A4|A5-SDA 
;                 1--TXD-PCINT17-PD1 -| 3            26|- PC3-PCINT11-ADC3-A3|A5
;                 2-INT0-PCINT18-PD2 -| 4            25|- PC2-PCINT10-ADC2-A2|A5
;        OC2B-PWM-3-INT1-PCINT19-PD3 -| 5            24|- PC1-PCINT9--ADC1-A1|A5
;             T0--4-XCK--PCINT20-PD4 -| 6            23|- PC0-PCINT8--ADC0-A0|A5
;                                VCC -| 7            22|- GND
;                                GND -| 8            21|- AREF
;             OSC1-XTAL1-PCINT6--PB6 -| 9            20|- VCC
;             OSC2-XTAL2-PCINT7--PB7 -|10            19|- PB5-PCINT5------13-----SCK
;        OC0B-PWM-5--T1--PCINT21-PD5 -|11            18|- PB4-PCINT4------12-----MISO
;        OC0A-PWM-6-AIN0-PCINT22-PD6 -|12            17|- PB3-PCINT3-OC2A-11-PWM-MOSI
;                 7-AIN1-PCINT23-PD7 -|13            16|- PB2-PCINT2-OC1B-10-PWM-SS
; --->       ICP1-8-CLK0-PCINT0--PB0 -|14            15|- PB1-PCINT1-OC1A--9-PWM
;                                     ------------------
;
;
                .include        "stack.inc"

                .dseg                                   ; data segment specification
                .org            SRAM_START              ; jump over the reserved SRAM section
counter:        .byte           1                       ; define a byte counter (0 ... 255)

                .cseg                                   ; code segment
                .org    0               jmp start       ; program start (Reset Interrupt Vector)
                .org    PCI0addr        jmp PCI0vec     ; PCI0 Interrupt Vector

start:                                                  ; programm begin
                cli                                     ; disable all the interrupts
                initStk                                 ; initialize the stack
                eor             r20, r20                ; initialiez the counter
                sts             counter, r20            ;
                ; setup the PCI0 for PCINT0/PB0 for output
                ; so we can simmulate the software interrupts
                ldi             r20, 1 << PB0           ; PCINT0/PB0 set for output
                out             DDRB, r20               ; update Data Direction Register for B bank
                in              r20, PORTB              ; load the current Port B register values
                eor             r20, r20                ; set PB0 on low
                out             PORTB, r20              ; update the Port B register
                ;
                ldi             r20, 1 << PCIE0         ; ebable the PCI0 interrupt
                sts             PCICR, r20              ; !is not in the out range; use sts
                ldi             r20, 1 << PCINT0        ; mask the Pin PB0
                sts             PCMSK0, r20             ; update the PCMSK0 (!Memory Mapped)
                sei                                     ; ready to receive interrupts
                ; testing 
                sbi             PINB, PINB0             ; toggle the PB0
                nop                                     ; not sure why some interrupts don't fire
                nop                                     ; as expected, with the 4 nops everything 
                nop                                     ; looks fine.
                nop                                     ; 12.1 Pin Change Interrupt Timing (page 70)
                sbi             PINB, PINB0
                nop
                nop
                nop
                nop
                sbi             PINB, PINB0
                nop
                nop
                nop
                nop
                sbi             PINB, PINB0
                nop
                nop
                nop
                nop
                ;
end:            rjmp            end                     ; infinite loop at the ned of the app


PCI0vec:        pushSREG
                push            r20
                lds             r20, counter
                inc             r20
                sts             counter, r20
                pop             r20
                popSREG  
                reti                            ; return from the PCI0 interrupt

