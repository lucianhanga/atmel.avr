

;
;       
; copy a number of bytes from the code memory to the  datamemory
;
; parameters: @0 - source
;             @1 - destination
;             @2 - bytes
;
 

   
                        .def            len_high   = r27
                        .def            len_low    = r26
                        .def            reg        = r20
                        ;
                        .macro          cpDBcseg2dseg
                        ldZcseg         @0
                        ldY             @1
                        ldi             len_high, high(@2)
                        ldi             len_low, low(@2)
                        call            __cpDBcseg2dseg
                        .endmacro
                        ;
                        .macro          cpDBcseg2dsegS
                        push            r20
                        push            r26
                        push            r27
                        push            r28
                        push            r29
                        push            r30
                        push            r31
                        in              r20, SREG
                        push            r20
                        ldZcseg         @0
                        ldY             @1
                        ldi             len_high, high(@2)
                        ldi             len_low, low(@2)
                        call            __cpDBcseg2dseg
                        pop             r20
                        out             SREG,r20
                        pop             r31
                        pop             r30
                        pop             r29
                        pop             r28
                        pop             r27
                        pop             r26
                        pop             r20
                        .endmacro
                        ;
__cpDBcseg2dseg:
                        cpi             len_high, 0                             ; check if the len is 0
                        brne            __cpDBcseg2dseg_e20
__cpDBcseg2dseg_e10:    cpi             len_low, 0
                        breq            __cpDBcseg2dseg_end                     ; len is 0 - do nothing
__cpDBcseg2dseg_e20:    lpm             reg, Z+
                        st              Y+, reg
                        sbiw            len_low, 1
                        brne            __cpDBcseg2dseg_e20
__cpDBcseg2dseg_end:    ret
                        .undef          len_high
                        .undef          len_low
                        .undef          reg
