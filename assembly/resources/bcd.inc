
#ifdef IMPL_BINTOBCD8S

                ;
                ; proc BinToBcd8S - (Binary to BCD  8 bit signed)
                ;       descr:  encode a 8 bit signed value to BCD format 
                ;               in a zero terminated string (stringZ)
                ;       params: r16 - the value
                ;               x   - the buffer pointer
                ;       ret:    r21 - the number of bytes written to the buffer
                ;       alters: r21
                ;
BinToBcd8S:     push            r16             ; save the altered registers
                push            r17
                push            r18
                push            r19
                push            r20
                push	        r26
                push	        r27
                in              r18, SREG       ; --
                push            r18             ; --
                clr             r21             ; r21 <-- 0 - set to zero the size of the str.
                .def            sign = r20
                clr             sign            ; sign <-- 0
                ; add the string terminator (0x00)
                ldi             r17, 0x00
                push	        r17
                inc             r21
                ; check if the number is negative
                sbrs            r16, 7          ; skip if bit 7 in r16 is set
                rjmp            BinToBcd8S_E10  ; 
                ; it's negative - compute the two's complement
                com             r16             ; 2's complement
                inc             r16             ; --
                ldi             sign, 0x01      ; set the sign flag accordingly
BinToBcd8S_E10: ; (now) it's positive - go on with conversion
                ldi             r17,10          ; divide by 10
BinToBcd8S_E15: call            Div8U           ; Div8U  (r16, r17) --> (r18, r19)
                ADI             r19, '0'        ; decimal digit of r19 in ASCII
                push            r19             ; push it on the stack for later extraction
                inc             r21             ; increment the size of the string
                mov             r16, r18        ; put in the r16 the quotient for the next round
                cpi             r18, 0          ; check if are still digits 
                brne            BinToBcd8S_E15
                ; check if the sign has to be added
                cpi             sign, 0
                breq            BinToBcd8S_E20
                ; it's negative add the sign
                ldi             r17, '-'
                push	        r17
BinToBcd8S_E20: ; the number was transformed and it's on the stack
                ; extract the number and store it in the buffer
                pop             r17
                st              x+, r17
                cpi             r17, 0x00
                brne	        BinToBcd8S_E20
                ; done 
BinToBcd8S_end: pop             r18             ; restore the altered registers
                out             SREG, r18
                pop             r27
                pop             r26				        
                pop             r20
                pop             r19
                pop             r18
                pop             r17
                pop             r16
                .undef          sign
                ret
#endif ; IMPL_BINTOBCD8S


#ifdef  IMPL_BINTOBCD16S
                ;
                ; proc BinToBcd16S - (Binary to BCD  16 bit signed)
                ;       descr:  encode a 16 bit signed value to BCD format 
                ;               in a zero terminated string (stringZ)
                ;       params: r17 - the value HSB
                ;               r16 - the value LSB
                ;               x   - the buffer pointer
                ;       ret:    r25 - the number of bytes written to the buffer
                ;       alters: r25
                ;
BinToBcd16S:    push            r16                     ; save the altered registers
                push            r17
                push            r18
                push            r19
                push            r20
                push            r21
                push            r22
                push            r23
                push            r24
                push            r25
                push	        r26
                push	        r27
                in              r18, SREG               ; --
                push            r18                     ; --
                clr             r25                     ; r25 <-- 0 - set to zero the size of the str.
                .def            sign = r24
                clr             sign                    ; sign <-- 0
                ; add the string terminator (0x00)
                ldi             r20, 0x00
                push	        r20
                inc             r25
                ; check if the number is negative
                sbrs            r17, 7                  ; skip if bit 7 in r16 is set
                rjmp            BinToBcd16S_E10         ; 
                ; it's negative - compute the two's complement
                com             r17                     ; 2's complement
                com             r16                     ; 2's complement
                ldi             r21, 0x01      
                add             r16, r21                ; --
                adc             r17, r20                ; --
                ldi             sign, 0x01              ; set the sign flag accordingly
