;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
;
;       This example will show/explain step by step how to configure the Timer/Counter1 and
;       generate different type of timer interrupts supported by the Timer/Counter1.
;       For this example to work accurately, setup the Fuse to 1Mb Frequency:
;                CKDIV8 = [X]
;                SUT_CKSEL = INTRCOSC_8MHZ_6CK_14CK_65MS
;

                .include        "stack.inc"             ; include the stack macros

                .dseg                                   ; data segment specification
                .org            SRAM_START              ; move to the start of the SRAM
counter:        .byte           1                       ; alloc 1 byte for the counter
seconds:        .byte           1                       ; alloc 1 byte for seconds
minutes:        .byte           1                       ; alloc 1 byte for minutes
                .cseg
                ; define the interrupt table
                .org    0               jmp     start
                .org    OVF1addr        jmp     OVF1vec

                .org    INT_VECTORS_SIZE
start:          ; program start and the interupt vector for RESET
                initStk                                 ; initialize the stack
                lds             r20, counter            ; set the counter to 0
                eor             r20, r20
                sts             counter, r20

                ; setup the timer/clock1 for overflow interrupt
                cli                                     ; disable int until everything is set

                lds             r20, PRR                ; load the Power Reduction Register
                andi            r20, ~( 1<< PRTIM1)     ; disable power reduction on timer/clock1
                sts             PRR, r20                ;   
    
;  CS02  CS01  CS00
;    0     0     0      No clock source (Timer/Counter stopped)
;    0     0     1      clkI/O/(No prescaling)
;    0     1     0      clkI/O/8 (From prescaler)
;    0     1     1      clkI/O/64 (From prescaler)
;    1     0     0      clkI/O/256 (From prescaler)
;    1     0     1      clkI/O/1024 (From prescaler)
;    1     1     0      External clock source on T0 pin. Clock on falling edge.
;    1     1     1      External clock source on T0 pin. Clock on rising edge.

                ldi             r20, 1 << CS01          ; select no prescaling
                sts             TCCR1B, r20             ; update the Timer/Counter1 Ctrl Register B

;
; Mode  WGM02   WGM01   WGM00   Timer/Counter        TOP        Update of       TOV Flag Set
;                               Mode of Operation               OCRx at         on
;
;   0     0       0       0          Normal          0xFFFF     Immediate       MAX
;   1     0       0       1    PWM, Phase Correct    0xFFFF     TOP             BOTTOM
;   2     0       1       0           CTC            OCRA       Immediate       MAX
;   3     0       1       1        Fast PWM          0xFFFF     BOTTOM          MAX
;   4     1       0       0        Reserved          –          -               –
;   5     1       0       1    PWM, Phase Correct    OCRA       TOP             BOTTOM
;   6     1       1       0        Reserved          –          –               –
;   7     1       1       1        Fast PWM          OCRA       BOTTOM         TOP
;
                eor             r20, r20                ; set mode 0
                sts             TCCR1A, r20             ; update the Timer/Counter1 Ctrl Register A

                ldi             r20, 1 << TOIE1         ; Timer/counter1 Overflow Interrupt Enable
                sts             TIMSK1, r20             ; update Timer/counter1 Int Mask Register 

                eor             r20, r20                ; select the IDLE mode for sleep command
                sts             SMCR, r20               ; update the Sleep Mode Control Register

                sei                                     ; enable interrupts in SREG


                sleep                                   ; sleep and wait for the interrupt to happen
end:            rjmp            end                     ; inifinite loop

OVF1vec:       ; timer/counter1 OVerFlow routine       call from IntVector     (3cycles)
                pushSREG                                ; save the SREG         (3cycles)
                push            r20                     ; save the r20

                lds             r20, counter            ; load the counter from memory
                .equ            ONE_SECOND_CYCLES = 15  ; 0x10 * 0x10000 *1Hz = 1MHz
                cpi             r20, ONE_SECOND_CYCLES  ; check if the counter reached 1 second
                breq            OVF1vec_E10             ; 1 second reached - jump 
                inc             r20                     ; not reached yet, increase the counter
                sts             counter, r20            ; and store it back
                rjmp            OVF1vec_exit            ; 
OVF1vec_E10:    ldi             r20, 0xD6               ; Timer/CouNTer1 adjustment with 
                sts             TCNT1L, r20             ; 1024*1024 - 1000000 + 22 cycles 
                ldi             r20, 0xBD               ; which were lost during interupt calls
                sts             TCNT1H, r20             ; 
                eor             r20,r20                 ; reset the counter
                sts             counter, r20            ; store it back
                lds             r20, seconds            ; load the seconds from memory
                cpi             r20, 59                 ; check if a minute is gone
                breq            OVF1vec_E20             ; 1 minute reached - jump
                inc             r20                     ; not reached yet, increase the counter
                sts             seconds, r20            ; store it back
                rjmp            OVF1vec_exit            ; 
OVF1vec_E20:    eor             r20,r20                 ; reset the seconds
                sts             seconds, r20            ; store it back
                lds             r20, minutes            ; load the minutes from memory
                inc             r20                     ; update the minutes
                sts             minutes, r20            ; store them back
                                
OVF1vec_exit:   pop             r20                     ; restore r20
                popSREG                                 ; restore the SREG      (3cycles)
                reti                                    ; return from interrupt (2cycles)
