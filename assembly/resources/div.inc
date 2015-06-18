

#ifdef  IMPL_DIV8U
                ;
                ; proc Div8U    - (Divide 8bit Unsigned)
                ;       descr:  8bit unsigned integer division
                ;       params: r16 - Nominator (N)
                ;               r17 - Denominator (D)
                ;       ret:    r18 - Quotinent (Q)
                ;               r19 - Rest (R) 
                ;       alters: r18, r19
Div8U:          push            r20                             ; save the registers which will be altered
                push            r21                             ; r20, r21, r22
                push            r22                             ; --
                in              r22, SREG                       ; save the Status Register
                push            r22                             ; --
                .def            N = r16
                .def            D = r17
                .def            Q = r18
                .def            R = r19
                .def            index = r20
                .def            tmp = r21
                .def            tmpN = r22
                ldi             index, 0x08                     ; load the index the bit size
                mov             tmpN, N                         ; tmpN <-- N
                clr             Q                               ; Q <-- 0
                clr             R                               ; R <-- 0
Div8U_E10:                                                      ; do
                lsl             tmpN                            ;   Shift Left R:N - get in R bit by bit N, starting
                rol             R                               ;                      from the most significant bit
                lsl             Q                               ;   Q <-- Q << 2
                mov             tmp, R                          ;   tmp <-- R - D
                sub             tmp, D                          ;   --
                brlo            Div8U_E20                       ;   if (R > D) then   [IMPORTANT: UNsinged comparation]
                mov             R,tmp                           ;       R <-- R - D
                inc             Q                               ;       Q <-- Q + 1 
Div8U_E20:      dec             index                           ;   index <-- index - 1  
                cpi             index, 0x00                     ; while (index > 0)
                brne            Div8U_E10                       ; --
                pop             r22                             ; restore the Status Register
                out             SREG, r22                       ; --
                pop             r22                             ; restore the altered registers
                pop             r21                             ; r22, r21, r20
                pop             r20                             ;
                .undef          N
                .undef          D
                .undef          Q
                .undef          R
                .undef          index
                .undef          tmp
                .undef          tmpN
Div8U_end:      ret

#endif //  IMPL_DIV8U

#ifdef  IMPL_DIV16U
                ;
                ; proc Div16U   - (Divide 16bit Unsigned)
                ;       descr:  16bit unsigned integer division
                ;       params: r17:r16 - Nominator (N)
                ;               r19:r18 - Denominator (D)
                ;       ret:    r21:r20 - Quotinent (Q)
                ;               r23:r22 - Rest (R) 
                ;       alters: r20, r21, r22, r23
Div16U:         push            r24                             ; save the registers which will be altered r24 - r29
                push            r25                             ; 
                push            r26                             ; --
                push            r27                             ; --
                push            r28                             ; --
                push            r29                             ; --
                in              r28, SREG                       ; save the Status Register
                push            r28                             ; --
                .def            N_Lo = r16
                .def            N_Hi = r17
                .def            D_Lo = r18
                .def            D_Hi = r19
                .def            Q_Lo = r20
                .def            Q_Hi = r21
                .def            R_Lo = r22
                .def            R_Hi = r23
                .def            tmp_Lo = r24
                .def            tmp_Hi = r25
                .def            tmpN_Lo = r26
                .def            tmpN_Hi = r27
                .def            index = r28
                .def            dummy = r29
                clr             dummy                           ; dummy 
                ldi             index, 0x10                     ; load the index the bit size (16bit)
                mov             tmpN_Lo, N_Lo                   ; tmpN <-- N
                mov             tmpN_Hi, N_Hi                   ; --
                clr             Q_Lo                            ; Q <-- 0
                clr             Q_Hi                            ; --
                clr             R_Lo                            ; R <-- 0
                clr             R_Hi                            ; --
Div16U_E10:                                                     ; do
                lsl             tmpN_Lo                         ;   Shift Left R:N - get in R bit by bit N, starting
                rol             tmpN_Hi                         ;                       from the most significant bit
                rol             R_Lo                            ;   --
                rol             R_Hi                            ;   --                               
                lsl             Q_Lo                            ;   Q <-- Q << 2
                rol             Q_Hi                            ;   --
                mov             tmp_Lo, R_Lo                    ;   tmp <-- R - D
                mov             tmp_Hi, R_Hi                    ;   --
                sub             tmp_Lo, D_Lo                    ;   --
                sbc             tmp_Hi, D_Hi                    ;   --
                brlo            Div16U_E20                      ;   if (R > D) then   [IMPORTANT: UNsinged comparation]
                mov             R_Lo,tmp_Lo                     ;       R <-- R - D
                mov             R_Hi,tmp_Hi                     ;       --
                inc             Q_Lo                            ;       Q <-- Q + 1
                adc             Q_Hi, dummy                     ;       --
Div16U_E20:     dec             index                           ;   index <-- index - 1  
                cpi             index, 0x00                     ; while (index > 0)
                brne            Div16U_E10                       ; --
Div16U_end:     pop             r28                             ; restore the Status Register
                out             SREG, r28                       ; --
                pop             r29                             ; restore the altered registers r24 - r29
                pop             r28                             ; --
                pop             r27                             ; --
                pop             r26                             ; --
                pop             r25                             ; --
                pop             r24                             ; --
                .undef          N_Lo
                .undef          N_Hi
                .undef          D_Lo
                .undef          D_Hi
                .undef          Q_Lo
                .undef          Q_Hi
                .undef          R_Lo
                .undef          R_Hi
                .undef          tmp_Lo
                .undef          tmp_Hi
                .undef          tmpN_Lo
                .undef          tmpN_Hi
                .undef          index
                .undef          dummy
                ret
