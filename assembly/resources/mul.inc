;
;    Atmel AVR Math Library
;	multiplication functions definitions
;
;    Copyright (C) 2013  Lucian Hanga
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;

#ifdef IMP_MUL16U

                ;
                ; proc Mul16U   - (Multiply 16bit Unsigned)
                ;       descr:  16bit unsigned integer multiplication
                ;       params: r17:r16         - Term1
                ;               r19:r18         - Term2
                ;       ret:    r23:r22:r21:r20 - Result
                ;       alters: r20, r21, r22, r23
                ;
Mul16U:         push            r0                              ; save registers r0, r1                 
                push            r1                              ; --
                in              r0, SREG                        ; save the Status Register
                push            r0                              ; --
Mul16U_start:   mul             r16, r18                        ; R1:R0 <-- T1_Lo * T2_Lo
                movw            r21:r20, r1:r0                  ; --
                mul             r17, r19                        ; R3:R2 <-- T1_Hi * T2_Hi
                movw            r23:r22, r1:r0                  ; --
                mul             r16, r19                        ; R2:R1 += T1_Lo * T2_Hi
                add             r21, r0                         ; --
                adc             r22, r1                         ; --
                clr             r1                              ; --
                adc             r23, r1                         ; --
                mul             r17, r18                        ; R2:R1 += T1_Hi * T2_Lo
                add             r21, r0                         ; --
                adc             r22, r1                         ; --
                clr             r1                              ; --
                adc             r23, r1                         ; --
Mul16U_end:     pop             r0                              ; restore the Status Register
                out             SREG, r0                        ; --
                pop             r1                              ; restore registers r0, r1
                pop             r0                              ; --
                ret
#endif ; IMP_MUL16U