BinToBcd16S_E10:; (now) it's positive - go on with conversion
                clr             r19                     ; prepare the r19:r18 <-- 10
                ldi             r18,10                  ; divide by 10
BinToBcd16S_E15:call            Div16U                  ; Div8U  (r17:r16, r19:r18) --> (r21:r20, r23:r22)
                ADI             r22, '0'                ; decimal digit of r19 in ASCII
                push            r22                     ; push it on the stack for later extraction
                inc             r25                     ; increment the size of the string
                mov             r16, r20                ; put in the r16 the quotient for the next round
                mov             r17, r21                ; --
                cpi             r20, 0                  ; check if are still digits
                brne            BinToBcd16S_E15
                cpi             r21, 0
                brne            BinToBcd16S_E15
                ; check if the sign has to be added
                cpi             sign, 0
                breq            BinToBcd16S_E20
                ; it's negative add the sign
                ldi             r17, '-'
                push	        r17
BinToBcd16S_E20:; the number was transformed and it's on the stack
                ; extract the number and store it in the buffer
                pop             r17
                st              x+, r17
                cpi             r17, 0x00
                brne	        BinToBcd16S_E20
                ; done 
BinToBcd16S_end:pop             r18             ; restore the altered registers
                out             SREG, r18
                pop             r27
                pop             r26
                pop             r25
                pop             r24
                pop             r23
                pop             r22
                pop             r21
                pop             r20
                pop             r19
                pop             r18
                pop             r17
                pop             r16
                .undef          sign
                ret
#endif ; IMPL_BINTOBCD16S



#ifdef IMPL_BINTOBCD8U
                ;
                ; proc BinToBcd8U - (Binary to BCD  8 bit unsigned)
                ;       descr:  encode a 8 bit unsigned value to BCD format 
                ;               in a zero terminated string (stringZ)
                ;       params: r16 - the value
                ;               x   - the buffer pointer
                ;       ret:    r21 - the number of bytes written to the buffer
                ;       alters: r21
                ;
BinToBcd8U:     push            r16                     ; save the altered registers
                push            r17
                push            r18
                push            r19
                push	        r26                     ; save the x register
                push	        r27
                in              r18, SREG               ; --
                push            r18                     ; --
                clr             r21                     ; r21 <-- 0 - set to zero the size of the str.
                ; add the string terminator (0x00)
                ldi             r17, 0x00
                push	        r17
                inc             r21
                ldi             r17,10                  ; divide by 10
BinToBcd8U_E15: call            Div8U                   ; Div8U  (r16, r17) --> (r18, r19)
                ADI             r19, '0'                ; decimal digit of r19 in ASCII
                push            r19                     ; push it on the stack for later extraction
                inc             r21                     ; increment the size of the string
                mov             r16, r18                ; put in the r16 the quotient for the next round
                cpi             r18, 0                  ; check if are still digits 
                brne            BinToBcd8U_E15
BinToBcd8U_E20: ; the number was transformed and it's on the stack
                ; extract the number and store it in the buffer
                pop             r17
                st              x+, r17
                cpi             r17, 0x00
                brne            BinToBcd8U_E20
                ; done 
BinToBcd8U_end: pop             r18                     ; restore the altered registers
                out             SREG, r18
                pop             r27                     ; restore the x register
                pop             r26                     ; --        
                pop             r19
                pop             r18
                pop             r17
                pop             r16
                ret
#endif ; IMPL_BINTOBCD8U


#if  defined (IMPL_BINTOBCH8) || defined (IMPL_BINTOBCH16) || defined (IMPL_BINTOBCH32)
                ; proc BinToHex - Binary value to Hex ASCII digit
                ;       descr:  encode the 4 LSB and 4 MSB of r16 to
				;				Ascii Hex value into r18:r17
                ;       params: r16 - the value
                ;       ret:    r17, r18 - the LSB hex digit and MSB hex digit
                ;       alters: r17, r18
                ;
BinToHex:       mov             r17, r16
                andi            r17, 0b00001111
                cpi             r17, 9                  ; check if the value is bigger then 9
                brge            BinToHex_E10
                ; the value is not bigger than 9 so treat it as Decimal value
                ADI             r17, '0'
                rjmp            BinToHex_E20
