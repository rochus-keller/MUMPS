KTR1    ;PRINT UNIBUS DISK ADAPTOR CONTROLLER ERRORS LOGGED BY CARETAKER
        S %DT=$P(ERROR,",",4),%TM=+$P(ERROR,",",5)
        Q:%DT<SDAT  I %DT=SDAT Q:%TM<STIM
        S ERR=$P(@ERROR,";",2) Q:ERR<32768  S ERCODE=ERR#64 S %DO=ERR D %DO^KTR
        W !!!,TY," Controller fatal error at " D %CTS^%H,%CDS^%H W %TIM," on ",%DAT
        W !!,"Contents of status and address (SA) register: ",%DO Q:'ERCODE!(ERCODE>21)
        W !,"Error code:",!?3,ERCODE," - ",$P($T(ERROR+ERCODE),";;",2),!
        Q
ERROR   ;;ASSIGNED PORT-GENERIC FATAL ERROR CODES
        ;;Envelope/Packet Read (parity or timeout).
        ;;Envelope/Packet Write (parity or timeout).
        ;;Controller ROM and RAM parity.
        ;;Controller RAM parity.
        ;;Controller ROM parity.
        ;;Ring Read (parity or timeout).
        ;;Ring Write (parity or timeout).
        ;;Interrupt Master.
        ;;Host Access Timeout (higher-level protocol-dependent).
        ;;Credit Limit Exceeded.
        ;;Unibus Master Error
        ;;Diagnostic Controller Fatal Error.
        ;;Instruction Loop Timeout.
        ;;Invalid Connection Identifier.
        ;;Interrupt Write.
        ;;MAINTENANCE READ/WRITE Invalid Region Identifier.
        ;;MAINTENANCE WRITE Load to non-Loadable Controller.
        ;;Controller RAM error (non-parity)
        ;;INIT sequence error
        ;;High-level protocol incompatibility error
        ;;Purge/poll hardware failure
Z       P KTR1 ZS KTR1 Q