#endif //  IMPL_DIV16U

/*
#ifdef  IMPL_DIV32U
                ;
                ; proc Div32U   - (Divide 32bit Unsigned)
                ;       descr:  32bit unsigned integer division
                ;       params: r19:r18:r17:r16 - Nominator (N)
                ;               r23:r22:r21:r20 - Denominator (D)
                ;       ret:    r27:r26:r25:r24 - Quotinent (Q)
                ;               r31:r30:r29:r28 - Rest (R) 
                ;       alters: r27-r31
Div32U:         push            r0                              ; save the registers which will be altered r0-r9
                push            r1                              ; --
                push            r2                              ; --
                push            r3                              ; --
                push            r4                              ; --
                push            r5                              ; --
                push            r6                              ; --
                push            r7                              ; --
                push            r8                              ; --
                push            r9                              ; --
                in              r9, SREG                        ; save the Status Register
                push            r9                              ; --
                .def            N3 = r19
                .def            N2 = r18
                .def            N1 = r17
                .def            N0 = r16
                .def            D3 = r23
                .def            D2 = r22
                .def            D1 = r21
                .def            D0 = r20
                .def            Q3 = r27
                .def            Q2 = r26
                .def            Q1 = r25
                .def            Q0 = r24
                .def            Rs3 = r31
                .def            Rs2 = r30
                .def            Rs1 = r29
                .def            Rs0 = r28
                .def            tmp3 = r3
                .def            tmp2 = r2
                .def            tmp1 = r1
                .def            tmp0 = r0
                .def            tmpN3 = r7
                .def            tmpN2 = r6
                .def            tmpN1 = r5
                .def            tmpN0 = r4
                .def            index = r9
                .def            dummy = r10
                clr             dummy                           ; dummy
                ldi             Q0, 32                          ; load in the index the bit size (32bit)
                mov             index, Q0                       ; --
                mov             tmpN0, N0                       ; tmpN <-- N
                mov             tmpN1, N1                       ; --
                mov             tmpN2, N2                       ; --
                mov             tmpN3, N3                       ; --
                clr             Q0                              ; Q <-- 0
                clr             Q1                              ; --
                clr             Q2                              ; --
                clr             Q3                              ; --
                clr             Rs0                             ; Rs <-- 0
                clr             Rs1                             ; --
                clr             Rs2                             ; --
                clr             Rs3                             ; --
Div32U_E10:                                                     ; do
                lsl             tmpN0                           ;   Shift Left R:N - get in R bit by bit N, starting
                rol             tmpN1                           ;                      from the most significant bit
                rol             tmpN2                           ;   --
                rol             tmpN3                           ;   --
                rol             Rs0                             ;   --
                rol             Rs1                             ;   --                               
                rol             Rs2                             ;   --                               
                rol             Rs3                             ;   --                               
                lsl             Q0                              ;   Q <-- Q << 2
                rol             Q1                              ;   --
                rol             Q2                              ;   --
                rol             Q3                              ;   --
                mov             tmp0, Rs0                       ;   tmp <-- R - D
                mov             tmp1, Rs1                       ;   --
                mov             tmp2, Rs2                       ;   --
                mov             tmp3, Rs3                       ;   --
                sub             tmp0, D0                        ;   --
                sub             tmp1, D1                        ;   --
                sub             tmp2, D2                        ;   --
                sbc             tmp3, D3                        ;   --
                brlo            Div32U_E20                      ;   if (R > D) then   [IMPORTANT: UNsinged comparation]
                mov             Rs0,tmp0                        ;       R <-- R - D
                mov             Rs1,tmp1                        ;       --
                mov             Rs2,tmp2                        ;       --
                mov             Rs3,tmp3                        ;       --
                inc             Q0                              ;       Q <-- Q + 1
                adc             Q1, dummy                       ;       --
                adc             Q2, dummy                       ;       --
                adc             Q3, dummy                       ;       --
Div32U_E20:     dec             index                           ;   index <-- index - 1  
                cp              index, dummy                    ; while (index > 0)
                brne            Div32U_E10                      ; --
                pop             r9                              ; restore the Status Register
                out             SREG, r9                        ; --
                pop             r9                              ; restore the altered registers r0-r9
                pop             r8                              ; --
                pop             r7                              ; --
                pop             r6                              ; --
                pop             r5                              ; --
                pop             r4                              ; --
                pop             r3                              ; --
                pop             r2                              ; --
                pop             r1                              ; --
                pop             r0                              ; --
                .undef            N3 
                .undef            N2 
                .undef            N1 
                .undef            N0 
                .undef            D3 
                .undef            D2 
                .undef            D1 
                .undef            D0 
                .undef            Q3 
                .undef            Q2 
                .undef            Q1 
                .undef            Q0 
                .undef            Rs3
                .undef            Rs2
                .undef            Rs1
                .undef            Rs0
                .undef            tmp3 
                .undef            tmp2 
                .undef            tmp1 
                .undef            tmp0 
                .undef            tmpN3
                .undef            tmpN2
                .undef            tmpN1
                .undef            tmpN0
                .undef            index
                .undef            dummy
Div32U_end:     ret 
#endif ; IMPL_DIV32U


*/