BinToHex_E10:   ADI             r17, ('A' - 10)         ; is a upper hex digit 
BinToHex_E20:   mov             r18, r16
                lsr             r18
                lsr             r18
                lsr             r18
                lsr             r18
                cpi             r18, 9                  ; check if the value is bigger then 9
                brge            BinToHex_E30
                ; the value is not bigger than 9 so treat it as Decimal value
                ADI             r18, '0'
                rjmp            BinToHex_E40
BinToHex_E30:   ADI             r18, ('A' - 10)		; is a upper hex digit 
BinToHex_E40:
BinToHex_end:   ret
#endif

#ifdef IMPL_BINTOBCH8
                ;
                ; proc BinToBch8 - (Binary to Binary Codeed Hex 8 bit unsigned)
                ;       descr:  encode a 8 bit unsigned value to BCD Hex format 
                ;               in a zero terminated string (stringZ)
                ;       params: r16 - the value
                ;               x   - the buffer pointer
                ;       ret:    r21 - the number of bytes written to the buffer
                ;       alters: r21
                ;
BinToBch8:      push            r17                     ; save the altered registers
                push	        r18
                push	        r26                     ; 
                push	        r27                     ;
                in              r17, SREG               ;
                push            r17                     ;
BinToBch8_start:
                ldi             r21,3                   ; r21 <-- 3 (the return value)
                call	        BinToHex                ; transform the value from r16 to r17:r18
                st		x+, r18	                ; store the high hex digit
                st		x+, r17	                ; store the low hex digit
                clr		r17	                ;
                st		x, r17	                ; store the string terminator
BinToBch8_end:  pop             r17                     ; restore the altered registers
                out             SREG, r17               ;
                pop             r27                     ; 
                pop             r26                     ;
                pop             r18                     ; 
                pop             r17                     ;
                ret

#endif ; IMPL_BINTOBCH8

#ifdef IMPL_BINTOBCH16
                ;
                ; proc BinToBch16 - (Binary to Binary Codeed Hex 16 bit)
                ;       descr:  encode a 16 bit value to BCD Hex format 
                ;               in a zero terminated string (stringZ)
                ;       params: r17 - the value 
                ;               r16 - the value
                ;               x   - the buffer pointer
                ;       ret:    r21 - the number of bytes written to the buffer
                ;       alters: r21
                ;
BinToBch16:     push            r16
                push            r17                     ; save the altered registers
                push	        r18                     
                push	        r26                     ; 
                push	        r27                     ;
                in              r18, SREG               ;
                push            r18                     ;
BinToBch16_start:
                ldi             r21,5                   ; r21 <-- 5 (the return value)
                push            r16                     ; save the LSByte for later
                mov             r16, r17                ; put the MSByte to r16 (needed as paramter for BinToHex)
                call            BinToHex                ; transform the value from r16 (MSByte) to r17:r18
                st              x+, r18	                ; store the high hex digit
                st              x+, r17	                ; store the low hex digit
                pop             r16                     ; restore the LSByte from stack
                call            BinToHex                ; transform the value from r16 (LSByte) to r17:r18
                st              x+, r18	                ; store the high hex digit
                st              x+, r17	                ; store the low hex digit
                clr             r17                     ;
                st              x, r17                  ; store the string terminator
BinToBch16_end: pop             r18                     ; restore the altered registers
                out             SREG, r18               ;
                pop             r27                     ; 
                pop             r26                     ;
                pop             r18                     ; 
                pop             r17                     ;
                pop             r16                     ;
                ret

#endif ; IMPL_BINTOBCH16


#ifdef IMPL_BINTOBCH32
                ;
                ; proc BinToBch32 - (Binary to Binary Codeed Hex 32 bit)
                ;       descr:  encode a 32 bit value to BCD Hex format 
                ;               in a zero terminated string (stringZ)
                ;       params: r19 - the value (byte 3) MSB 
                ;               r18 - the value (byte 2)
                ;               r17 - the value (byte 1)
                ;               r16 - the value (byte 0) LSB
                ;               x   - the buffer pointer
                ;       ret:    r21 - the number of bytes written to the buffer
                ;       alters: r21
                ;
