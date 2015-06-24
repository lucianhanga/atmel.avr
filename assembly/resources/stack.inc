;--------10--------20--------30--------40--------50--------60--------70--------80--------90------100
                ;
                ; macro initStk
                ;       descr:  initialize the stack
                ;       params: none
                ;       ret:    none
                ;       alters: r16, SPL, SPH
                ;
                .macro          initStk
                ldi             r16, low(RAMEND)                ; load the RAMEND in theStackPointer
                out             SPL, r16                        ; --
                ldi             r16, high(RAMEND)               ; --
                out             SPH, r16                        ; --
                .endmacro
                ;
                ; macro allocStk
                ;       descr:  allocate space on the stack
                ;       params: @0 - the size in bytes of area which has to be allocated
                ;                    the maximum value is 63 bytes
                ;       ret:    none
                ;       alters: r16, r17, SPL, SPH
                ;
                ;       notes:  NO bounds checking is done
                ;
                .macro          allocStk
                in              r16, SPL                        ; load in r17:r16 the StackPointer  
                in              r17, SPH                        ; --
                sbiw            r16:r17, @0                     ; SP <-- SP - @0
                out             SPL, r16                        ; store back the r17:r16 in the StackPointer
                out             SPH, r17                        ; --
                .endmacro
                ;
                ; macro deallocStk
                ;       descr:  deallocate space in the stack
                ;       params: @0 - the size in bytes of the area which has to be dellocated
                ;                    the maximum value is 63 bytes
                ;       ret:    none
                ;       alters: r16, r17, SPL, SPH
                ;
                ;       notes:  No bounds checksing is done
                ;
                .macro          deallocStk
                in              r16, SPL                        ; load in r17:r16 the StackPointer  
                in              r17, SPH                        ; --
                adiw            r16:r17, @0                     ; SP <-- SP + @0
                out             SPL, r16                        ; store back the r17:r16 in the StackPointer
                out             SPH, r17                        ; --
                .endmacro


                ;
                ;
                ; 
                .macro          pushSREG
                push            r20
                in              r20, SREG
                push            r20
                .endmacro
                ;
                ;
                ;
                .macro          popSREG
                pop             r20
                out             SREG, r20
                pop             r20         
                .endmacro