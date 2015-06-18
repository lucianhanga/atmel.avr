

                        .macro          ADI
                        subi            @0, -@1
                        .endmacro


                        ; ldX  - load X register (from data memory)
                        ; 
                        ;       description:    load the X register (r26:r25) with an address from data segment
                        ;       parameters:     @0 - the data memory address (imediate)
                        ;       return:         none
                        .macro      ldX
                        ldi         xl, low(@0)
                        ldi         xh, high(@0)
                        .endmacro
                        ; ldY  - load Y register 
                        .macro      ldY
                        ldi         yl, low(@0)
                        ldi         yh, high(@0)
                        .endmacro
                        ; ldZ  - load Z register 
                        .macro      ldZ
                        ldi         zl, low(@0)
                        ldi         zh, high(@0)
                        .endmacro
                        ; ldXcseg  - load X register (from programm memory)
                        ; 
                        ;       description:    load the X register (r26:r25) with an address from code segment
                        ;       parameters:     @0 - the code memory address (imediate)
                        ;       return:         none
                        .macro      ldXcseg
                        ldi         xl, low(@0 << 1)
                        ldi         xh, high(@0 << 1)
                        .endmacro
                        ; ldYcseg  - load Y register 
                        .macro      ldYcseg
                        ldi         yl, low(@0 << 1)
                        ldi         yh, high(@0 << 1)
                        .endmacro
                        ; ldZcseg  - load Z register 
                        .macro      ldZcseg
                        ldi         zl, low(@0 << 1)
                        ldi         zh, high(@0 << 1)
                        .endmacro
   
                        ; cseg2dsegDWi - imediate code segment to data segment  word (16bit)
                        ; 
                        ;       description:    copy 2 bytes from an programm memory address 
                        ;                       to a data segment address
                        ;       parameters:     @0 - the program memory address (imediate)
                        ;                       @1 - the data memory address (imediate)
                        ;       return:         none
                        ;       observations:   optimised for speed (the loops are unrolled)
                        ;                       NOT optimised for space
                        ;       altered regs:   r0, r29, r30, r31, r32
                        .macro  cseg2dsegDWi
                        ldZcseg         @0
                        ldY             @1
                        lpm             r0, Z+
                        st              Y+, r0
                        lpm             r0, Z
                        st              Y, r0
                        .endmacro

                        ; cseg2dsegDDi - imediate code segment to data segment double word (32bit)
                        ; 
                        ;       description:    copy 4 bytes from an programm memory address 
                        ;                       to a data segment address
                        ;       parameters:     @0 - the program memory address (imediate)
                        ;                       @1 - the data memory address (imediate)
                        ;       return:         none
                        ;       observations:   optimised for speed (the loops are unrolled)
                        ;                       NOT optimised for space
                        ;       altered regs:   r0, r29, r30, r31, r32
                        .macro  cseg2dsegDDi
                        ldZcseg         @0
                        ldY             @1
                        lpm             r0, Z+
                        st              Y+, r0
                        lpm             r0, Z+
                        st              Y+, r0
                        lpm             r0, Z+
                        st              Y+, r0
                        lpm             r0, Z
                        st              Y, r0
                        .endmacro