BinToBch32:     push            r16                     ; save the altered registers
                push            r17                     ; 
                push	        r18                     ;
                push            r19                     ;
                push            r20                     ; for internal work
                push	        r26                     ; 
                push	        r27                     ;
                in              r20, SREG               ;
                push            r20                     ;
BinToBch32_start:
                ldi             r21,9                   ; r21 <-- 9 (the return value)
                push            r16                     ; save the byte 0 for later use
                push            r17                     ; save the byte 1 for later use
                push            r18                     ; save the byte 2 for later use
                mov             r16, r19                ; put the MSByte to r16 (needed as paramter for BinToHex)
                call            BinToHex                ; transform the value from r16 (MSByte) to r17:r18
                st              x+, r18	                ; store the high hex digit
                st              x+, r17	                ; store the low hex digit
                pop             r16                     ; restore the byte 2
                call            BinToHex                ; transform the value from r16 (LSByte) to r17:r18
                st              x+, r18	                ; store the high hex digit
                st              x+, r17	                ; store the low hex digit
                pop             r16                     ; restore the byte 2
                call            BinToHex                ; transform the value from r16 (LSByte) to r17:r18
                st              x+, r18	                ; store the high hex digit
                st              x+, r17	                ; store the low hex digit
                pop             r16                     ; restore the byte 2
                call            BinToHex                ; transform the value from r16 (LSByte) to r17:r18
                st              x+, r18	                ; store the high hex digit
                st              x+, r17	                ; store the low hex digit
                clr             r17                     ;
                st              x, r17                  ; store the string terminator
BinToBch32_end: pop             r20                     ; restore the altered registers
                out             SREG, r20               ;
                pop             r27                     ; 
                pop             r26                     ;
                pop             r20                     ; 
                pop             r19                     ; 
                pop             r18                     ; 
                pop             r17                     ;
                pop             r16                     ;
                ret

#endif ; IMPL_BINTOBCH32

#ifdef IMPL_BINTOBCB8
                ;
                ; proc BinToBcb8 - (Binary to Binary Codeed Binary 8 bit)
                ;       descr:  encode a 8 bit unsigned value to BCD binary format 
                ;               in a zero terminated string (stringZ)
                ;       params: r16 - the value
                ;               x   - the buffer pointer
                ;       ret:    r21 - the number of bytes written to the buffer
                ;       alters: r21
                ;
BinToBcb8:      push            r16                     ; save the altered registers
                push	        r17                     ; 
                push	        r18                     ; 
                push	        r26                     ; 
                push	        r27                     ;
                in              r17, SREG               ;
                push            r17                     ;
BinToBcb8_start:
                ldi             r21,8                   ; r21 <-- 8 the number of bits
                ldi             r17, 0x00               ; store the string termination
                push            r17                     ; --
                ldi             r17,'0'
                ldi             r18,'1'
BinToBcb8_E10:  lsr             r16                     ; get in carry flag the LSBit from r16
                brcc            BinToBcb8_E20
                push            r18                     ; the bit is 1 so push '1'
                rjmp            BinToBcb8_E30
BinToBcb8_E20:  push            r17                     ; the bit is 0 so push '0'
BinToBcb8_E30:  dec             r21
                brne            BinToBcb8_E10           ; check if all the bits were explored
BinToBcb8_E40:  ; the number was encoded, now remove it from the stack and put it into the buffer
                pop             r16
                st              x+, r16
                tst             r16
                brne            BinToBcb8_E40           ; if the number extracted is not 0x00 loop
                ldi             r21,9                   ; the number of characters
BinToBcb8_end:  pop             r17                     ; restore the altered registers
                out             SREG, r17               ;
                pop             r27                     ; 
                pop             r26                     ;
                pop             r18                     ; 
                pop             r17                     ;
                pop             r16                     ;
                ret

#endif ; IMPL_BINTOBCH8
